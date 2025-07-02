//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.

#include <stdio.h>
#include <stdlib.h>

int main(int argc, const char* argv[]) {
    fprintf(stderr, "All your %s are belong to us\n", "codebase");

    printf("Run `zig build test` to run the tests\n");

    return EXIT_SUCCESS;
}