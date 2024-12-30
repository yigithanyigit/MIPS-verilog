module demux_1to2 (
    input [31:0] data_in,
    input sel,
    output reg [31:0] data_out_0,
    output reg [31:0] data_out_1
);

    always @(*) begin
        // Default all outputs to 0
        data_out_0 = 32'b0;
        data_out_1 = 32'b0;

        // Route data_in to the selected output
        case (sel)
            1'b0: data_out_0 = data_in;
            1'b1: data_out_1 = data_in;
            default: ; // Do nothing
        endcase
    end

endmodule
