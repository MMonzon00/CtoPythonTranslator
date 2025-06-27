# C-to-Python Compiler Usage Guide

## Compilation

```bash
# Build the compiler
make

# Or manually:
bison -d parser.y
flex lexer.l
gcc -o compiler lex.yy.c parser.tab.c -lfl
```

## Usage

### Option 1: File Input/Output
```bash
# Translate input.c to input.py
./compiler input.c

# Example:
./compiler test.c
# Creates: test.py
```

### Option 2: Standard Input (creates output.py)
```bash
./compiler < input.c
# Creates: output.py
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
python3 test.py
```

## Supported Features

### ✅ Currently Implemented:
- Variable declarations (`int x, y, z;`)
- Constant declarations (`const int MAX_SIZE;`)
- **Array/Vector declarations (`int arr[10];`, `float data[5];`)**
- **Array element access and assignment (`arr[0] = 10;`, `x = arr[i];`)**
- Basic assignments (`x = 10;`)
- Arithmetic expressions (`x + y * z`)
- Comparison operations (`x > 5`, `x == y`)
- Logical operations (`x && y`, `!x`)
- If-else statements
- While loops
- For loops (translated to while loops)
- Nested structures with proper indentation
- Symbol table with type checking
- Error detection for undeclared variables and const assignments
- **Array bounds and type validation**

### 🔄 Automatic Translations:
- C operators → Python operators
- `&&` → `and`
- `||` → `or`
- `!` → `not`
- **C arrays → Python lists with appropriate initialization**
- **`int arr[n]` → `arr = [0] * n`**
- **`float arr[n]` → `arr = [0.0] * n`**
- **`char arr[n]` → `arr = [''] * n`**
- Proper indentation for nested blocks
- Type-appropriate default values

### ❌ Error Detection:
- Undeclared variable usage
- Assignment to constant variables
- **Array access on non-array variables**
- **Assignment to constant array elements**
- Syntax errors with helpful messages

## Testing

```bash
# Run predefined tests
make test

# Run generated Python code to verify
make run-test

# Clean all generated files
make clean
```

## File Structure
```
├── lexer.l          # Lexical analyzer
├── parser.y         # Parser with semantic actions
├── Makefile         # Build configuration
├── test.c           # Your test input
└── test.py          # Generated Python output
```