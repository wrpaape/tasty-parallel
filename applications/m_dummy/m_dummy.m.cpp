// m_dummy.m.cpp                                                      -*-C++-*-
module tasty:m_dummy;

import :m_dummy.dummyapplication;

using namespace tasty;

int main(int argc, char *argv[])
{
    return m_dummy::DummyApplication::exec(argc, argv);
}
