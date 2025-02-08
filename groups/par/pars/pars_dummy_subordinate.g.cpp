// pars_dummy_subordinate.g.cpp                                       -*-C++-*-
module;

#include <string>

#include <gtest/gtest.h>

module tasty:pars.dummy.subordinate.g;

import :pars.dummy.subordinate;

namespace {
using namespace tasty;

// TESTS
TEST(Dummy_SubordinateTest, NameReturnsNamePassedAtConstruction)
{
    // GIVEN a 'Dummy_Subordinate' object constructed with a name,
    //
    // WHEN the 'name()' method is called,
    //
    // THEN a non-modifiable reference to the name's value is returned.

    const std::string expectedName("foo");
    const pars::Dummy_Subordinate dummySubordinate(expectedName);

    const std::string& actualName = dummySubordinate.name();

    EXPECT_EQ(expectedName, actualName);
}

}  // close unnamed namespace
