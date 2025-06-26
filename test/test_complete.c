// Test 7: Test completo
// Combina todas las características implementadas

int counter, sum, max_value;
float average, total;
char grade;
const int LIMIT;

// Inicialización
counter = 0;
sum = 0;
max_value = 100;
total = 0.0;
grade = 'A';

// Ciclo principal con condiciones anidadas
while (counter < 10) {
    if (counter % 2 == 0) {
        sum = sum + counter;
        if (sum > 20) {
            if (counter > 5) {
                total = total + sum * 1.5;
            } else {
                total = total + sum;
            }
        }
    } else {
        sum = sum - counter;
    }
    
    counter = counter + 1;
}

// Cálculo de promedio
if (counter > 0) {
    average = total / counter;
} else {
    average = 0.0;
}

// Asignación de calificación basada en promedio
if (average >= 90.0) {
    grade = 'A';
} else {
    if (average >= 80.0) {
        grade = 'B';
    } else {
        if (average >= 70.0) {
            grade = 'C';
        } else {
            grade = 'F';
        }
    }
}

// Ciclo for para procesamiento final
for (counter = 1; counter <= 5; counter = counter + 1) {
    if (counter < 3 && grade == 'A') {
        sum = sum + counter * 10;
    }
}
