digit	[0-9]
letterup	[A-Z]
lettermix [A-Za-z]
letterlow [a-z]
%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"
int linenum;

%}
%%
"\<"{letterup}{lettermix}*"\>"    yylval.str = strdup(yytext); return NONTERMINAL;
{letterup}{lettermix}*"\>"  return ERROR1;
"\<"{letterup}{lettermix}*  return ERROR2;
"<" return SMALL;
">" return BIG;
"->" return ARROW;
{letterlow}+    yylval.str = strdup(yytext);  return TERMINAL;
";" return SEMICOLON;
\n  linenum++;
[ \t]+
%%
