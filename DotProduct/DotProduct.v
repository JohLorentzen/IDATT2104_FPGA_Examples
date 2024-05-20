/*
// DotProduct with parralel processing elements

module DotProduct #(
    parameter SIZE = 10000,  // Determine the size of the vectors.
    parameter PE_COUNT = 10  // Number of parallel processing elements.
) (
    input logic clk_i,
    input logic reset_n_i,
    input logic [31:0] a_i [SIZE],
    input logic [31:0] b_i [SIZE],
    output logic [31:0] result_o
);

    // Derived parameters
    localparam PART_SIZE = SIZE / PE_COUNT;

    // Partial results from each processing element
    logic [31:0] partial_results [PE_COUNT];

    // Internal logic for processing elements
    genvar i;
    generate
        for (i = 0; i < PE_COUNT; i = i + 1) begin : pe_block
            DotProductPE #(
                .START_IDX(i * PART_SIZE),
                .END_IDX((i + 1) * PART_SIZE - 1)
            ) pe (
                .clk_i(clk_i),
                .reset_n_i(reset_n_i),
                .a_i(a_i[(i * PART_SIZE) +: PART_SIZE]),
                .b_i(b_i[(i * PART_SIZE) +: PART_SIZE]),
                .result_o(partial_results[i])
            );
        end
    endgenerate

    // Accumulate partial results
    always_ff @(posedge clk_i or negedge reset_n_i) begin
        if (!reset_n_i) begin
            result_o <= 0;
        end else begin
            logic [31:0] temp_result;
            temp_result = 0;
            for (integer j = 0; j < PE_COUNT; j = j + 1) begin
                temp_result = temp_result + partial_results[j];
            end
            result_o <= temp_result;
        end
    end
endmodule

module DotProductPE #(
    parameter START_IDX = 0,
    parameter END_IDX = 999
) (
    input logic clk_i,
    input logic reset_n_i,
    input logic [31:0] a_i [0:END_IDX - START_IDX],
    input logic [31:0] b_i [0:END_IDX - START_IDX],
    output logic [31:0] result_o
);

    // Internal logic
    integer i;
    always_ff @(posedge clk_i or negedge reset_n_i) begin
        if (!reset_n_i) begin
            result_o <= 0;
        end else begin
            // Use a temporary variable for accumulation
            logic [31:0] temp_result;
            temp_result = 0;
            for (i = 0; i <= (END_IDX - START_IDX); i = i + 1) begin
                temp_result = temp_result + (a_i[i] * b_i[i]);
            end
            // Assign the result to the output
            result_o <= temp_result;
        end
    end
endmodule
*/

// DotProduct with pipeline registers
module DotProduct #(
    parameter SIZE = 10000,  // Determine the size of the vectors.
    parameter PE_COUNT = 10  // Number of parallel processing elements.
) (
    input logic clk_i,
    input logic reset_n_i,
    input logic [31:0] a_i [SIZE],
    input logic [31:0] b_i [SIZE],
    output logic [31:0] result_o
);

    // Derived parameters
    localparam PART_SIZE = SIZE / PE_COUNT;

    // Partial results from each processing element
    logic [31:0] partial_results [PE_COUNT];

    // Pipeline registers for intermediate results
    logic [31:0] pipeline_regs [PE_COUNT - 1:0];

    // Internal logic for processing elements
    genvar i;
    generate
        for (i = 0; i < PE_COUNT; i = i + 1) begin : pe_block
            DotProductPE #(
                .START_IDX(i * PART_SIZE),
                .END_IDX((i + 1) * PART_SIZE - 1)
            ) pe (
                .clk_i(clk_i),
                .reset_n_i(reset_n_i),
                .a_i(a_i[(i * PART_SIZE) +: PART_SIZE]),
                .b_i(b_i[(i * PART_SIZE) +: PART_SIZE]),
                .result_o(partial_results[i])
            );
        end
    endgenerate

    // Pipeline stages
    always_ff @(posedge clk_i or negedge reset_n_i) begin
        if (!reset_n_i) begin
            result_o <= 0;
            for (integer j = 0; j < PE_COUNT - 1; j = j + 1) begin
                pipeline_regs[j] <= 0;
            end
        end else begin
            pipeline_regs[0] <= partial_results[0];
            for (integer j = 1; j < PE_COUNT - 1; j = j + 1) begin
                pipeline_regs[j] <= pipeline_regs[j - 1] + partial_results[j];
            end
            result_o <= pipeline_regs[PE_COUNT - 2] + partial_results[PE_COUNT - 1];
        end
    end
endmodule

module DotProductPE #(
    parameter START_IDX = 0,
    parameter END_IDX = 999
) (
    input logic clk_i,
    input logic reset_n_i,
    input logic [31:0] a_i [0:END_IDX - START_IDX],
    input logic [31:0] b_i [0:END_IDX - START_IDX],
    output logic [31:0] result_o
);

    // Internal logic
    integer i;
    always_ff @(posedge clk_i or negedge reset_n_i) begin
        if (!reset_n_i) begin
            result_o <= 0;
        end else begin
            // Use a temporary variable for accumulation
            logic [31:0] temp_result;
            temp_result = 0;
            for (i = 0; i <= (END_IDX - START_IDX); i = i + 1) begin
                temp_result = temp_result + (a_i[i] * b_i[i]);
            end
            // Assign the result to the output
            result_o <= temp_result;
        end
    end
endmodule
