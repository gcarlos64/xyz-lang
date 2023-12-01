#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "symtab.h"

static inline struct var_symtab *init_var_symtab(void)
{
	struct var_symtab *vst = (struct var_symtab *)malloc(sizeof(struct var_symtab));
	vst->count = 0;
	return vst;
}

static struct symtab *init_symtab(void)
{
	struct symtab *st = (struct symtab *)malloc(sizeof(struct symtab));
	st->count = 0;
	return st;
}

void symtab_install_var(struct var_symtab **vst, char *name, char *type)
{
	struct symbol *sym;

	if (!*vst)
		*vst = init_var_symtab();

	if (!symtab_lookup_var(*vst, name)) {
		if ((*vst)->count == MAXSYMS) {
			yyerror("more than %ud variables was declared on the same scope",
				MAXSYMS);
			exit(1);
		}

		sym = &(*vst)->syms[(*vst)->count++];
		sym->name = strdup(name);
		sym->type = strdup(type);
	} else {
		yyerror("multiple definitions of var \"%s\" on the same scope",
			name);
		exit(1);
	}
}

void symtab_install_function(struct symtab **st, struct var_symtab **vst,
                             char *name, char *type)
{
	struct fsymbol *fsym;

	if (!*st)
		*st = init_symtab();

	if (!symtab_lookup_function(*st, name)) {
		if ((*st)->count == MAXSYMS) {
			yyerror("more than %ud functions was declared\n", MAXSYMS);
			exit(1);
		}

		fsym = &(*st)->fsyms[(*st)->count++];
		fsym->sym.name = strdup(name);
		fsym->sym.type = strdup(type);
		fsym->var_syms = *vst;
		*vst = NULL;
	} else {
		yyerror("multiple definitions of function \"%s\"\n", name);
		exit(1);
	}
}

struct fsymbol *symtab_lookup_function(struct symtab *st, char *name)
{
	struct fsymbol *fsym = st->fsyms;
	unsigned int i = 0;

	if (st->count == 0)
    		return NULL;

    	do {
		if (!strcmp(fsym->sym.name, name))
    			return fsym;
		fsym++;
		i++;
	} while (i < st->count);

	return NULL;
}

struct symbol *symtab_lookup_var(struct var_symtab *vst, char *name)
{
	struct symbol *sym = vst->syms;
	unsigned int i = 0;

	if (vst->count == 0)
    		return NULL;

    	do {
		if (!strcmp(sym->name, name))
    			return sym;
		sym++;
		i++;
	} while (i < vst->count);

	return NULL;
}

void symtab_print(struct symtab *st)
{
	struct fsymbol *fsym;
	struct symbol *vsym;
	int i, j;

	if (!st || !st->count)
    		return;

	fsym = st->fsyms;
	for (i = 0; i < st->count; i++, fsym++) {
    		printf("%s [%s]\n", fsym->sym.name, fsym->sym.type);

		if (!fsym->var_syms)
    			break;

		vsym = fsym->var_syms->syms;
		for (j = 0; j < fsym->var_syms->count; j++, vsym++) {
        		if (!fsym->var_syms->count)
            			break;

        		printf("%s.%s [%s]\n", fsym->sym.name, vsym->name, vsym->type);
    		}
	}
}
