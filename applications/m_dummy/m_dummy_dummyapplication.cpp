// m_dummy_dummyapplication.cpp                                       -*-C++-*-
module;

#include <print>

export module tasty:m_dummy.dummyapplication;
import :pars.dummy;

namespace tasty {
namespace m_dummy {

                        // =======================
                        // struct DummyApplication
                        // =======================

struct DummyApplication {
    // This 'struct' implements a utility namespace for functions that execute
    // the 'm_dummy' application.

    // CLASS METHODS
    static int exec(int argc, const char *const argv[]);
        // Execute an instance of the 'm_dummy' application with the specified
        // 'argc' and 'argv'.  Return '0' on success and a non-zero value
        // otherwise.
};

                        // -----------------------
                        // struct DummyApplication
                        // -----------------------

// CLASS METHODS
int DummyApplication::exec(int argc, const char *const argv[])
{
    for (int i = 0; i < argc; ++i)
        std::println("argv[{}]=\"{}\"", i, argv[i]);
        // std::cout << "argv[" << i << "]=\"" << argv[i] << "\"\n";


    pars::Dummy dummy("foo");
    std::println("dummy.name()=\"{}\"", dummy.name());
    return 0;
}

}  // close package namespace
}  // close enterprise namespace
