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
	double f;
	char *s;
}

%token CONST_INT CONST_FLOAT
%token IDENTIFIER FN VAR
%token INC_OP DEC_OP LE_OP GE_OP EQ_OP NE_OP AND_OP OR_OP
%token IF ELSE WHILE RETURN
%token I64 F64

%start program
%%

program	    : function_declaration_list		  
			;

assignment  : IDENTIFIER '=' expression ';'
			;

type_specifier
			: I64
			| F64
			;

declaration_assignment
			: IDENTIFIER ':' type_specifier '=' expression ';'
			;

declaration_assignment_list
			: declaration_assignment
			| declaration_assignment_list declaration_assignment
			;

declaration_list
			: VAR declaration_assignment_list
			;

statement   : expression
			| assignment
			| selection_statement
			| loop_statement
			| compound_statement
			| return_statement
			:

selection_statement
			: IF expression compound_statement
			| IF expression compound_statement ELSE compound_statement
			;

loop_statement
			: WHILE expression compound_statement
			;

return_statement
			: RETURN CONST_INT ';'
			| RETURN expression ';'
			;

statement_list
			: statement ';'
			| statement_list statement
			;

parameter_declaration
			: IDENTIFIER type_specifier
			;

parameter_list
			: parameter_declaration
			| parameter_list ',' parameter_declaration
			;

compound_statement
			: '{' '}'
			| '{' statement_list '}'
			| '{' declaration_list '}'
			| '{' declaration_list statement_list '}'
			;

function_declaration
			: FN IDENTIFIER '(' parameter_list ')' compound_statement
			| FN IDENTIFIER '(' ')' compound_statement
			;

function_declaration_list
			: function_declaration
			| function_declaration_list function_declaration
			;

primary_expression 
			: IDENTIFIER
			| CONST_INT
			| CONST_FLOAT
			;

postfix_expression
			: primary_expression
			| postfix_expression INC_OP
			| postfix_expression DEC_OP
			;

unary_expression
			: postfix_expression
			| INC_OP unary_expression
			| DEC_OP unary_expression
			| unary_operator unary_expression
			;

unary_operator
			: '-'
			| '!'
			;

multiplicative_expression
			: unary_expression
			| multiplicative_expression '*' unary_expression
			| multiplicative_expression '/' unary_expression
			| multiplicative_expression '%' unary_expression
			;

additive_expression
			: multiplicative_expression
			| additive_expression '+' multiplicative_expression
			| additive_expression '-' multiplicative_expression
			;

relational_expression
			: additive_expression
			| relational_expression '<' additive_expression
			| relational_expression '>' additive_expression
			| relational_expression LE_OP additive_expression
			| relational_expression GE_OP additive_expression
			;

equality_expression
			: relational_expression
			| equality_expression EQ_OP relational_expression
			| equality_expression NE_OP relational_expression
			;

logical_and_expression
			: equality_expression
			| logical_and_expression AND_OP equality_expression
			;
 
logical_or_expression
			: logical_and_expression
			| logical_or_expression OR_OP logical_and_expression
			;
 
conditional_expression
 			: logical_or_expression
			;

expression
			: conditional_expression
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
