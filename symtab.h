#ifndef SYMTAB_H
#define SYMTAB_H

extern int yyerror(const char *msg, ...);

#define MAXNAME 32
#define MAXSYMS 32

/* This limits function to take up to 9 arguments. */
#define MAXTYPE 32

struct symbol {
	/*
	 * @type is a designator like: i64 to denote the i64 type
	 * and f(i64,f64) to denote a function that takes two
	 * arguments, respectively of type i64 and f64.
	 */
	char type[MAXTYPE];

	char name[MAXNAME];
};

/* Symbol table for variables only */
struct var_symtab {
	struct symbol syms[MAXSYMS];
	unsigned short count;
};

/*
 * A function symbol is composed by the fields of a regular symbols plus
 * a pointer to a symtab of varsu
 */
struct fsymbol {
	struct symbol sym;
	struct var_symtab *var_syms;
};

struct symtab {
	struct fsymbol fsyms[MAXSYMS];
	unsigned short count;
};

void symtab_install_var(struct var_symtab *vs, char *name, char *type);
void symtab_install_function(struct symtab *s, struct var_symtab **vs, char *name, char *type);
struct fsymbol *symtab_lookup_function(struct symtab *s, char *name);
struct symbol *symtab_lookup_var(struct var_symtab *vs, char *name);
void symtab_print(struct symtab *s);

#endif
