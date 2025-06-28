# C-to-Python Compiler

Un traductor de C a Python utilizando generacion de analizadores lexicos con Flex y generador de analizador semantico con Bison/Yacc.

## Instalación

```bash
git clone https://github.com/MMonzon00/CtoPythonTranslator.git
cd CtoPythonTranslator
```

## Requisitos

- GCC (Compilador de C)
- Flex (Generador de analizador léxico)
- Bison (Generador de analizador sintáctico)
- Make
- Python 3 (para ejecutar el código generado)

### Instalación Ubuntu/Debian:
```bash
sudo apt-get install gcc flex bison make
```

### Instalación macOS:
```bash
brew install flex bison make
```

## Compilacion

```bash
# Build the compiler
make
```

## Uso

### Entrada estándar (genera: output.py)
```bash
./compiler < test/test_*.c
# Salida: test_*.py
```


## Ejemplo de Traducción

### Código C de entrada (test/test_complete.c):
```c
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

 y + numbers[x];
```

### Código Python generado (test/test_complete.py):
```python
# Generated Python code from C-like source
# Input file: test/test_complete.c

counter = 0  # int
sum = 0  # int
max_value = 0  # int
average = 0.0  # float
total = 0.0  # float
grade = ''  # char
# Constant: LIMIT
LIMIT = 0  # int
counter = 0
sum = 0
max_value = 100
total = 0.000000
grade = 'A'
while counter < 10:
    if counter % 2 == 0:
        sum = sum + counter
        if sum > 20:
            if counter > 5:
                total = total + sum * 1.500000
            else:
                total = total + sum
    else:
        sum = sum - counter
    counter = counter + 1

if counter > 0:
    average = total / counter
else:
    average = 0.000000

if average >= 90.000000:
    grade = 'A'
else:

    if average >= 80.000000:
        grade = 'B'
    else:

        if average >= 70.000000:
            grade = 'C'
        else:
            grade = 'F'

```

### Ejecutar el código generado:
```bash
python3 output.py
```


## Limpiar archivos generados:
```bash
make clean
```

## Características

### Tipos de datos soportados:
- `int`, `float`, `char`
- Variables y constantes
- Arrays 1D, 2D, 3D y multidimensionales

### Estructuras de control:
- `if/else` statements
- `while` loops
- Estructuras anidadas

### Funciones:
- Declaración y llamada de funciones sin parámetros
- Funciones con retorno de valor
- Función `main()`

### Gestión avanzada:
- Scope management (variables globales y locales)
- Detección de errores (variables no declaradas, asignación a constantes)
- Comentarios (`//`)

## Estructura del Proyecto
```
├── lexer.l          # Generador de analizador lexico
├── parser.y         # Generador de analizador semantico
├── Makefile         # Archivo de configuracion
├── /test            # tests incluidos.
```