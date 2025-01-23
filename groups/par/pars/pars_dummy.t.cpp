// pars_dummy.t.cpp                                                   -*-C++-*-
module;

#include <print>
#include <string>

module tasty:pars.dummy.t;

import :pars.dummy;

using namespace tasty;

int main(int argc, char *argv[])
{
    int exitStatus = 0;
    const std::string expectedName("foo");
    const pars::Dummy dummy(expectedName);
    const std::string& actualName = dummy.name();
    if (expectedName != actualName) {
        std::println(stderr, "name() failed: (expected: {}, actual: {})",
                     expectedName, actualName);
        exitStatus = 1;
    }
    return exitStatus;
}
