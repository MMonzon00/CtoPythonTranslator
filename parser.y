%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
void addToPythonVars(char* var);
int yylex(void);
int yyerror(char *s);
%}

%union {
    int ival;
    char* sval;
}

%token <ival> NUMBER
%token <sval> ID
%token INT FLOAT CHAR CONST
%token SEMICOLON COMMA ASSIGN

%type <sval> type idlist

%%

program:
    declarations
    ;

declarations: 
    declaration 
    | declarations declaration
    ;

declaration:
    type idlist SEMICOLON {
        char* ids = $2;
        char* token = strtok(ids, ",");
        while (token != NULL) {
            printf("%s = None\n", token); // Output as Python assignment
            token = strtok(NULL, ",");
        }
        free($2);
    }
    ;

type:
    INT     {$$ = "int";}
    | FLOAT {$$ = "float";}
    | CHAR  {$$ = "char";}
    ;

idlist:
    ID {
        $$ = strdup($1);
    }
    | idlist COMMA ID {
        char* tmp = malloc(strlen($1) + strlen($3) + 2);
        sprintf(tmp, "%s,%s", $1, $3);
        free($1);
        $$ = tmp;
    }
    ;

%%

int main() {
    yyparse();
    return 0;
}

int yyerror(char* s) {
    fprintf(stderr, "Error: %s\n", s);
    return 0;
}
