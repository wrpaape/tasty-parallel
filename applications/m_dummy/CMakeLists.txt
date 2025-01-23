add_library(m_dummy_lib)
target_sources(
    m_dummy_lib
    PUBLIC
    FILE_SET tasty_m_dummy_lib TYPE CXX_MODULES FILES
        m_dummy_dummyapplication.cpp
)
target_link_libraries(m_dummy_lib PRIVATE pars)

add_executable(m_dummy_dummyapplication.t)
target_sources(
    m_dummy_dummyapplication.t
    PRIVATE
    FILE_SET tasty_m_dummy_dummyapplication_t TYPE CXX_MODULES FILES
        m_dummy_dummyapplication.t.cpp
)
target_link_libraries(m_dummy_dummyapplication.t PRIVATE m_dummy_lib)
add_test(
    NAME    m_dummy_dummyapplication.t
    COMMAND $<TARGET_FILE:m_dummy_dummyapplication.t>
)

add_executable(m_dummy)
target_sources(
    m_dummy
    PRIVATE
    FILE_SET tasty_m_dummy TYPE CXX_MODULES FILES
        m_dummy.m.cpp
)
target_link_libraries(m_dummy PRIVATE m_dummy_lib)
