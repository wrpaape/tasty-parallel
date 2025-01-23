// pars_dummy_subordinate.cpp                                         -*-C++-*-
module;

#include <string>
#include <utility>

module tasty:pars.dummy.subordinate;

namespace tasty {
namespace pars {

                        // =======================
                        // class Dummy_Subordinate
                        // =======================

class Dummy_Subordinate {
    // This is a dummy class.

  private:
    // DATA
    std::string d_name; // name of this object

  public:
    // CREATORS
    explicit Dummy_Subordinate(std::string name);
        // Create a 'Dummy_Subordinate' object having the specified 'name'.

    // ACCESSORS
    const std::string& name() const;
        // Return a reference offering non-modifiable access to this object's
        // name.
};

                        // -----------------------
                        // class Dummy_Subordinate
                        // -----------------------

// CREATORS
Dummy_Subordinate::Dummy_Subordinate(std::string name)
: d_name(std::move(name))
{
}

// ACCESSORS
const std::string& Dummy_Subordinate::name() const
{
    return d_name;
}

}  // close package namespace
}  // close enterprise namespace
