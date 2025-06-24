%{
#include "parser.tab.h"
%}

%%

int         { return INT; }
float       { return FLOAT; }
char        { return CHAR; }
const       { return CONST; }
[0-9]+      { yylval.ival = atoi(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.sval = strdup(yytext); return ID; }
";"         { return SEMICOLON; }
","         { return COMMA; }
"="         { return ASSIGN; }

[ \t\n]     ;  // skip whitespace

.           { return yytext[0]; }

%%

int yywrap(void) { return 1;}
