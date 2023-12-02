
%{
#include <stdlib.h>
#include "xyz.tab.h"

extern int yyerror (char const *msg, ...);
%}

ID		[a-zA-Z][a-zA-Z_]*
CONST_INT	0|[1-9][0-9]*
CONST_FLOAT	{CONST_INT}\.[0-9]*(E[+-]?{CONST_INT})?

%option noyywrap nodefault yylineno
%%
"i64"		{ yylval.s = strdup(yytext); return T_I64; }
"f64"		{ yylval.s = strdup(yytext); return T_F64; }
"if"		{ return IF; }
"else"		{ return ELSE; }
"while"		{ return WHILE; }
"return"	{ return RETURN; }
"fn"		{ return FN; }
"var"		{ return VAR; }
{CONST_INT}	{ yylval.i = atoi(yytext); return CONST_INT; }
{CONST_FLOAT}	{ yylval.f = atof(yytext); return CONST_FLOAT; }
{ID}		{ yylval.s = strdup(yytext); return ID; }
","		{ return yytext[0]; }
"="		{ return yytext[0]; }
":"		{ return yytext[0]; }
";"		{ return yytext[0]; }
"("		{ return yytext[0]; }
")"		{ return yytext[0]; }
"{"		{ return yytext[0]; }
"}"		{ return yytext[0]; }
"+"		{ return yytext[0]; }
"-"		{ return yytext[0]; }
"*"		{ return yytext[0]; }
"/"		{ return yytext[0]; }
"%"		{ return yytext[0]; }
"<"		{ return yytext[0]; }
">"		{ return yytext[0]; }
"++"		{ return INC_OP; }
"--"		{ return DEC_OP; }
"<="		{ return LE_OP; }
">="		{ return GE_OP; }
"=="		{ return EQ_OP; }
"!="		{ return NE_OP; }
"&&"		{ return AND_OP; }
"||"		{ return OR_OP; }
[ \t\r\n]	{ }
.		{ yyerror("unknown token %s\n", yytext); }
%%
