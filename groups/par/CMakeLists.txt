include(tasty_setup_target_uor)

set(target par)

add_library(${target} STATIC)
tasty_setup_target_uor(${target})
