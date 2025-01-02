// Top-level MIPS module
module mips_processor (
    input clk,
    input rst,
    input file_init,
    output reg [31:0] PC_out
);

    // Instruction Memory (IMEM)
    reg [31:0] IMEM [0:4095];

    // Memory Unit
    reg [31:0] MEM [0:4095];

    // Initialize Instruction Memory from external file
    initial begin
        $readmemh("/home/yigit/Desktop/Labs/homework/work/initIM.dat", IMEM);
        $readmemh("/home/yigit/Desktop/Labs/homework/work/initDM.dat", MEM);
    end
        
    // Fetch Unit
    wire [31:0] instruction;
    assign instruction = IMEM[PC_out >> 2];
    
    // Control Unit Signals
    wire [5:0] opcode;
    wire [5:0] funct;
    wire jump, branch, mem_read, mem_to_reg, mem_write,reg_write, jalfor, alu_src;
    wire [1:0] reg_dst;
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
        .jalfor(jalfor),
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

    wire [31:0] shamt;
    assign shamt = {27'b0, instruction[10:6]};

    wire [15:0] address;
    assign address = instruction[15:0];
    
    wire [31:0] read_data_1, read_data_2;

    wire [4:0] muxed_rd; // Muxed write register
    wire [4:0] muxed_rs; // Muxed read register

    reg [5:0] loop_counter;

    multiplexer_5bit_4 mux_reg_dst (
        .data_in_0(rt),
        .data_in_1(rd),
        .data_in_2(5'b11111),
        .data_in_3(5'b11111),
        .sel(reg_dst),
        .data_out(muxed_rd)
    );

    multiplexer_5bit mux_reg_src (
        .data_in_0(5'b11111),
        .data_in_1(rs),
        .sel(~&loop_counter),
        .data_out(muxed_rs)
    );

    wire [31:0] jalfor_writeback_original_address;

    multiplexer mux_write_data (
      .data_in_0(write_back_data),
      .data_in_1(PC_out + 4),
      .sel(jalfor),
      .data_out(jalfor_writeback_original_address)
    );
    
    // Instantiate Register File
    register_file rf (
        .clk(clk),
        .rst(rst),
        .rs(muxed_rs),
        .rt(rt),
        .rd(muxed_rd),
        .reg_write(reg_write),
        .reg_dst(reg_dst),
        .write_data(jalfor_writeback_original_address),
        .file_init(file_init),
        .read_data_1(read_data_1),
        .read_data_2(read_data_2)
    );

    // Loop Counter and Iteration Logic
    reg [5:0] number_of_iterations;
    reg [5:0] iteration_const;
    wire [31:0] PC_address, ALU_in;

    demux_1to2 demux_read_data_1 (
        .data_in(read_data_1),
        .sel(~&loop_counter),
        .data_out_0(PC_address),
        .data_out_1(ALU_in)
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
    wire [31:0] alu_a, alu_b, alu_a_temp;
    wire [31:0] alu_result;
    wire zero;
    
    // Main Control Logic
    wire [31:0] immediate;
    assign immediate = {{16{instruction[15]}}, address};
    
    wire [31:0] branch_offset; // 32 bit but 28 of them used.
    assign branch_offset = {4'b0000,instruction[25:0], 2'b00};
    
    reg branch_taken;
    
    always @(posedge clk or posedge rst) begin
        if (rst)
            branch_taken <= 1'b0;
        else if (opcode[2:0] == 3'b011)
            branch_taken = (branch && zero);  //bqe
        else if (opcode[2:0] == 3'b100)
            branch_taken = (branch && ~zero); //bne
    end
    
    // ALU Input Assignments
    // read_data_1 ??
    //assign alu_a = reg_dst ? read_data_2 : PC_out + (branch_taken ? branch_offset : 32'd0); //FIXME write as a multiplexer

    wire [31:0] alu_a_branch;

    multiplexer mux_alu_a_branch (
      .data_in_0(32'd0),
      .data_in_1(branch_offset),
      .sel(branch_taken),
      .data_out(alu_a_branch)
    );

    wire [31:0] alu_a_pc;
    assign alu_a_pc = alu_a_branch + PC_out;

    multiplexer mux_alu_a (
      .data_in_0(alu_a_pc),
      //.data_in_1(read_data_1),
      .data_in_1(ALU_in),
      .sel(reg_dst[0]),
      .data_out(alu_a_temp)
    );

    //assign alu_b = alu_src ? immediate : read_data_2; //FIXME write as a multiplexer
    multiplexer mux_alu_b (
      .data_in_0(read_data_2),
      .data_in_1(immediate),
      .sel(alu_src),
      .data_out(alu_b)
    );

    wire shamt_sel = AlUControlOut == 4'b0001 || AlUControlOut == 4'b0010 ? 1'b1 : 1'b0;

    multiplexer mux_alu_c (
      .data_in_0(alu_a_temp),
      .data_in_1(shamt),
      .sel(shamt_sel),
      .data_out(alu_a)
    );
    
    // Instantiate ALU
    alu alu_inst (
        .A(alu_a),
        .B(alu_b),
        .AlUControlInput(AlUControlOut),
        .Zero(zero),
        .Result(alu_result)
    );
    
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
        
    // Instantiate multiplexer for data memory or ALU results.
    // It is for writing data to a register
    multiplexer mux (
        .data_in_0(alu_result),
        .data_in_1(memory_data_out),
        .sel(mem_to_reg),
        .data_out(write_back_data)
    );

    reg [31:0] jalfor_jump_address;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PC_out <= 32'b0;
            loop_counter <= 4'b1111;
            number_of_iterations <= 4'b0000;
        end else if (jump && jalfor) begin
            jalfor_jump_address <= {PC_out[31:28], 2'b00, address}; // Jump to target address
            PC_out <= {PC_out[31:28], 2'b00, address};
            loop_counter <= rt - 1;
            number_of_iterations <= rs;
            iteration_const <= rs;
        end else if (number_of_iterations > 1) begin
            PC_out <= PC_out + 4;
            number_of_iterations <= number_of_iterations - 1;
        end else if (number_of_iterations == 1 && loop_counter != 0 && loop_counter != 4'b1111) begin
            number_of_iterations <= iteration_const;
            loop_counter <= loop_counter - 1;
            PC_out <= jalfor_jump_address;
        end else if (loop_counter == 0) begin
            PC_out <= PC_address + 4;
            loop_counter <= 4'b1111;
        end else if (jump && ~jalfor) begin
            PC_out <= {PC_out[31:28], 2'b00, instruction[15:0]}; // Jump for jal instructions
        end else if (branch_taken) begin
            PC_out <= PC_out + branch_offset;
        end else
            PC_out <= PC_out + 4; // Sequential execution
    end



  // Monitor PART
  always @(PC_out) begin
    $monitor("Time %t: PC = %h, Instruction = %b, rf[0] = %h (%d), rf[1] = %h (%d), rf[2] = %h (%d), rf[3] = %h (%d), rf[4] = %h (%d), mem[0] = %h (%d), mem[1] = %h (%d), mem[2] = %h (%d), mem[3] = %h (%d), mem[4] = %h (%d)",

       $time,
       PC_out, instruction,
       rf.rf[0], rf.rf[0],
       rf.rf[1], rf.rf[1],
       rf.rf[2], rf.rf[2],
       rf.rf[3], rf.rf[3],
       rf.rf[4], rf.rf[4],
       MEM[0], MEM[0],
       MEM[1], MEM[1],
       MEM[2], MEM[2],
       MEM[3], MEM[3],
       MEM[4], MEM[4]
);
end

endmodule
