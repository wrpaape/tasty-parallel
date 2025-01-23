// m_dummy_dummyapplication.t.cpp                                     -*-C++-*-
module;

#include <print>

module tasty:m_dummy.dummyapplication.t;

import :m_dummy.dummyapplication;

using namespace tasty;

int main(int argc, char *argv[])
{
    int exitStatus = 0;
    const int result = m_dummy::DummyApplication::exec(argc, argv);
    if (result != 0) {
        std::println(stderr, "exec() failed: (expected: {}, actual: {})",
                     0, result);
        exitStatus = 1;
    }
    return exitStatus;
}
