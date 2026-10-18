#include <iostream>
#include <boost/multiprecision/cpp_int.hpp>

using namespace std;
using boost::multiprecision::cpp_int;

int main() {
    int sum = 0;
    cpp_int product = 1;

    for (int i = 1; i <= 1000; i++) {
        sum += i;
        product *= i;
    }

    cpp_int result = sum + product;

    cout << "sum = " << sum
         << "\nproduct = " << product
         << "\nresult = " << result << '\n';

    return 0;
}