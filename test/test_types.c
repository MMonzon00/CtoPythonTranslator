// Test 5: Comprobación de tipos
// Prueba diferentes tipos de datos y operaciones

int integer_var;
float float_var;
char char_var;

// Asignaciones válidas
integer_var = 42;
float_var = 3.14159;
char_var = 'X';

// Operaciones aritméticas
integer_var = integer_var + 10;
float_var = float_var * 2.5;

// Comparaciones entre tipos
if (integer_var > 50) {
    float_var = float_var + 1.0;
}

if (float_var < 10.0) {
    integer_var = integer_var - 5;
}

// Expresiones complejas
integer_var = integer_var + float_var;
float_var = integer_var * 1.5 + float_var / 2.0;
