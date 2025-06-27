CC = gcc
CFLAGS = -Wall -g

# Default target
all: compiler

# Generate parser files
parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

# Generate lexer file
lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

# Compile the compiler
compiler: lex.yy.c parser.tab.c
	$(CC) $(CFLAGS) -o compiler lex.yy.c parser.tab.c -lfl

# Create test files
test_basic.c:
	@echo "int x, y, z;" > test_basic.c
	@echo "float pi;" >> test_basic.c
	@echo "const char letter;" >> test_basic.c
	@echo "x = 10;" >> test_basic.c
	@echo "y = x + 5;" >> test_basic.c

test_advanced.c:
	@echo "int x, y;" > test_advanced.c
	@echo "x = 10;" >> test_advanced.c
	@echo "if (x > 5) {" >> test_advanced.c
	@echo "    y = x + 1;" >> test_advanced.c
	@echo "}" >> test_advanced.c
	@echo "while (x > 0) {" >> test_advanced.c
	@echo "    x = x - 1;" >> test_advanced.c
	@echo "}" >> test_advanced.c

# Test the compiler
test: compiler test_basic.c test_advanced.c
	@echo "=== Testing basic declarations ==="
	./compiler test_basic.c
	@echo "Generated: test_basic.py"
	@cat test_basic.py
	@echo ""
	@echo "=== Testing with expressions ==="
	./compiler test_advanced.c
	@echo "Generated: test_advanced.py"
	@cat test_advanced.py

# Run Python output to verify it works
run-test: test
	@echo ""
	@echo "=== Running generated Python code ==="
	@echo "--- test_basic.py ---"
	python3 test_basic.py
	@echo "--- test_advanced.py ---"
	python3 test_advanced.py

# Individual test targets
test-variables: compiler
	./compiler test/test_variables.c
	@echo "✅ Test de variables completado"

test-conditionals: compiler
	./compiler test/test_conditionals.c
	@echo "✅ Test de condicionales completado"

test-loops: compiler
	./compiler test/test_loops.c
	@echo "✅ Test de loops completado"

test-arrays: compiler
	./compiler test/test_arrays.c
	@echo "✅ Test de arrays completado"

test-nested: compiler
	./compiler test/test_nested.c
	@echo "✅ Test de estructuras anidadas completado"

test-types: compiler
	./compiler test/test_types.c
	@echo "✅ Test de tipos completado"

test-errors: compiler
	./compiler test/test_errors.c
	@echo "⚠️  Test de errores completado (se esperan errores)"

test-complete: compiler
	./compiler test/test_complete.c
	@echo "✅ Test completo completado"

# Execute all individual tests
test-all: test-variables test-conditionals test-loops test-nested test-types test-complete test-errors
	@echo ""
	@echo "=== TODOS LOS TESTS COMPLETADOS ==="

# Clean generated files
clean:
	rm -f compiler lex.yy.c parser.tab.c parser.tab.h 
	rm -f test_basic.c test_advanced.c test_basic.py test_advanced.py
	rm -f test/*.py
	rm -f *.py

.PHONY: all test run-test test-variables test-conditionals test-loops test-nested test-types test-errors test-complete test-all clean