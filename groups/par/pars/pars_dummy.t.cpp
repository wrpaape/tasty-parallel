// pars_dummy.t.cpp                                                   -*-C++-*-
module;

#include <string>

#include <gtest/gtest.h>

module tasty:pars.dummy.t;

import :pars.dummy;

namespace {
using namespace tasty;

// TESTS
TEST(DummyTest, NameReturnsNamePassedAtConstruction)
{
    // GIVEN a 'Dummy' object constructed with a name,
    //
    // WHEN the 'name()' method is called,
    //
    // THEN a non-modifiable reference to the name's value is returned.

    const std::string expectedName("foo");
    const pars::Dummy dummy(expectedName);

    const std::string& actualName = dummy.name();

    EXPECT_EQ(expectedName, actualName);
}

}  // close unnamed namespace
