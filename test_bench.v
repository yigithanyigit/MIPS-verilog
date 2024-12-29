module test_bench;
  reg clk;
  reg rst;
  wire [31:0] PC_out;

  reg file_init;

  // Instantiate the MIPS processor
  mips_processor uut (
    .clk(clk),
    .rst(rst),
    .file_init(file_init),
    .PC_out(PC_out)
  );

  initial begin
    // Initialize clock and reset
    clk = 0;
    rst = 1;
    file_init = 0;
    #20 rst = 0; // Release reset after 10 time units
    #20 file_init = 1;

    // Run the simulation for a specific duration
    #400 $finish; // max pico sec
  end

  // Clock generation
  initial begin
    forever #20 clk = ~clk;
  end

  // Monitor signals
  //initial begin
  //  $monitor($time, " PC %h", PC_out);
  //end
endmodule
