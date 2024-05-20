#include <systemc.h>
#include <verilated.h>
#include <verilated_vcd_sc.h>

#include "VDotProduct.h"  // Generated from DotProduct.v by Verilator

#include <iostream>
#include <memory>

#define SIZE 10000  // Define the size parameter

int sc_main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    // Get VCD file path from command line arguments
    std::string vcd_file_path;
    if (argc == 2) {
        vcd_file_path = std::string(argv[1]);
    }

    // Signals
    sc_clock clk{"clk", 1, SC_NS, 0.5, 0, SC_NS, true};
    sc_signal<bool> reset_n;

    // Input signals
    sc_signal<uint32_t> a[SIZE];
    sc_signal<uint32_t> b[SIZE];

    // Output signal
    sc_signal<uint32_t> result;

    // Create DotProduct module instance
    const std::unique_ptr<VDotProduct> dotProduct{new VDotProduct{"dotProduct"}};

    // Connect signals to the DotProduct module
    dotProduct->clk_i(clk);
    dotProduct->reset_n_i(reset_n);
    for (int i = 0; i < SIZE; ++i) {
        dotProduct->a_i[i](a[i]);
        dotProduct->b_i[i](b[i]);
    }
    dotProduct->result_o(result);

    // Start simulation and trace
    std::cout << "VDotProduct start!" << std::endl;

    sc_start(0, SC_NS);

    VerilatedVcdSc* trace = new VerilatedVcdSc();
    dotProduct->trace(trace, 99);

    if (vcd_file_path.empty()) {
        trace->open("DotProduct_tb.vcd");
    } else {
        trace->open(vcd_file_path.c_str());
    }

    // Reset
    sc_start(1, SC_NS);
    reset_n.write(0);
    sc_start(1, SC_NS);
    reset_n.write(1);
    sc_start(1, SC_NS);

    // Initialize vectors
    for (int i = 0; i < SIZE; ++i) {
        a[i].write(1); 
        b[i].write(2);  
    }

    sc_start(100, SC_NS);  // Wait for more time to let the module compute

    // Print the result
    std::cout << "Dot Product: " << result.read() << std::endl;

    dotProduct->final();

    trace->flush();
    trace->close();

    delete trace;

    std::cout << "VDotProduct done!" << std::endl;
    return 0;
}