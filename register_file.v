// Register File Module
module register_file (
    input clk,
    input rst,
    input [4:0] rs, rt, rd,
    input reg_write,
    input reg_dst,
    input [31:0] write_data,
    input file_init,
    output [31:0] read_data_1, read_data_2
);

    reg [31:0] rf [0:31];
    integer i;

/*
    always @(posedge file_init) begin
      // Initialize Register File from external file
      $readmemh("/home/yigit/Desktop/Labs/homework/work/initReg.dat", rf);
    end
*/

    initial begin
      $readmemh("/home/yigit/Desktop/Labs/homework/work/initReg.dat", rf);
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
       //     for (i = 0; i < 32; i = i + 1) begin
       //         rf[i] <= 32'b0;
       //     end

            
        //end else if (reg_write && rd != 5'b00000) begin
        //    rf[rd] <= write_data;
        //end
        end else if (reg_write) begin
            if (reg_dst) begin
                rf[rd] <= write_data;
            end else begin
                rf[rt] <= write_data;
            end
        end
    end

    assign read_data_1 = rf[rs];
    assign read_data_2 = rf[rt];

endmodule
