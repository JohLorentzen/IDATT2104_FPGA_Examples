cmake_minimum_required(VERSION 3.16)
project(DotProduct_tb CXX)

# Find Verilator
find_package(verilator HINTS ${VERILATOR_ROOT} $ENV{VERILATOR_ROOT})

# SystemC dependencies
set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

# Find SystemC using SystemC's CMake integration
find_package(SystemCLanguage PATHS ${SYSTEMC_HOME})

add_executable(DotProduct_tb DotProduct_tb.cc)

set_property(
    TARGET DotProduct_tb
    PROPERTY CXX_STANDARD ${SystemC_CXX_STANDARD}
)

verilate(DotProduct_tb SYSTEMC COVERAGE TRACE
    INCLUDE_DIRECTORIES "."
    SOURCES DotProduct.v  
)

verilator_link_systemc(DotProduct_tb)

