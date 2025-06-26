%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct symbol {
    char* name;
    char* type;
    int is_const;
    struct symbol* next;
} symbol_t;

symbol_t* symbol_table = NULL;
int indent_level = 0;
FILE* output_file = NULL;
char* input_filename = NULL;
char* output_filename = NULL;

void add_symbol(char* name, char* type, int is_const);
symbol_t* find_symbol(char* name);
void print_indent();
void generate_python_declaration(char* type, char* name, int is_const);
char* translate_type(char* c_type);
char* get_output_filename(char* input_name);
void open_output_file(char* filename);
void close_output_file();

int yylex(void);
int yyerror(char *s);
extern FILE* yyin;
%}

%union {
    int ival;
    float fval;
    char cval;
    char* sval;
}

%token <ival> NUMBER
%token <fval> FLOAT_NUM
%token <cval> CHAR_LITERAL
%token <sval> ID STRING_LITERAL
%token INT FLOAT CHAR CONST VOID
%token IF ELSE WHILE FOR DO BREAK CONTINUE RETURN
%token PLUS MINUS MULTIPLY DIVIDE MODULO
%token ASSIGN EQ NE LT LE GT GE AND OR NOT
%token LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET
%token SEMICOLON COMMA

%type <sval> type idlist expression term factor
%type <ival> const_flag

%left OR
%left AND
%left EQ NE
%left LT LE GT GE
%left PLUS MINUS
%left MULTIPLY DIVIDE MODULO
%right NOT
%right UMINUS
%nonassoc ELSE

%%

program:
    declarations statements
    | declarations
    | statements
    ;

declarations: 
    /* empty */
    | declarations declaration
    ;

declaration:
    const_flag type idlist SEMICOLON {
        char* ids = $3;
        char* token = strtok(ids, ",");
        while (token != NULL) {
            add_symbol(token, $2, $1);
            generate_python_declaration($2, token, $1);
            token = strtok(NULL, ",");
        }
        free($3);
    }
    ;

const_flag:
    /* empty */ { $$ = 0; }
    | CONST     { $$ = 1; }
    ;

type:
    INT     { $$ = strdup("int"); }
    | FLOAT { $$ = strdup("float"); }
    | CHAR  { $$ = strdup("char"); }
    | VOID  { $$ = strdup("void"); }
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

statements:
    /* empty */
    | statements statement
    ;

statement:
    assignment_statement
    | if_statement
    | while_statement
    | for_statement
    | compound_statement
    | expression_statement
    ;

assignment_statement:
    ID ASSIGN expression SEMICOLON {
        symbol_t* sym = find_symbol($1);
        if (sym) {
            if (sym->is_const) {
                yyerror("Cannot assign to constant variable");
            } else {
                print_indent();
                fprintf(output_file, "%s = %s\n", $1, $3);
            }
        } else {
            yyerror("Undeclared variable");
        }
        free($1);
        free($3);
    }
    ;

if_statement:
    IF LPAREN expression RPAREN statement %prec ELSE {
        print_indent();
        fprintf(output_file, "if %s:\n", $3);
        free($3);
    }
    | IF LPAREN expression RPAREN statement ELSE statement {
        print_indent();
        fprintf(output_file, "if %s:\n", $3);
        print_indent();
        fprintf(output_file, "else:\n");
        free($3);
    }
    ;

while_statement:
    WHILE LPAREN expression RPAREN statement {
        print_indent();
        fprintf(output_file, "while %s:\n", $3);
        free($3);
    }
    ;

for_statement:
    FOR LPAREN assignment_or_empty SEMICOLON expression SEMICOLON assignment_or_empty RPAREN statement {
        print_indent();
        fprintf(output_file, "while %s:\n", $5);
        free($5);
    }
    ;

assignment_or_empty:
    /* empty */
    | ID ASSIGN expression {
        print_indent();
        fprintf(output_file, "%s = %s\n", $1, $3);
        free($1);
        free($3);
    }
    ;

compound_statement:
    LBRACE statements RBRACE
    ;

expression_statement:
    expression SEMICOLON {
        print_indent();
        fprintf(output_file, "%s\n", $1);
        free($1);
    }
    | SEMICOLON /* empty statement */
    ;

expression:
    term { $$ = $1; }
    | expression PLUS term {
        char* result = malloc(strlen($1) + strlen($3) + 4);
        sprintf(result, "%s + %s", $1, $3);
        free($1); free($3);
        $$ = result;
    }
    | expression MINUS term {
        char* result = malloc(strlen($1) + strlen($3) + 4);
        sprintf(result, "%s - %s", $1, $3);
        free($1); free($3);
        $$ = result;
    }
    | expression MULTIPLY term {
        char* result = malloc(strlen($1) + strlen($3) + 4);
        sprintf(result, "%s * %s", $1, $3);
        free($1); free($3);
        $$ = result;
    }
    | expression DIVIDE term {
        char* result = malloc(strlen($1) + strlen($3) + 4);
        sprintf(result, "%s / %s", $1, $3);
        free($1); free($3);
        $$ = result;
    }
    | expression EQ term {
        char* result = malloc(strlen($1) + strlen($3) + 5);
        sprintf(result, "%s == %s", $1, $3);
        free($1); free($3);
        $$ = result;
    }
    | expression NE term {
        char* result = malloc(strlen($1) + strlen($3) + 5);
        sprintf(result, "%s != %s", $1, $3);
        free($1); free($3);
        $$ = result;
    }
    | expression LT term {
        char* result = malloc(strlen($1) + strlen($3) + 4);
        sprintf(result, "%s < %s", $1, $3);
        free($1); free($3);
        $$ = result;
    }
    | expression LE term {
        char* result = malloc(strlen($1) + strlen($3) + 5);
        sprintf(result, "%s <= %s", $1, $3);
        free($1); free($3);
        $$ = result;
    }
    | expression GT term {
        char* result = malloc(strlen($1) + strlen($3) + 4);
        sprintf(result, "%s > %s", $1, $3);
        free($1); free($3);
        $$ = result;
    }
    | expression GE term {
        char* result = malloc(strlen($1) + strlen($3) + 5);
        sprintf(result, "%s >= %s", $1, $3);
        free($1); free($3);
        $$ = result;
    }
    | expression AND term {
        char* result = malloc(strlen($1) + strlen($3) + 6);
        sprintf(result, "%s and %s", $1, $3);
        free($1); free($3);
        $$ = result;
    }
    | expression OR term {
        char* result = malloc(strlen($1) + strlen($3) + 5);
        sprintf(result, "%s or %s", $1, $3);
        free($1); free($3);
        $$ = result;
    }
    ;

