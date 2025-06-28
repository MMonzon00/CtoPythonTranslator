# Guia de uso: C-to-Python Compiler 

## Compilacion

```bash
# Build the compiler
make
```

## Usage

### Standard Input (genera: output.py)
```bash
./compiler < test/test_*.c
# Salida: output.py
```

## Example Translation

### Input C-like code (test.c):
```c
int x, y, z;
float pi;
const int MAX_SIZE;
int numbers[5];
float values[3];

x = 10;
y = x + 5;
numbers[0] = 100;
numbers[1] = x + y;
values[2] = 3.14;

if (x > 5) {
    z = x * y + numbers[0];
}

while (x > 0) {
    x = x - 1;
    y = y + numbers[x];
}
```

### Generated Python code (test.py):
```python
# Generated Python code from C-like source
# Input file: test.c

x = 0  # int
y = 0  # int
z = 0  # int
pi = 0.0  # float
# Constant: MAX_SIZE
MAX_SIZE = 0  # int
numbers = [0] * 5  # int array[5]
values = [0.0] * 3  # float array[3]
x = 10
y = x + 5
numbers[0] = 100
numbers[1] = x + y
values[2] = 3.140000
if x > 5:
    z = x * y + numbers[0]
while x > 0:
    x = x - 1
    y = y + numbers[x]
```

### Running the generated code:
```bash
python3 output.py
```

## Testing

```bash
# Limpiar todos los archivos generados por el makefile
make clean
```

## File Structure
```
├── lexer.l          # Generador de analizador lexico
├── parser.y         # Generador de analizador semantico
├── Makefile         # Archivo de configuracion
├── /test            # tests incluidos.
└── output.py        # Archivo de salida del compilador.
```
