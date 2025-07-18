%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct symbol {
    char* name;
    char* type;
    int is_const;
    int is_array;
    int dimensions;         // Number of dimensions (0 = not array, 1 = 1D, 2 = 2D, etc.)
    int* sizes;            // Array to store sizes for each dimension
    int scope_level;       // 0 = global, 1+ = function level
    struct symbol* next;
} symbol_t;

typedef struct scope {
    symbol_t* symbols;     // Local symbol table for this scope
    int level;            // Scope level (0 = global, 1+ = function)
    struct scope* parent; // Parent scope
} scope_t;

symbol_t* symbol_table = NULL;  // Global symbol table
scope_t* current_scope = NULL;  // Current scope
int scope_level = 0;           // Current scope level
int indent_level = 0;
int in_control_structure = 0;  // Flag to track if we're inside if/while/for
int in_function = 0;           // Flag to track if we're inside any function
int last_was_if_statement = 0; // Flag to track if the last statement was an if
FILE* output_file = NULL;
char* input_filename = NULL;
char* output_filename = NULL;

void add_symbol(char* name, char* type, int is_const, int dimensions, int* sizes);
symbol_t* find_symbol(char* name);
void print_indent();
void generate_python_declaration(char* type, char* name, int is_const, int dimensions, int* sizes);
char* translate_type(char* c_type);
char* get_output_filename(char* input_name);
void open_output_file(char* filename);
void close_output_file();
char* generate_multidim_access(char* name, char* indices[], int dim_count);
char* generate_multidim_init(char* type, int dimensions, int* sizes);
void enter_scope();
void exit_scope();
symbol_t* find_symbol_in_scope(char* name, int level);
void add_symbol_to_current_scope(char* name, char* type, int is_const, int dimensions, int* sizes);

int yylex(void);
int yyerror(char *s);
extern FILE* yyin;
%}

%union {
    int ival;
    float fval;
    char cval;
    char* sval;
    struct {
        int* sizes;
        int count;
    } dimensions;
}

%token <ival> NUMBER
%token <fval> FLOAT_NUM
%token <cval> CHAR_LITERAL
%token <sval> ID STRING_LITERAL
%token INT FLOAT CHAR CONST VOID
%token IF ELSE WHILE BREAK CONTINUE RETURN
%token PLUS MINUS MULTIPLY DIVIDE MODULO
%token ASSIGN EQ NE LT LE GT GE AND OR NOT
%token LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET
%token SEMICOLON COMMA

%type <sval> type idlist expression term factor
%type <dimensions> array_dimensions
%type <sval> index_list

%left OR
%left AND
%left EQ NE
%left LT LE GT GE
%left PLUS MINUS
%left MULTIPLY DIVIDE MODULO
%right NOT
%right UMINUS
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

program:
    /* empty */
    | program declaration
    | program statement
    | program function_definition
    ;

function_definition:
    VOID ID LPAREN RPAREN {
        if (strcmp($2, "main") == 0) {
            in_function = 1;
            print_indent();
            fprintf(output_file, "def %s():\n", $2);
        } else {
            print_indent();
            fprintf(output_file, "def %s():\n", $2);
        }
        indent_level++;
        enter_scope();
        free($2);
    } compound_statement {
        exit_scope();
        indent_level--;
        in_function = 0;
        fprintf(output_file, "\n");
    }
    | type ID LPAREN RPAREN {
        if (strcmp($2, "main") == 0) {
            in_function = 1;
            print_indent();
            fprintf(output_file, "def %s():\n", $2);
        } else {
            print_indent();
            fprintf(output_file, "def %s():\n", $2);
        }
        indent_level++;
        enter_scope();
        free($1);
        free($2);
    } compound_statement {
        exit_scope();
        indent_level--;
        in_function = 0;
        fprintf(output_file, "\n");
    }
    ;

