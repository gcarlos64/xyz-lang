/* 
   Avaliacao simbolica de expressoes aritmeticas
*/

%{
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include "symtab.h"

extern int yylex();
extern int yyerror(const char *msg, ...);

struct symtab *s = NULL;
struct var_symtab *vs = NULL;

/*
 * To debug, run `bison --verbose --debug -d file.y`
 */
int yydebug = 1;

%}

%union {
	int i;
	char *s;
}

%token  <i> T_INT
%token  <s> T_ID
%type   <i> expr

%left '+' '-'
%left '*' '/'
%right '='

%start program

%%
program	 : assign_list { return 0; }		  
		;

assign_list     : assignment
		| assignment  assign_list
		;

assignment      : T_ID '=' expr ';'	     { ; }
		;

expr	    : expr '+' expr		 { $$ = $1 + $3; }
		| expr '-' expr		 { $$ = $1 - $3; }
		| expr '*' expr		 { $$ = $1 * $3; }
		| expr '/' expr		 { $$ = $1 / $3; }
		| T_INT			 { $$ = $1; }
		;
%%

#include "xyz.yy.c"

int yyerror(const char *msg, ...) {
	va_list args;

	va_start(args, msg);
	vfprintf(stderr, msg, args);
	va_end(args);

	return 0;
}

int main (int argc, char **argv) {
	FILE *fp;

	if (argc < 2) { 
		fprintf(stderr, "usage: %s <file>\n", argv[0]);
		return 1;
	}

	fp = fopen(argv[1], "r");
	if (!fp) {
		perror(argv[1]);
		return errno;
	}

	yyin = fp;
	do {
		yyparse();
	} while(!feof(yyin));

	symtab_print(s);

	return 0;
}
