// Test 2: Estructuras condicionales
// Prueba if, if-else y operadores de comparación y lógicos

int x, y, result;
x = 10;
y = 5;

// If simple
if (x > y) {
    result = 1;
}

// If-else
if (x == y) {
    result = 0;
} else {
    result = -1;
}

// Operadores de comparación
if (x >= 10) {
    y = y + 1;
}

if (y <= 3) {
    x = x - 1;
}

if (x != y) {
    result = x + y;
}

// Operadores lógicos
if (x > 5 && y < 10) {
    result = 100;
}

if (x < 0 || y > 20) {
    result = 200;
}

if (!(x == 0)) {
    result = 300;
}
