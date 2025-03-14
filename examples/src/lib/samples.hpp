#pragma once


namespace learning {

/*
    Given some sample size N and tolerance epsilon, return the probability that the difference
    between the underlying sample probability and population probability is greater than epsilon.

    The inequality implies that as the sample size N increases, it becomes exponentially unlikely that the sample probability will deviate from the population probability by more than our
    tolerance epsilon.
*/
double HoeffdingInequality(int N, double epsilon);



} // End sample