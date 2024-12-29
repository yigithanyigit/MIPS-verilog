// ALU Control Module
module alucontrol (
    input [3:0] ALUOp,
    input [5:0] funct,
    output reg [3:0] AlUControlOut
);

    always @(*) begin
        case (ALUOp)
            3'b000: AlUControlOut = 4'b0111; // Add
            3'b001: AlUControlOut = 4'b0100; // Subtract
            3'b010: begin
                case (funct)
                    6'b000111: AlUControlOut = 4'b0111; // ADD
                    6'b000100: AlUControlOut = 4'b0100; // SUB
                    6'b000110: AlUControlOut = 4'b0110; // AND
                    6'b000101: AlUControlOut = 4'b0101; // OR
                    6'b000000: AlUControlOut = 4'b0000; // XOR
                    6'b000001: AlUControlOut = 4'b0001; // SLL
                    6'b000010: AlUControlOut = 4'b0010; // SRL
                    6'b000011: AlUControlOut = 4'b0011; // NOR
                    6'b001000: AlUControlOut = 4'b1000; // SLT (Set Less Than)
                    default: AlUControlOut = 4'b1111; // Undefined
                endcase
            end
            default: AlUControlOut = 4'b1111; // Undefined
        endcase
    end

endmodule
