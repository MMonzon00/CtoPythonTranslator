// Test de scope management
// Prueba variables globales, locales, constantes y acceso entre scopes

int global_counter = 0;
float global_ratio = 1.5;
const int MAX_LIMIT = 100;
const float PI_CONSTANT = 3.14159;

int calculateSum() {
    int local_a = 10;
    int local_b = 20;
    int local_result;
    const int LOCAL_MULTIPLIER = 2;
    
    local_result = local_a + local_b;
    local_result = local_result * LOCAL_MULTIPLIER;
    global_counter = global_counter + 1;
    
    return local_result;
}

float calculateAverage() {
    float local_sum = 100.0;
    float local_count = 4.0;
    float local_avg;
    
    local_avg = local_sum / local_count;
    global_ratio = local_avg * PI_CONSTANT;
    
    return local_avg;
}

void updateGlobals() {
    int local_increment = 5;
    float local_factor = 2.0;
    
    global_counter = global_counter + local_increment;
    global_ratio = global_ratio * local_factor;
    
    if (global_counter < MAX_LIMIT) {
        int nested_value = 15;
        global_counter = global_counter + nested_value;
    }
}

void main() {
    int main_sum;
    float main_average;
    int main_iterations = 3;
    const int MAIN_CONSTANT = 50;
    
    main_sum = calculateSum();
    main_average = calculateAverage();
    updateGlobals();
    
    global_counter = global_counter + main_iterations + MAIN_CONSTANT;
    
    while (global_counter > 0) {
        int loop_decrement = 10;
        global_counter = global_counter - loop_decrement;
        
        if (global_counter < MAIN_CONSTANT) {
            int condition_value = 5;
            global_counter = global_counter + condition_value;
        }
    }
}
