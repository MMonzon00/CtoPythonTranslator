// Test 3: Ciclos (Loops)
// Prueba while y for loops

int i, sum, count;
sum = 0;
count = 10;

// While loop simple
while (count > 0) {
    sum = sum + count;
    count = count - 1;
}

// While loop con condición compleja
i = 1;
while (i <= 5 && sum < 100) {
    sum = sum + i * 2;
    i = i + 1;
}


