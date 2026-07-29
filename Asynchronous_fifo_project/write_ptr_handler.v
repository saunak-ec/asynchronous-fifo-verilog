// write pointer handler 
// description: the write point handler controls the write pointer and depending on its position and other singals like enable, allows writing .
//it also controls the full flag to prevent overriding of present datas in the memory
module write_ptr_handler(wclk,wrst_n,b_wptr,g_wptr,g_rptr_sync,w_en,full);
  parameter ptr_width=3;  //pointer width
  // ports
  input wclk;   //write clock
  input wrst_n;  //active-low reset signal for write domain 
  input w_en;   //asynchronous enable signal to allow writing int he memory
  input[ptr_width:0] g_rptr_sync;   //synchronus gray coded read point
  output reg [ptr_width:0] b_wptr,g_wptr;  //the write pointer is taken in graycode to minimize the error in signals during synchronization
  output reg full;
  //internal signals
  wire[ptr_width:0] b_wptr_next;
  wire[ptr_width:0] g_wptr_next;
  //next pointer calculation : add 1 to current pointer
  assign b_wptr_next=b_wptr+1;
  //binary to gray conversion
  assign g_wptr_next=(b_wptr_next>>1)^b_wptr_next;
  always@(posedge wclk or negedge wrst_n) //asynchronus reset
    if(!wrst_n)
      begin
        b_wptr<=0;
        g_wptr<=0;
      end
    else if(w_en& ~full)
      begin
        b_wptr<=b_wptr_next;
        g_wptr<=g_wptr_next;
      end
    else
      begin
        b_wptr<=b_wptr;
        g_wptr<=g_wptr;
      end
  //full flag generation
  //fifo is full when MSB and 2ND MSB of gray write pointer and synchronized read pointer are inverted
  //all other bits are same
  always@(posedge wclk or negedge wrst_n)
    if(!wrst_n)
      full<=0;
    else if(g_wptr_next=={~g_rptr_sync[ptr_width:ptr_width-1],g_rptr_sync[ptr_width-2:0]})
      full<=1;
    else 
      full<=0;
endmodule