%{
#include "parser.tab.h"
%}

%%

int         { return INT; }
float       { return FLOAT; }
char        { return CHAR; }
const       { return CONST; }
if          { return IF; }
else        { return ELSE; }
while       { return WHILE; }
for         { return FOR; }
do          { return DO; }
break       { return BREAK; }
continue    { return CONTINUE; }
return      { return RETURN; }
void        { return VOID; }

"+"         { return PLUS; }
"-"         { return MINUS; }
"*"         { return MULTIPLY; }
"/"         { return DIVIDE; }
"%"         { return MODULO; }
"="         { return ASSIGN; }
"=="        { return EQ; }
"!="        { return NE; }
"<"         { return LT; }
"<="        { return LE; }
">"         { return GT; }
">="        { return GE; }
"&&"        { return AND; }
"||"        { return OR; }
"!"         { return NOT; }

"("         { return LPAREN; }
")"         { return RPAREN; }
"{"         { return LBRACE; }
"}"         { return RBRACE; }
"["         { return LBRACKET; }
"]"         { return RBRACKET; }
";"         { return SEMICOLON; }
","         { return COMMA; }

[0-9]+\.[0-9]+  { yylval.fval = atof(yytext); return FLOAT_NUM; }
[0-9]+          { yylval.ival = atoi(yytext); return NUMBER; }
'[^']'          { yylval.cval = yytext[1]; return CHAR_LITERAL; }
\"[^\"]*\"      { yylval.sval = strdup(yytext); return STRING_LITERAL; }

[a-zA-Z_][a-zA-Z0-9_]* { yylval.sval = strdup(yytext); return ID; }

[ \t\n\r]     ;
"//".*      ;
"/*"([^*]|\*+[^*/])*\*+"/"  ;
.           { return yytext[0]; }

%%

int yywrap(void) { return 1; }