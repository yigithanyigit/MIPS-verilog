// Control Unit Module
module control_unit (
    input [5:0] opcode,
    output reg jump, branch,
    output reg mem_read, mem_to_reg, mem_write, jalfor,
    output reg [2:0] alu_op,
    output reg [1:0] reg_dst,
    output reg alu_src, reg_write
);

    always @(*) begin
        case (opcode)
            6'b110001: begin // lw
                reg_dst     = 2'b01;
                jump        = 1'b0;
                branch      = 1'b0;
                mem_read    = 1'b1;
                mem_to_reg  = 1'b1;
                alu_op      = 3'b000; // Add
                mem_write   = 1'b0;
                alu_src     = 1'b1; // 1 - For Immediate / 0 - For registers
                reg_write   = 1'b1;
                jalfor      = 1'b0;
            end
            6'b110010: begin // sw
                reg_dst     = 2'b01;
                jump        = 1'b0;
                branch      = 1'b0;
                mem_read    = 1'b0;
                mem_to_reg  = 1'b0;
                alu_op      = 3'b000; // Add
                mem_write   = 1'b1;
                alu_src     = 1'b1; // Immediate
                reg_write   = 1'b0;
                jalfor      = 1'b0;
            end
            6'b110011: begin // beq
                reg_dst     = 2'b01;
                jump        = 1'b0;
                branch      = 1'b1;
                mem_read    = 1'b0;
                mem_to_reg  = 1'b0;
                alu_op      = 3'b001; // Subtract
                mem_write   = 1'b0;
                alu_src     = 1'b0; // Register
                reg_write   = 1'b0;
                jalfor      = 1'b0;
            end
            6'b110100: begin // bne
                reg_dst     = 2'b01;
                jump        = 1'b0;
                branch      = 1'b1;
                mem_read    = 1'b0;
                mem_to_reg  = 1'b0;
                alu_op      = 3'b001; // Subtract
                mem_write   = 1'b0;
                alu_src     = 1'b0; // Register
                reg_write   = 1'b0;
                jalfor      = 1'b0;
            end
            6'b110101: begin // addi
                reg_dst     = 2'b1;
                jump        = 1'b0;
                branch      = 1'b0;
                mem_read    = 1'b0;
                mem_to_reg  = 1'b0;
                alu_op      = 3'b000; // Add
                mem_write   = 1'b0;
                alu_src     = 1'b1; // Immediate
                reg_write   = 1'b1;
                jalfor      = 1'b0;
            end
            6'b110110: begin // j
                reg_dst     = 2'b0;
                jump        = 1'b1;
                branch      = 1'b0;
                mem_read    = 1'b0;
                mem_to_reg  = 1'b0;
                alu_op      = 3'b000;
                mem_write   = 1'b0;
                alu_src     = 1'b0;
                reg_write   = 1'b0;
                jalfor      = 1'b0;
            end
            6'b110111: begin // jal
                reg_dst     = 2'b0;
                jump        = 1'b1;
                branch      = 1'b0;
                mem_read    = 1'b0;
                mem_to_reg  = 1'b0;
                alu_op      = 3'b000;
                mem_write   = 1'b0;
                alu_src     = 1'b0;
                reg_write   = 1'b1;
                jalfor      = 1'b0;
            end
            6'b111000: begin // jalfor
                reg_dst     = 2'b10;
                jump        = 1'b1;
                branch      = 1'b0;
                mem_read    = 1'b0;
                mem_to_reg  = 1'b0;
                alu_op      = 3'b000;
                mem_write   = 1'b0;
                alu_src     = 1'b0;
                reg_write   = 1'b1;
                jalfor      = 1'b1;
            end
            6'b110000: begin // R-type instructions
                reg_dst     = 2'b01;
                jump        = 1'b0;
                branch      = 1'b0;
                mem_read    = 1'b0;
                mem_to_reg  = 1'b0;
                alu_op      = 3'b010; // Function Code
                mem_write   = 1'b0;
                alu_src     = 1'b0; // Register
                reg_write   = 1'b1;
                jalfor      = 1'b0;
            end
            default: begin
                reg_dst     = 2'b0;
                jump        = 1'b0;
                branch      = 1'b0;
                mem_read    = 1'b0;
                mem_to_reg  = 1'b0;
                alu_op      = 3'b000;
                mem_write   = 1'b0;
                alu_src     = 1'b0;
                reg_write   = 1'b0;
                jalfor      = 1'b0;
            end
        endcase
    end

endmodule
