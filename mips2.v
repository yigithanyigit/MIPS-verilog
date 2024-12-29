// Top-level MIPS module
module mips_processor (
    input clk,
    input rst,
    //output reg [31:0] PC_out,
    //output reg [31:0] IMEM [0:4095], 
    //output reg [31:0] MEM [0:4095]
    input [31:0] instruction,
    input [31:0] memory_data_out,
    output reg [31:0] PC_out,
    output [31:0] mem_addr,
    output [31:0] mem_data_in,
    output mem_write,
    output mem_read
);


    /*
    // Instruction Memory (IMEM)
    reg [31:0] IMEM [0:4095];

    // Memory Unit
    reg [31:0] MEM [0:4095];

    // Initialize Instruction Memory from external file
    initial begin
        $readmemh("/home/yigit/Desktop/Labs/homework/work/initIM.dat", IMEM);
        $readmemh("/home/yigit/Desktop/Labs/homework/work/initDM.dat", MEM);
    end
    
    always @(posedge clk or posedge rst) begin
        if (rst)
            PC_out <= 32'b0;
        else
            PC_out <= PC_out + 32'd4;
    end
    */
    
    // Fetch Unit
   // wire [31:0] instruction;
    assign instruction = IMEM[PC_out >> 2];
    
    // Control Unit Signals
    wire [5:0] opcode;
    wire [5:0] funct;
    //wire reg_dst, jump, branch, mem_read, mem_to_reg, mem_write, alu_src, reg_write;
    wire reg_dst, jump, branch, mem_to_reg, alu_src, reg_write;
    wire [2:0] alu_op; // 3-bit wide
    
    assign opcode = instruction[31:26];
    assign funct = instruction[5:0];
    
    // Instantiate Control Unit
    control_unit cu (
        .opcode(opcode),
        .reg_dst(reg_dst),
        .jump(jump),
        .branch(branch),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write)
    );
    

    // Write Back Unit
    wire [31:0] write_back_data;


    // Register File Signals
    wire [4:0] rs, rt, rd;
    assign rs = instruction[25:21];
    assign rt = instruction[20:16];
    assign rd = instruction[15:11];
    
    wire [31:0] read_data_1, read_data_2;
    
    // Instantiate Register File
    register_file rf (
        .clk(clk),
        .rst(rst),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .reg_write(reg_write),
        .write_data(write_back_data),
        .read_data_1(read_data_1),
        .read_data_2(read_data_2)
    );
    
    // ALU Control Signals
    wire [3:0] ALUOp;
    wire [3:0] AlUControlOut;
    assign ALUOp = alu_op;
    
    // Instantiate ALU Control
    alucontrol ac (
        .ALUOp(ALUOp),
        .funct(funct),
        .AlUControlOut(AlUControlOut)
    );
    
    // ALU Signals
    wire [31:0] alu_a, alu_b;
    wire [31:0] alu_result;
    wire zero;
    
    // Main Control Logic
    wire [31:0] immediate;
    assign immediate = {{16{instruction[15]}}, instruction[15:0]};
    
    wire [27:0] branch_offset;
    assign branch_offset = {instruction[25:0], 2'b00};
    
    reg branch_taken;
    
    always @(posedge clk or posedge rst) begin
        if (rst)
            branch_taken <= 1'b0;
        else
            branch_taken <= (branch && zero);
    end
    
    // ALU Input Assignments
    assign alu_a = reg_dst ? read_data_2 : PC_out + (branch_taken ? branch_offset : 32'd0);
    assign alu_b = alu_src ? immediate : read_data_2;
    
    // Instantiate ALU
    alu alu_inst (
        .A(alu_a),
        .B(alu_b),
        .AlUControlInput(AlUControlOut),
        .Zero(zero),
        .Result(alu_result)
    );
    
    /*
    wire [31:0] memory_data_out;
    assign memory_data_out = mem_read ? MEM[alu_result >> 2] : 32'b0;
    
    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 4096; i = i + 1) begin
                MEM[i] <= 32'b0;
            end
        end else if (mem_write) begin
            MEM[alu_result >> 2] <= alu_b;
        end
    end
       
    */ 

    assign mem_addr = alu_result;
    assign mem_data_in = read_data_2;

    // Instantiate Multiplexer
    multiplexer mux (
        .data_in_0(alu_result),
        .data_in_1(memory_data_out),
        .sel(mem_to_reg),
        .data_out(write_back_data)
    );

endmodule