declaration:
    type idlist SEMICOLON {
        char* ids = $2;
        char* token = strtok(ids, ",");
        while (token != NULL) {
            if (in_function) {
                add_symbol_to_current_scope(token, $1, 0, 0, NULL);
            } else {
                add_symbol(token, $1, 0, 0, NULL);
            }
            generate_python_declaration($1, token, 0, 0, NULL);
            token = strtok(NULL, ",");
        }
        free($1);
        free($2);
        last_was_if_statement = 0;  // Resetear la flag después de declaraciones
    }
    | CONST type idlist SEMICOLON {
        char* ids = $3;
        char* token = strtok(ids, ",");
        while (token != NULL) {
            if (in_function) {
                add_symbol_to_current_scope(token, $2, 1, 0, NULL);
            } else {
                add_symbol(token, $2, 1, 0, NULL);
            }
            generate_python_declaration($2, token, 1, 0, NULL);
            token = strtok(NULL, ",");
        }
        free($2);
        free($3);
    }
    | type ID ASSIGN expression SEMICOLON {
        if (in_function) {
            add_symbol_to_current_scope($2, $1, 0, 0, NULL);
        } else {
            add_symbol($2, $1, 0, 0, NULL);
        }
        print_indent();
        fprintf(output_file, "%s = %s  # %s\n", $2, $4, $1);
        free($1);
        free($2);
        free($4);
    }
    | CONST type ID ASSIGN expression SEMICOLON {
        if (in_function) {
            add_symbol_to_current_scope($3, $2, 1, 0, NULL);
        } else {
            add_symbol($3, $2, 1, 0, NULL);
        }
        print_indent();
        fprintf(output_file, "# Constant: %s\n", $3);
        print_indent();
        fprintf(output_file, "%s = %s  # %s\n", $3, $5, $2);
        free($2);
        free($3);
        free($5);
    }
    | type ID array_dimensions SEMICOLON {
        if (in_function) {
            add_symbol_to_current_scope($2, $1, 0, $3.count, $3.sizes);
        } else {
            add_symbol($2, $1, 0, $3.count, $3.sizes);
        }
        generate_python_declaration($1, $2, 0, $3.count, $3.sizes);
        free($1);
        free($2);
        free($3.sizes);
    }
    | CONST type ID array_dimensions SEMICOLON {
        if (in_function) {
            add_symbol_to_current_scope($3, $2, 1, $4.count, $4.sizes);
        } else {
            add_symbol($3, $2, 1, $4.count, $4.sizes);
        }
        generate_python_declaration($2, $3, 1, $4.count, $4.sizes);
        free($2);
        free($3);
        free($4.sizes);
    }
    | type ID array_dimensions ASSIGN LBRACE expression RBRACE SEMICOLON {
        if (in_function) {
            add_symbol_to_current_scope($2, $1, 0, $3.count, $3.sizes);
        } else {
            add_symbol($2, $1, 0, $3.count, $3.sizes);
        }
        print_indent();
        char* init_code = generate_multidim_init($1, $3.count, $3.sizes);
        fprintf(output_file, "%s = %s  # %s array", $2, init_code, $1);
        for (int i = 0; i < $3.count; i++) {
            fprintf(output_file, "[%d]", $3.sizes[i]);
        }
        fprintf(output_file, "\n");
        free($1);
        free($2);
        free($6);
        free(init_code);
        free($3.sizes);
    }
    | CONST type ID array_dimensions ASSIGN LBRACE expression RBRACE SEMICOLON {
        if (in_function) {
            add_symbol_to_current_scope($3, $2, 1, $4.count, $4.sizes);
        } else {
            add_symbol($3, $2, 1, $4.count, $4.sizes);
        }
        print_indent();
        fprintf(output_file, "# Constant array: %s\n", $3);
        print_indent();
        char* init_code = generate_multidim_init($2, $4.count, $4.sizes);
        fprintf(output_file, "%s = %s  # %s array", $3, init_code, $2);
        for (int i = 0; i < $4.count; i++) {
            fprintf(output_file, "[%d]", $4.sizes[i]);
        }
        fprintf(output_file, "\n");
        free($2);
        free($3);
        free($7);
        free(init_code);
        free($4.sizes);
    }
    ;

