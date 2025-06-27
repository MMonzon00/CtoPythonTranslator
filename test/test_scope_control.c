// Test de scope en estructuras de control
// Demuestra variables locales en if, while y funciones anidadas

int global_value = 100;

int processValue() {
    int function_local = 50;
    
    if (function_local > 0) {
        int if_local = 10;
        function_local = function_local + if_local;
    }
    
    while (function_local < global_value) {
        int while_local = 5;
        function_local = function_local + while_local;
    }
    
    return function_local;
}

void main() {
    int main_result;
    int main_counter = 0;
    
    main_result = processValue();
    
    if (main_result > global_value) {
        int condition_var = 20;
        main_result = main_result - condition_var;
    } else {
        int else_var = 30;
        main_result = main_result + else_var;
    }
    
    while (main_counter < 5) {
        int loop_var = 2;
        main_counter = main_counter + loop_var;
        global_value = global_value + loop_var;
    }
}
