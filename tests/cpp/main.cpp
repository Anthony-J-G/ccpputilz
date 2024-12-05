#include <iostream>


#undef FOUND_THE_FIRST
#define UNLOCK_THE_FINAL


int main() {
    printf("[Running C++ Application]");

#ifdef FOUND_THE_FIRST
    Prelude();
    Function1();
    Function2();
    Function3();
    Function4();
    Function5();
    Function6();
    Function7();
    Function8();
    Function9();
    Function10();
#endif

#ifdef FOUND_THE_FINAL
    Function11();
#endif

    return EXIT_SUCCESS;
}