type:
    INT     { $$ = strdup("int"); }
    | FLOAT { $$ = strdup("float"); }
    | CHAR  { $$ = strdup("char"); }
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

array_dimensions:
    LBRACKET NUMBER RBRACKET {
        $$.count = 1;
        $$.sizes = malloc(sizeof(int));
        $$.sizes[0] = $2;
    }
    | array_dimensions LBRACKET NUMBER RBRACKET {
        $$.count = $1.count + 1;
        $$.sizes = realloc($1.sizes, $$.count * sizeof(int));
        $$.sizes[$$.count - 1] = $3;
    }
    ;

index_list:
    LBRACKET expression RBRACKET {
        $$ = malloc(strlen($2) + 3);
        sprintf($$, "[%s]", $2);
        free($2);
    }
    | index_list LBRACKET expression RBRACKET {
        char* result = malloc(strlen($1) + strlen($3) + 4);
        sprintf(result, "%s[%s]", $1, $3);
        free($1);
        free($3);
        $$ = result;
    }
    ;

statement:
    assignment_statement
    | if_statement
    | while_statement
    | compound_statement
    | expression_statement
    | return_statement
    ;

if_statement:
    if_header statement %prec LOWER_THAN_ELSE {
        // if_header ya escribió "if condition:", ahora solo decrementar indentación
        indent_level--;
        last_was_if_statement = 1;  // Marcar que acabamos de procesar un if
    }
    | if_header statement else_header statement {
        // if_header escribió "if condition:", statement se procesó con indentación
        // else_header escribió "else:", segundo statement se procesó con indentación
        indent_level--;
        last_was_if_statement = 1;  // Marcar que acabamos de procesar un if-else
    }
    ;

if_header:
    IF LPAREN expression RPAREN {
        // Si el statement anterior fue un if, agregar una línea vacía para separación
        if (last_was_if_statement) {
            fprintf(output_file, "\n");
        }
        print_indent();
        fprintf(output_file, "if %s:\n", $3);
        indent_level++;
        free($3);
    }
    ;

else_header:
    ELSE {
        indent_level--;
        print_indent();
        fprintf(output_file, "else:\n");
        indent_level++;
    }
    ;

return_statement:
    RETURN SEMICOLON {
        print_indent();
        fprintf(output_file, "return\n");
    }
    | RETURN expression SEMICOLON {
        print_indent();
        fprintf(output_file, "return %s\n", $2);
        free($2);
    }
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
    | ID index_list ASSIGN expression SEMICOLON {
        symbol_t* sym = find_symbol($1);
        if (sym) {
            if (sym->is_const) {
                yyerror("Cannot assign to constant array element");
            } else if (sym->dimensions == 0) {
                yyerror("Variable is not an array");
            } else {
                print_indent();
                fprintf(output_file, "%s%s = %s\n", $1, $2, $4);
            }
        } else {
            yyerror("Undeclared variable");
        }
        free($1);
        free($2);
        free($4);
    }
    ;



while_statement:
    WHILE LPAREN expression RPAREN {
        print_indent();
        fprintf(output_file, "while %s:\n", $3);
        indent_level++;
        free($3);
    } statement {
        indent_level--;
    }
    ;

compound_statement:
    LBRACE { 
        // No incrementar indentación aquí, ya se maneja en las estructuras de control
    } statement_list RBRACE {
        // No decrementar indentación aquí
    }
    ;

statement_list:
    /* empty */
    | statement_list statement
    | statement_list declaration
    ;

