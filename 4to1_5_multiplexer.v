module multiplexer_5bit_4 (
    input [4:0] data_in_0, data_in_1, data_in_2, data_in_3,
    input [1:0] sel,
    output reg [4:0] data_out
);

    always @(*) begin
        case (sel)
            2'b00: data_out = data_in_0;
            2'b01: data_out = data_in_1;
            2'b10: data_out = data_in_2;
            2'b11: data_out = data_in_3;
            default: data_out = 5'b0;
        endcase
    end

endmodule
