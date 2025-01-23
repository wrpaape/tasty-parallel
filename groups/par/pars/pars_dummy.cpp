// bdlcc_singleconsumerqueue.h                                        -*-C++-*-
module;

#include <string>
#include <utility>

export module tasty:pars.dummy;

import :pars.dummy.subordinate;

namespace tasty {
namespace pars {

                             // ==============
                             // class DummyImp
                             // ==============

class DummyImp {
    // This class implements the 'Dummy' class.

  private:
    // DATA
    Dummy_Subordinate d_imp; // implementation

  public:
    // CREATORS
    explicit DummyImp(std::string name);
        // Create a 'DummyImp' object having the specified 'name'.

    // ACCESSORS
    const std::string& name() const;
        // Return a reference offering non-modifiable access to this object's
        // name.
};

                              // ===========
                              // class Dummy
                              // ===========

export class Dummy {
    // This is a dummy class.

  private:
    // DATA
    DummyImp d_imp;

  public:
    // CREATORS
    explicit Dummy(std::string name);
        // Create a 'Dummy' object having the specified 'name'.

    // ACCESSORS
    const std::string& name() const;
        // Return a reference offering non-modifiable access to this object's
        // name.
};

                             // --------------
                             // class DummyImp
                             // --------------

// CREATORS
DummyImp::DummyImp(std::string name)
: d_imp(std::move(name))
{
}

// ACCESSORS
const std::string& DummyImp::name() const
{
    return d_imp.name();
}

                              // -----------
                              // class Dummy
                              // -----------

// CREATORS
Dummy::Dummy(std::string name)
: d_imp(std::move(name))
{
}

// ACCESSORS
const std::string& Dummy::name() const
{
    return d_imp.name();
}

}  // close package namespace
}  // close enterprise namespace
