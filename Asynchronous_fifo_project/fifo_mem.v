//FIFO memory
//dual port ram acting as the storage for asynchronous fifo
//writing is synchronous whereas reading is continous
module fifo_mem(wclk,w_en,rptr,wptr,full,data_in,data_out);
  parameter datasize=8,depth=8;
  localparam ptr_width=$clog2(depth);
  //ports
  input w_en;
  input wclk;
  input[datasize-1:0] data_in;
  input[ptr_width-1:0] rptr,wptr;
  input full;
  output [datasize-1:0] data_out;
  //declaring the fifo memory array
  reg[datasize-1:0]FIFO[depth-1:0];
  //synchronous write logic based on write enable and write clock
  always@(posedge wclk)
    begin
      if(w_en&!full)
        FIFO[wptr]<=dat//a_in;
    end
  //asynchronous read logic using continous assignment
  assign data_out=FIFO[rptr];
endmodule
