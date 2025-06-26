// Test 6: Detección de errores
// Este archivo contiene errores intencionalmente para probar la detección

int x, y;
const int MAX_VALUE;

// Asignación válida
x = 10;

// ERROR: Variable no declarada
undeclared_var = 5;

// ERROR: Asignación a constante
MAX_VALUE = 100;

// ERROR: Uso de variable no declarada en expresión
y = x + unknown_variable;

// Código válido después de errores
if (x > 5) {
    y = x * 2;
}