term:
    factor { $$ = $1; }
    | MINUS term %prec UMINUS {
        char* result = malloc(strlen($2) + 2);
        sprintf(result, "-%s", $2);
        free($2);
        $$ = result;
    }
    | NOT term {
        char* result = malloc(strlen($2) + 5);
        sprintf(result, "not %s", $2);
        free($2);
        $$ = result;
    }
    ;

factor:
    ID { 
        symbol_t* sym = find_symbol($1);
        if (!sym) {
            yyerror("Undeclared variable");
        }
        $$ = strdup($1); 
    }
    | NUMBER { 
        char* result = malloc(20);
        sprintf(result, "%d", $1);
        $$ = result;
    }
    | FLOAT_NUM {
        char* result = malloc(30);
        sprintf(result, "%.6f", $1);
        $$ = result;
    }
    | CHAR_LITERAL {
        char* result = malloc(10);
        sprintf(result, "'%c'", $1);
        $$ = result;
    }
    | STRING_LITERAL { $$ = strdup($1); }
    | LPAREN expression RPAREN { $$ = $2; }
    ;

%%

void add_symbol(char* name, char* type, int is_const) {
    symbol_t* new_symbol = malloc(sizeof(symbol_t));
    new_symbol->name = strdup(name);
    new_symbol->type = strdup(type);
    new_symbol->is_const = is_const;
    new_symbol->next = symbol_table;
    symbol_table = new_symbol;
}

symbol_t* find_symbol(char* name) {
    symbol_t* current = symbol_table;
    while (current) {
        if (strcmp(current->name, name) == 0) {
            return current;
        }
        current = current->next;
    }
    return NULL;
}

void print_indent() {
    for (int i = 0; i < indent_level; i++) {
        fprintf(output_file, "    ");
    }
}

void generate_python_declaration(char* type, char* name, int is_const) {
    print_indent();
    if (is_const) {
        fprintf(output_file, "# Constant: %s\n", name);
        print_indent();
    }
    
    if (strcmp(type, "int") == 0) {
        fprintf(output_file, "%s = 0  # int\n", name);
    } else if (strcmp(type, "float") == 0) {
        fprintf(output_file, "%s = 0.0  # float\n", name);
    } else if (strcmp(type, "char") == 0) {
        fprintf(output_file, "%s = ''  # char\n", name);
    } else {
        fprintf(output_file, "%s = None  # %s\n", name, type);
    }
}

char* translate_type(char* c_type) {
    if (strcmp(c_type, "int") == 0) return "int";
    if (strcmp(c_type, "float") == 0) return "float";
    if (strcmp(c_type, "char") == 0) return "str";
    return "object";
}

char* get_output_filename(char* input_name) {
    if (!input_name) return strdup("output.py");
    
    char* output_name = malloc(strlen(input_name) + 10);
    strcpy(output_name, input_name);
    
    // Remove extension if present
    char* dot = strrchr(output_name, '.');
    if (dot) *dot = '\0';
    
    // Add .py extension
    strcat(output_name, ".py");
    return output_name;
}

void open_output_file(char* filename) {
    output_filename = get_output_filename(filename);
    output_file = fopen(output_filename, "w");
    if (!output_file) {
        fprintf(stderr, "Error: Cannot create output file %s\n", output_filename);
        exit(1);
    }
    fprintf(output_file, "# Generated Python code from C-like source\n");
    fprintf(output_file, "# Input file: %s\n\n", filename ? filename : "stdin");
}

void close_output_file() {
    if (output_file && output_file != stdout) {
        fclose(output_file);
        printf("Python code generated successfully: %s\n", output_filename);
    }
    if (output_filename) {
        free(output_filename);
    }
}

int main(int argc, char* argv[]) {
    if (argc > 1) {
        // Input file provided
        input_filename = argv[1];
        yyin = fopen(input_filename, "r");
        if (!yyin) {
            fprintf(stderr, "Error: Cannot open input file %s\n", input_filename);
            return 1;
        }
        open_output_file(input_filename);
    } else {
        // Reading from stdin
        open_output_file(NULL);
    }
    
    int result = yyparse();
    
    if (argc > 1) {
        fclose(yyin);
    }
    close_output_file();
    
    return result;
}

int yyerror(char* s) {
    fprintf(stderr, "Error: %s\n", s);
    return 0;
}