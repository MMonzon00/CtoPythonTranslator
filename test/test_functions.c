// Test de funciones básicas
// Prueba declaración, llamada y retorno de funciones sin parámetros

int getValue() {
    return 42;
}

float getPI() {
    return 3.14159;
}

void showMessage() {
    return;
}

void main() {
    int result;
    float pi_value;
    
    result = getValue();
    pi_value = getPI();
    showMessage();
}
