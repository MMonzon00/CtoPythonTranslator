// Arrays 2D  
int matrix[3][4];           
float image[2][3];          
char board[4][4];           

// Arrays 3D
int cube[2][3][4];          
float rgb[2][2][3];         
char pages[2][3][5];        

int i, j, k, l;
int x, y, z, w;
float value, sum, avg;
char ch, result_char;


matrix[0][0] = 1;
matrix[0][1] = 2;
matrix[0][2] = 3;
matrix[0][3] = 4;
matrix[1][0] = 5;
matrix[1][1] = 6;
matrix[1][2] = 7;
matrix[1][3] = 8;
matrix[2][0] = 9;
matrix[2][1] = 10;
matrix[2][2] = 11;
matrix[2][3] = 12;

image[0][0] = 0.1;
image[0][1] = 0.2;
image[0][2] = 0.3;
image[1][0] = 1.1;
image[1][1] = 1.2;
image[1][2] = 1.3;

board[0][0] = 'X';
board[0][3] = 'O';
board[3][0] = 'O';
board[3][3] = 'X';

i = 1;
j = 2;
k = 0;
l = 1;

x = matrix[i][j];
value = image[i][k];
ch = board[i][i];

// Arrays 2D
matrix[i][j] = matrix[j][i] + 10;
image[k][l] = image[i][j] + 0.5;
board[i][k] = board[j][l];

sum = matrix[0][0] + matrix[0][1] + matrix[1][0] + matrix[1][1];

