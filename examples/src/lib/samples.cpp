#include "samples.hpp"
#include <math.h>

namespace learning {

double HoeffdingInequality(int N, double epsilon) {
    return 2 * pow(2.75, -2 * pow(epsilon, 2) * N);
}




}