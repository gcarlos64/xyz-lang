#include "../symtab.h"
#include <stddef.h>
#include <stdarg.h>
#include <stdio.h>

int yyerror(const char *msg, ...) {
	va_list args;

	va_start(args, msg);
	vfprintf(stderr, msg, args);
	va_end(args);

	return 0;
}

int main(void)
{
	struct symtab *s = NULL;
	struct var_symtab *vs = NULL;

	symtab_install_var(&vs, "id1", "i64");
	printf("%d\n", *(vs->syms[0].name + 32));
	symtab_install_var(&vs, "id2", "i64");
	symtab_install_var(&vs, "id3", "f64");
	printf("%d\n", *(vs->syms[0].name + 32));
	symtab_install_function(&s, &vs, "func1", "fn(f64)");
	symtab_install_var(&vs, "id3", "f64");
	symtab_install_var(&vs, "id5", "i64");
	symtab_install_var(&vs, "id7", "i64");
	symtab_install_var(&vs, "id8", "i64");
	symtab_install_function(&s, &vs, "func2", "fn(f64)");
	symtab_install_function(&s, &vs, "func3", "fn(f64)");
	symtab_print(s);
	return 0;
}
