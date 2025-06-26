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

x = 10;
y = x + 5;

if (x > 5) {
    z = x * y;
}

while (x > 0) {
    x = x - 1;
    y = y + x;
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
x = 10
y = x + 5
if x > 5:
    z = x * y
while x > 0:
    x = x - 1
    y = y + x
```

### Running the generated code:
```bash
python3 test.py
```

## Supported Features

### ✅ Currently Implemented:
- Variable declarations (`int x, y, z;`)
- Constant declarations (`const int MAX_SIZE;`)
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

### 🔄 Automatic Translations:
- C operators → Python operators
- `&&` → `and`
- `||` → `or`
- `!` → `not`
- Proper indentation for nested blocks
- Type-appropriate default values

### ❌ Error Detection:
- Undeclared variable usage
- Assignment to constant variables
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