#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "symtab.h"
#include "xyz.tab.h"

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

void symtab_install_var(struct var_symtab *vs, char *name, char *type)
{
	struct symbol *sym;

	if (!vs)
		vs = init_var_symtab();

	if (!symtab_lookup_var(vs, name)) {
		if (vs->count == MAXSYMS) {
			yyerror("more than %ud variables was declared on the same scope", MAXSYMS);
			exit(1);
		}

		sym = &vs->syms[vs->count++];
		strcpy(sym->name, name);
		strcpy(sym->type, type);
	} else {
		yyerror("multiple definitions of var \"%s\" on the same scope", name);
		exit(1);
	}
}

void symtab_install_function(struct symtab *s, struct var_symtab **vs,
                             char *name, char *type)
{
	struct fsymbol *fsym;

	if (!s)
		s = init_symtab();

	if (!symtab_lookup_function(s, name)) {
		if ((*vs)->count == MAXSYMS) {
			yyerror("more than %ud functions was declared", MAXSYMS);
			exit(1);
		}

		fsym = &s->fsyms[s->count++];
		strcpy(fsym->sym.name, name);
		strcpy(fsym->sym.type, type);
		fsym->var_syms = *vs;
		*vs = NULL;
	} else {
		yyerror("multiple definitions of function \"%\"", name);
		exit(1);
	}
}

struct fsymbol *symtab_lookup_function(struct symtab *s, char *name)
{
	struct fsymbol *fsp = s->fsyms;
	unsigned int i = 0;

	if (s->count == 0)
    		return NULL;

    	do {
		if (!strncmp(fsp->sym.name, name, MAXNAME))
    			return fsp;
		fsp++;
		i++;
	} while (i < s->count);

	return NULL;
}

struct symbol *symtab_lookup_var(struct var_symtab *vs, char *name)
{
	struct symbol *sp = vs->syms;
	unsigned int i = 0;

	if (vs->count == 0)
    		return NULL;

    	do {
		if (!strncmp(sp->name, name, MAXNAME))
    			return sp;
		sp++;
		i++;
	} while (i < vs->count);

	return NULL;
}

void symtab_print(struct symtab *s)
{
	struct fsymbol *fsym;
	struct symbol *vsym;
	int i, j;

	if (s->count == 0)
    		return;

	for (i = 0, fsym = s->fsyms; i < s->count; i++, fsym++) {
    		printf("%s\t%s\n", fsym->sym.name, fsym->sym.type);

    		for (j = 0, vsym = fsym->var_syms->syms; i < fsym->var_syms->count; j++, vsym++) {
        		if (fsym->var_syms->count == 0)
            			break;

        		printf("%s.%s\t%s\n", fsym->sym.name, vsym->name, vsym->type);
    		}
	}
}
