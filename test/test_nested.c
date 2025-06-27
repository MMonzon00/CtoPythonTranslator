// Test 4: Estructuras anidadas
// Prueba if anidados, loops anidados y combinaciones

int x, y, z, result;
x = 5;
y = 3;
result = 0;

// If anidados
if (x > 0) {
    if (y > 0) {
        if (x > y) {
            result = x + y;
        } else {
            result = x - y;
        }
    } else {
        result = x;
    }
}

// While anidados
x = 3;
while (x > 0) {
    y = 2;
    while (y > 0) {
        result = result + x * y;
        y = y - 1;
    }
    x = x - 1;
}

// If dentro de while
z = 10;
while (z > 0) {
    if (z % 2 == 0) {
        result = result + z;
    } else {
        result = result - z;
    }
    z = z - 1;
}

