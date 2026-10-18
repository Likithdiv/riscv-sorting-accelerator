extern "C" {
volatile int values[64] = {
    42, -7, 0, 19, -100, 5, 42, 3,
    -1, 88, 17, -42, 6, 99, -5, 12,
    64, -64, 2, 1, -2, 31, 15, -15,
    8, 7, -8, 23, 11, -11, 50, -50,
    2147483647, (-2147483647 - 1), 1000, -1000, 256, -256, 127, -128,
    16, -16, 9, -9, 4, -4, 0, 42,
    73, -73, 21, -21, 33, -33, 55, -55,
    90, -90, 13, -13, 28, -28, 1, -1
};

const int expected[64] = {
    (-2147483647 - 1), -1000, -256, -128, -100, -90, -73, -64,
    -55, -50, -42, -33, -28, -21, -16, -15,
    -13, -11, -9, -8, -7, -5, -4, -2,
    -1, -1, 0, 0, 1, 1, 2, 3,
    4, 5, 6, 7, 8, 9, 11, 12,
    13, 15, 16, 17, 19, 21, 23, 28,
    31, 33, 42, 42, 42, 50, 55, 64,
    73, 88, 90, 99, 127, 256, 1000, 2147483647
};

volatile unsigned result;
volatile unsigned sorted_count;
volatile unsigned failure_index;
}

int main() {
    result = 0;
    sorted_count = 0;
    failure_index = 64;

    // Insertion sort in ascending signed order.
    for(int i = 1; i < 64; i++) {
        int key = values[i];
        int j = i - 1;

        while(j >= 0 && values[j] > key) {
            values[j + 1] = values[j];
            j--;
        }
        values[j + 1] = key;
    }

   
    for(unsigned i = 0; i < 64; i++) {
        if(values[i] != expected[i]) {
            failure_index = i;
            return 1;
        }
        sorted_count++;
    }

    result = 1;
    return 0;
}
