// ALU Module
module alu (
    input [31:0] A, B,
    input [3:0] AlUControlInput,
    output reg Zero,
    output reg [31:0] Result
);

    always @(*) begin
        case (AlUControlInput)
            4'b0111: Result = A + B; // ADD
            4'b0100: Result = A - B; // SUB
            4'b0110: Result = A & B; // AND
            4'b0101: Result = A | B; // OR
            4'b0000: Result = A ^ B; // XOR
            4'b0001: Result = B << A; // SLL (Shift Left Logical)
            4'b0010: Result = B >> A; // SRL (Shift Right Logical)
            4'b0011: Result = ~(A | B); // NOR
            4'b1000: Result = (A < B) ? 32'b1 : 32'b0; // SLT (Set Less Than)
            default: Result = 32'b0;
        endcase

        Zero = (Result == 32'b0);
    end

endmodule
