module multiplexer_5bit (
    input [4:0] data_in_0, data_in_1,
    input sel,
    output reg [4:0] data_out
);

    always @(*) begin
        case (sel)
            1'b0: data_out = data_in_0;
            1'b1: data_out = data_in_1;
            default: data_out = 5'b11111;
        endcase
    end

endmodule
