// m_dummy_dummyapplication.t.cpp                                     -*-C++-*-
module;

#include <array>

#include <gtest/gtest.h>

module tasty:m_dummy.dummyapplication.t;

import :m_dummy.dummyapplication;

namespace {
using namespace tasty;

// TESTS
TEST(DummyApplicationTest, ExecSucceedsWithWellFormedArgs)
{
    // WHEN the 'exec()' method is called with a non-negative 'argc' and
    // 'argv', a null-terminated list of 'argc' null-terminated strings,
    //
    // THEN '0' is returned.

    const char *const argv[] = { "foo", "bar", nullptr };
    const int         argc   = std::size(argv) - 1;
    const int         result = m_dummy::DummyApplication::exec(argc, argv);

    EXPECT_EQ(0, result);
}

}  // close unnamed namespace
