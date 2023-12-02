%{
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.h"

extern int yylex();
extern int yyerror(const char *msg, ...);

struct symtab *st = NULL;
struct var_symtab *vst = NULL;

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

%token <i> CONST_INT
%token <f> CONST_FLOAT
%token <s> ID T_I64 T_F64
%token INC_OP DEC_OP LE_OP GE_OP EQ_OP NE_OP AND_OP OR_OP
%token IF ELSE WHILE RETURN
%token FN VAR

%type <s> type_specifier parameter_declaration parameter_list

%start program
%%

program
	: function_declaration_list
	;

type_specifier
	: T_I64
	| T_F64
	;

declaration_assignment
	: ID ':' type_specifier '=' expression { symtab_install_var(&vst, $1, $3); }
	;

declaration_assignment_list
	: declaration_assignment
	| declaration_assignment_list ',' declaration_assignment
	;

declaration_list
	: VAR declaration_assignment_list ';'
	;

assignment_statement
	: ID '=' expression_statement
	;

expression_statement
	: ';'
	| expression ';'
	;

statement
	: expression_statement
	| assignment_statement
	| selection_statement
	| loop_statement
	| compound_statement
	| return_statement
	;

selection_statement
	: IF expression compound_statement
	| IF expression compound_statement ELSE compound_statement
	;

loop_statement
	: WHILE expression compound_statement
	;

return_statement
	: RETURN expression_statement
	;

statement_list
	: statement
	| statement_list statement
	;

parameter_declaration
	: ID type_specifier { $$ = $2; symtab_install_var(&vst, $1, $2); }
	;

parameter_list
	: parameter_declaration
	| parameter_list ',' parameter_declaration { char *s = malloc(strlen($1) + strlen($3) + 2);
						     strcat(s, $1);
						     strcat(s, ",");
						     $$ = strcat(s, $3); }
	;

compound_statement
	: '{' '}'
	| '{' statement_list '}'

function_compound_statement
	: compound_statement
	| '{' declaration_list '}'
	| '{' declaration_list statement_list '}'
	;

function_declaration
	: FN ID '(' parameter_list ')' function_compound_statement { char *s = malloc(strlen($4) + 5);
								    strcat(s, "fn(");
								    strcat(s, $4);
								    strcat(s, ")");
								    symtab_install_function(&st, &vst, $2, s); }
	| FN ID '(' ')' function_compound_statement { symtab_install_function(&st, &vst, $2, "fn()"); }
	;

function_declaration_list
	: function_declaration
	| function_declaration_list function_declaration
	;

argument_expression_list
	: expression
	| argument_expression_list ',' expression
	;

primary_expression 
	: ID
	| ID '(' ')'
	| ID '(' argument_expression_list ')'
	| CONST_INT
	| CONST_FLOAT
	| '(' expression ')'
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

expression
	: logical_or_expression
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

	symtab_print(st);

	return 0;
}
