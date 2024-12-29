 module pc(
    input wire clk,
    input wire rst,
    output reg [31:0] PC_out
);

 always @(posedge clk or posedge rst) begin
        if (rst)
            PC_out <= 32'b0;
        else
            PC_out <= PC_out + 32'd4;
    end

endmodule