expression_statement:
    expression SEMICOLON {
        print_indent();
        fprintf(output_file, "%s\n", $1);
        last_was_if_statement = 0;  // Resetear la flag
        free($1);
    }
    | SEMICOLON /* empty statement */ {
        last_was_if_statement = 0;  // Resetear la flag
    }
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
    | expression MODULO term {
        char* result = malloc(strlen($1) + strlen($3) + 4);
        sprintf(result, "%s %% %s", $1, $3);
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
        free($1);
    }
    | ID LPAREN RPAREN {
        char* result = malloc(strlen($1) + 3);
        sprintf(result, "%s()", $1);
        free($1);
        $$ = result;
    }
    | ID index_list {
        symbol_t* sym = find_symbol($1);
        if (!sym) {
            yyerror("Undeclared variable");
        } else if (sym->dimensions == 0) {
            yyerror("Variable is not an array");
        }
        char* result = malloc(strlen($1) + strlen($2) + 1);
        sprintf(result, "%s%s", $1, $2);
        free($1);
        free($2);
        $$ = result;
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

void add_symbol(char* name, char* type, int is_const, int dimensions, int* sizes) {
    symbol_t* new_symbol = malloc(sizeof(symbol_t));
    new_symbol->name = strdup(name);
    new_symbol->type = strdup(type);
    new_symbol->is_const = is_const;
    new_symbol->is_array = (dimensions > 0);
    new_symbol->dimensions = dimensions;
    new_symbol->scope_level = 0;  // Global scope
    
    if (dimensions > 0) {
        new_symbol->sizes = malloc(dimensions * sizeof(int));
        for (int i = 0; i < dimensions; i++) {
            new_symbol->sizes[i] = sizes[i];
        }
    } else {
        new_symbol->sizes = NULL;
    }
    
    new_symbol->scope_level = 0;  // Global scope
    new_symbol->next = symbol_table;
    symbol_table = new_symbol;
}

symbol_t* find_symbol(char* name) {
    // First check current scope and parent scopes
    if (current_scope) {
        symbol_t* current = current_scope->symbols;
        while (current) {
            if (strcmp(current->name, name) == 0) {
                return current;
            }
            current = current->next;
        }
        
        // Check parent scopes
        scope_t* parent = current_scope->parent;
        while (parent) {
            current = parent->symbols;
            while (current) {
                if (strcmp(current->name, name) == 0) {
                    return current;
                }
                current = current->next;
            }
            parent = parent->parent;
        }
    }
    
    // Finally check global scope
    symbol_t* current = symbol_table;
    while (current) {
        if (strcmp(current->name, name) == 0) {
            return current;
        }
        current = current->next;
    }
    return NULL;
}

void enter_scope() {
    scope_t* new_scope = malloc(sizeof(scope_t));
    new_scope->symbols = NULL;
    new_scope->level = scope_level++;
    new_scope->parent = current_scope;
    current_scope = new_scope;
}

void exit_scope() {
    if (current_scope) {
        scope_t* old_scope = current_scope;
        current_scope = current_scope->parent;
        scope_level--;
        
        // Free the symbols in the old scope
        symbol_t* current = old_scope->symbols;
        while (current) {
            symbol_t* temp = current;
            current = current->next;
            free(temp->name);
            free(temp->type);
            if (temp->sizes) free(temp->sizes);
            free(temp);
        }
        free(old_scope);
    }
}

void add_symbol_to_current_scope(char* name, char* type, int is_const, int dimensions, int* sizes) {
    symbol_t* new_symbol = malloc(sizeof(symbol_t));
    new_symbol->name = strdup(name);
    new_symbol->type = strdup(type);
    new_symbol->is_const = is_const;
    new_symbol->is_array = (dimensions > 0);
    new_symbol->dimensions = dimensions;
    new_symbol->scope_level = (current_scope ? current_scope->level : 0);
    
    if (dimensions > 0) {
        new_symbol->sizes = malloc(dimensions * sizeof(int));
        for (int i = 0; i < dimensions; i++) {
            new_symbol->sizes[i] = sizes[i];
        }
    } else {
        new_symbol->sizes = NULL;
    }
    
    if (current_scope) {
        new_symbol->next = current_scope->symbols;
        current_scope->symbols = new_symbol;
    } else {
        // Fall back to global scope if no current scope
        new_symbol->next = symbol_table;
        symbol_table = new_symbol;
    }
}

void print_indent() {
    for (int i = 0; i < indent_level; i++) {
        fprintf(output_file, "    ");
    }
}

void generate_python_declaration(char* type, char* name, int is_const, int dimensions, int* sizes) {
    print_indent();
    if (is_const) {
        fprintf(output_file, "# Constant%s: %s\n", (dimensions > 0) ? " array" : "", name);
        print_indent();
    }
    
    if (dimensions > 0) {
        char* init_code = generate_multidim_init(type, dimensions, sizes);
        fprintf(output_file, "%s = %s  # %s array", name, init_code, type);
        for (int i = 0; i < dimensions; i++) {
            fprintf(output_file, "[%d]", sizes[i]);
        }
        fprintf(output_file, "\n");
        free(init_code);
    } else {
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
}

char* translate_type(char* c_type) {
    if (strcmp(c_type, "int") == 0) return "int";
    if (strcmp(c_type, "float") == 0) return "float";
    if (strcmp(c_type, "char") == 0) return "str";
    return "object";
}

char* generate_multidim_init(char* type, int dimensions, int* sizes) {
    if (dimensions == 0) {
        return strdup("None");
    }
    
    char* default_value;
    if (strcmp(type, "int") == 0) {
        default_value = "0";
    } else if (strcmp(type, "float") == 0) {
        default_value = "0.0";
    } else if (strcmp(type, "char") == 0) {
        default_value = "''";
    } else {
        default_value = "None";
    }
    
    char* result = malloc(2000);  // Buffer larger for complex nested structures
    
    if (dimensions == 1) {
        sprintf(result, "[%s] * %d", default_value, sizes[0]);
    } else if (dimensions == 2) {
        sprintf(result, "[[%s] * %d for _ in range(%d)]", default_value, sizes[1], sizes[0]);
    } else if (dimensions == 3) {
        sprintf(result, "[[[%s] * %d for _ in range(%d)] for _ in range(%d)]", 
                default_value, sizes[2], sizes[1], sizes[0]);
    } else if (dimensions == 4) {
        sprintf(result, "[[[[%s] * %d for _ in range(%d)] for _ in range(%d)] for _ in range(%d)]", 
                default_value, sizes[3], sizes[2], sizes[1], sizes[0]);
    } else {
        // For higher dimensions (5+), create a more complex nested structure
        strcpy(result, "[");
        for (int i = 1; i < dimensions; i++) {
            strcat(result, "[");
        }
        strcat(result, default_value);
        
        for (int i = dimensions - 1; i >= 0; i--) {
            char temp[100];
            sprintf(temp, "] * %d", sizes[i]);
            strcat(result, temp);
            if (i > 0) {
                sprintf(temp, " for _ in range(%d)", sizes[i-1]);
                strcat(result, temp);
            }
            if (i > 0) {
                strcat(result, "]");
            }
        }
    }
    
    return result;
}

char* generate_multidim_access(char* name, char* indices[], int dim_count) {
    int total_len = strlen(name) + 1;
    for (int i = 0; i < dim_count; i++) {
        total_len += strlen(indices[i]) + 3; // for [index]
    }
    
    char* result = malloc(total_len);
    strcpy(result, name);
    
    for (int i = 0; i < dim_count; i++) {
        strcat(result, "[");
        strcat(result, indices[i]);
        strcat(result, "]");
    }
    
    return result;
}

char* get_output_filename(char* input_name) {
    if (!input_name) return strdup("output.py");
    
    char* output_name = malloc(strlen(input_name) + 10);
    strcpy(output_name, input_name);
    
    char* dot = strrchr(output_name, '.');
    if (dot) *dot = '\0';
    
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
        input_filename = argv[1];
        yyin = fopen(input_filename, "r");
        if (!yyin) {
            fprintf(stderr, "Error: Cannot open input file %s\n", input_filename);
            return 1;
        }
        open_output_file(input_filename);
    } else {
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