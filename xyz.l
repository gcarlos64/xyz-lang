
%{
#include <stdlib.h>
#include "xyz.tab.h"

extern int yyerror (char const *msg, ...);

%}

identifier  [a-zA-Z][a-zA-Z_]*
int         [0]|[1-9][0-9]*
float       [0]|[1-9][0-9]*.[0-9]*(E("+"|"-")[0]|[1-9][0-9]*)?

%option noyywrap nodefault yylineno
%%

{int}                           { yylval.i = atoi(yytext); return CONST_INT; }
{float}                         { yylval.f = atof(yytext); return CONST_FLOAT; }
"i64"                           { return(I64); }
"f64"                           { return(F64); }
"if"                            { return(IF); }
"else"                          { return(ELSE); }
"while"                         { return(WHILE); }
"return"                        { return(RETURN); }
"fn"                            { return(FN); }
"var"                           { return(VAR); }
{identifier}                    { yylval.s = strdup(yytext); return(IDENTIFIER); }
"("			                    { return('('); }
")"			                    { return(')'); }
"{"			                    { return('{'); }
"}"			                    { return('}'); }
"+"                             { return('+'); }
"-"                             { return('-'); }
"*"                             { return('*'); }
"/"                             { return('/'); }
"%"                             { return('%'); }
"<"                             { return('<'); }
">"                             { return('>'); }
"++"			                { return(INC_OP); }
"--"			                { return(DEC_OP); }
"<="                            { return(LE_OP); }
">="                            { return(GE_OP); }
"=="                            { return(EQ_OP); }
"!="                            { return(NE_OP); }                
"&&"                            { return(AND_OP); }
"||"                            { return(OR_OP); }

[ \t\r\n]                       { }
.                               { yyerror("unknown token %s\n", yytext); }

%%