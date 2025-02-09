// m_dummy.m.cpp                                                      -*-C++-*-
export module tasty:m_dummy;

import :m_dummy.dummyapplication;

using namespace tasty;

export int main(int argc, char *argv[])
{
    return m_dummy::DummyApplication::exec(argc, argv);
}
