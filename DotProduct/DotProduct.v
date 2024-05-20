module DotProduct #(
    parameter SIZE = 10000 // Determine the size of the vectors.
) (
    input logic clk_i,
    input logic reset_n_i,
    input logic [31:0] a_i [SIZE],
    input logic [31:0] b_i [SIZE],
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
            for (i = 0; i < SIZE; i = i + 1) begin
                temp_result = temp_result + (a_i[i] * b_i[i]);
            end
            // Assign the result to the output
            result_o <= temp_result;
        end
    end
endmodule
