# Tests para el Traductor C a Python

Esta carpeta contiene tests exhaustivos para verificar todas las características implementadas en el traductor.

## Archivos de Test

### 1. `test_variables.c`
- **Propósito**: Prueba declaraciones de variables y constantes
- **Características**: 
  - Declaraciones múltiples (`int x, y, z;`)
  - Diferentes tipos (`int`, `float`, `char`)
  - Constantes (`const`)
  - Inicializaciones con valores

### 2. `test_conditionals.c`
- **Propósito**: Prueba estructuras condicionales
- **Características**:
  - `if` simple
  - `if-else`
  - Operadores de comparación (`>`, `<`, `>=`, `<=`, `==`, `!=`)
  - Operadores lógicos (`&&`, `||`, `!`)

### 3. `test_loops.c`
- **Propósito**: Prueba ciclos
- **Características**:
  - `while` loops
  - `for` loops (convertidos a `while`)
  - Condiciones complejas en loops

### 4. `test_nested.c`
- **Propósito**: Prueba estructuras anidadas
- **Características**:
  - `if` anidados
  - `while` anidados
  - Combinaciones de `if` dentro de `while`
  - `for` dentro de `if`

### 5. `test_types.c`
- **Propósito**: Prueba comprobación de tipos
- **Características**:
  - Diferentes tipos de datos
  - Operaciones aritméticas
  - Comparaciones entre tipos
  - Expresiones complejas

### 6. `test_errors.c`
- **Propósito**: Prueba detección de errores
- **Características**:
  - Variables no declaradas
  - Asignación a constantes
  - Uso de variables inexistentes

### 7. `test_complete.c`
- **Propósito**: Test integral combinando todas las características
- **Características**: Todas las anteriores en un programa complejo

## Cómo Ejecutar los Tests

### Opción 1: Makefile
```bash
# Ejecutar test específico
make test-variables
make test-conditionals
make test-loops
make test-nested
make test-types
make test-errors
make test-complete

# Ejecutar todos los tests
make test-all

# Limpiar archivos generados
make clean
```

### Opción 2: Manual
```bash
# Desde el directorio principal
./compiler test/test_variables.c
python3 test_variables.py

./compiler test/test_conditionals.c
python3 test_conditionals.py

# ... etc para cada test
```

## Resultados Esperados

### ✅ Tests que deben ejecutar sin errores:
- `test_variables.c`
- `test_conditionals.c`
- `test_loops.c`
- `test_nested.c`
- `test_types.c`
- `test_complete.c`

### ⚠️ Test que debe mostrar errores:
- `test_errors.c` - Debe mostrar errores de compilación intencionalmente

## Interpretación de Resultados

- **✅ Traducción exitosa**: El archivo `.py` se genera correctamente
- **✅ Ejecución exitosa**: El código Python se ejecuta sin errores
- **❌ Error de traducción**: Problema en el compilador
- **❌ Error de ejecución**: El Python generado tiene errores de sintaxis

