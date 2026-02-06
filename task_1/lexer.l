%option noyywrap

%{
#include "icg.tab.h"
#include <string.h>
#include <stdlib.h>

extern int line_num ;
%}

DIGIT      [0-9]
ID         [a-zA-Z][a-zA-Z0-9]*
NEWLINE    \n
WHITESPACE [ \t\r]+

%%

"**="      { return EXP_ASSIGN; }
"//="      { return DIV_ASSIGN; }
"+="       { return ADD_ASSIGN; }
"-="       { return SUB_ASSIGN; }
"*="       { return MUL_ASSIGN; }
"/="       { return DIV_ASSIGN; }
"%="       { return MOD_ASSIGN; }

"**"       { return EXP; }
"//"       { return INTDIV; }
"*"        { return MUL; }
"/"        { return DIV; }
"+"        { return ADD; }
"-"        { return SUB; }
"%"        { return MOD; }
"="        { return ASSIGN; }
"&&"       { return AND; }
"||"       { return OR; }
"!"        { return NOT; }
">"        { return GT; }
"<"        { return LT; }
"("        { return LPAREN; }
")"        { return RPAREN; }

{ID}       { yylval.str = strdup(yytext); return ID; }
{DIGIT}+   { yylval.str = strdup(yytext); return NUM; }
{NEWLINE}  { line_num++; return NEWLINE; }
{WHITESPACE}   { /* ignore */ }

^[0-9]+[ \t]+ { /* ignore line numbers at line start */ }

.          { printf("Invalid char: %s\n", yytext); }

%%
