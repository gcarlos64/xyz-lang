#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "symtab.h"

static inline struct var_symtab *init_var_symtab(void)
{
	struct var_symtab *vs = (struct var_symtab *)malloc(sizeof(struct var_symtab));
	vs->count = 0;
	return vs;
}

static struct symtab *init_symtab(void)
{
	struct symtab *s = (struct symtab *)malloc(sizeof(struct symtab));
	s->count = 0;
	return s;
}

void symtab_install_var(struct var_symtab **vs, char *name, char *type)
{
	struct symbol *sym;

	if (!*vs)
		*vs = init_var_symtab();

	if (!symtab_lookup_var(*vs, name)) {
		if ((*vs)->count == MAXSYMS) {
			yyerror("more than %ud variables was declared on the same scope",
				MAXSYMS);
			exit(1);
		}

		sym = &(*vs)->syms[(*vs)->count++];
		sym->name = strdup(name);
		sym->type = strdup(type);
	} else {
		yyerror("multiple definitions of var \"%s\" on the same scope",
			name);
		exit(1);
	}
}

void symtab_install_function(struct symtab **s, struct var_symtab **vs,
                             char *name, char *type)
{
	struct fsymbol *fsym;

	if (!*s)
		*s = init_symtab();

	if (!symtab_lookup_function(*s, name)) {
		if ((*s)->count == MAXSYMS) {
			yyerror("more than %ud functions was declared\n", MAXSYMS);
			exit(1);
		}

		fsym = &(*s)->fsyms[(*s)->count++];
		fsym->sym.name = strdup(name);
		fsym->sym.type = strdup(type);
		fsym->var_syms = *vs;
		*vs = NULL;
	} else {
		yyerror("multiple definitions of function \"%s\"\n", name);
		exit(1);
	}
}

struct fsymbol *symtab_lookup_function(struct symtab *s, char *name)
{
	struct fsymbol *fsym = s->fsyms;
	unsigned int i = 0;

	if (s->count == 0)
    		return NULL;

    	do {
		if (!strcmp(fsym->sym.name, name))
    			return fsym;
		fsym++;
		i++;
	} while (i < s->count);

	return NULL;
}

struct symbol *symtab_lookup_var(struct var_symtab *vs, char *name)
{
	struct symbol *sym = vs->syms;
	unsigned int i = 0;

	if (vs->count == 0)
    		return NULL;

    	do {
		if (!strcmp(sym->name, name))
    			return sym;
		sym++;
		i++;
	} while (i < vs->count);

	return NULL;
}

void symtab_print(struct symtab *s)
{
	struct fsymbol *fsym;
	struct symbol *vsym;
	int i, j;

	if (!s || !s->count)
    		return;

	fsym = s->fsyms;
	for (i = 0; i < s->count; i++, fsym++) {
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
