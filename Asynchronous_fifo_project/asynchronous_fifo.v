//final module (top level)
`include "synchronizer.v"
`include "write_ptr_handler.v"
`include "read_ptr_handler.v"
`include "fifo_mem.v"

module asynchronous_fifo #(
  parameter depth = 8,
  parameter datasize = 8,
  parameter ptr_width = $clog2(depth)
)(
  // Ports 
  input  wire wclk,
  input  wire w_en,
  input  wire wrst_n,
  input  wire rclk,
  input  wire r_en,
  input  wire rrst_n,
  output wire empty,
  output wire full,
  input  wire [datasize-1:0] data_in,
  output wire [datasize-1:0] data_out
);
  //intermidiate signals
  wire[ptr_width:0] b_wptr,b_rptr,g_wptr,g_rptr,g_rptr_sync,g_wptr_sync;
  //module instantiations
  // Synchronizers (Data width is ptr_width + 1 to hold the 4-bit pointers)
  synchronizer #(.data_width(ptr_width + 1)) sync_r2w (
    .clk(wclk), 
    .rst_n(wrst_n), 
    .din(g_rptr), 
    .dout(g_rptr_sync)
  );
  
  synchronizer #(.data_width(ptr_width + 1)) sync_w2r (
    .clk(rclk), 
    .rst_n(rrst_n), 
    .din(g_wptr), 
    .dout(g_wptr_sync)
  );
  
  // Pointer Handlers
  write_ptr_handler #(.ptr_width(ptr_width)) wptr_h (
    .wclk(wclk), 
    .wrst_n(wrst_n), 
    .b_wptr(b_wptr), 
    .g_wptr(g_wptr), 
    .g_rptr_sync(g_rptr_sync), 
    .w_en(w_en), 
    .full(full)
  );
  
  read_ptr_handler #(.ptr_width(ptr_width)) rptr_h (
    .rclk(rclk), 
    .rrst_n(rrst_n), 
    .b_rptr(b_rptr), 
    .g_rptr(g_rptr), 
    .g_wptr_sync(g_wptr_sync), 
    .r_en(r_en), 
    .empty(empty)
  );
  
  // FIFO Memory Array
  fifo_mem #(.datasize(datasize), .depth(depth)) fifo (
    .wclk(wclk), 
    .w_en(w_en), 
    .rptr(b_rptr[ptr_width-1:0]), // Stripping off the MSB for the memory address
    .wptr(b_wptr[ptr_width-1:0]), 
    .full(full), 
    .data_in(data_in), 
    .data_out(data_out)
  );

endmodule