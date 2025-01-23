// pars_dummy_subordinate.t.cpp                                       -*-C++-*-
module;

#include <print>
#include <string>

module tasty:pars.dummy.subordinate.t;

import :pars.dummy.subordinate;

using namespace tasty;

int main(int argc, char *argv[])
{
    int exitStatus = 0;
    const std::string expectedName("bar");
    const pars::Dummy_Subordinate dummy(expectedName);
    const std::string& actualName = dummy.name();
    if (expectedName != actualName) {
        std::println(stderr, "name() failed: (expected: {}, actual: {})",
                     expectedName, actualName);
        exitStatus = 1;
    }
    return exitStatus;
}
