//testbench for asynchronous fifo
//this testbench writes input at negative clock edge and reads at positive edge
//this is useful for avoiding setup and hold violations
`timescale 1ns/1ps
module asynchronous_fifo_tb();
  localparam DATA_WIDTH = 8, DEPTH = 16; 
  reg wclk, rclk, wrst_n, rrst_n, w_en, r_en;
  reg [DATA_WIDTH-1:0] data_in;
  wire [DATA_WIDTH-1:0] data_out;
  wire empty, full;

  //instantiating the DUT
  asynchronous_fifo #(.datasize(DATA_WIDTH), .depth(DEPTH)) dut (
    .wclk(wclk), 
    .rclk(rclk), 
    .wrst_n(wrst_n), 
    .rrst_n(rrst_n), 
    .w_en(w_en),
    .r_en(r_en), 
    .data_in(data_in),
    .data_out(data_out), 
    .empty(empty), 
    .full(full)
  );

  //Initialization of inputs
  initial begin
    {rclk, wclk, wrst_n, rrst_n, w_en, r_en} = 6'b000000;
    data_in = 8'h00;
  end

  //clock inputs 
  always #5 wclk = ~wclk; //write clock = 100MHz
  always #10 rclk = ~rclk; //read clock = 50MHz

  initial begin
    $dumpfile("wav_asynchronous_fifo.vcd");
    $dumpvars(0, asynchronous_fifo_tb);
    
    #5 wrst_n = 1'b1; rrst_n = 1'b1; 
    //writing data into the FIFO (Checking for overflow condition simultaneously)
    w_en = 1'b1;
    #10;
    repeat(18) @(negedge wclk) data_in = data_in + 1;
    w_en = 1'b0;
    //reading data from the FIFO (Checking for the underflow condition simultaneously)
    #20;
    r_en = 1'b1;
    repeat(18) @ (posedge rclk);
    r_en = 1'b0;

    #50;

    //simultaneous Read and Write
    w_en = 1'b1; r_en = 1'b1;
    repeat(25) @(negedge wclk) data_in = data_in + 1;  
    w_en = 1'b0;
    #350 r_en = 1'b0;
    
    #20 $finish;
  end

endmodule