//read point handler
//description: read point handler controls the read pointer allowing us to read from the FIFO memory when needed
//it also controls the empty flag and doesn't allow reading when memory is empty
module read_ptr_handler(rclk,rrst_n,b_rptr,g_rptr,g_wptr_sync,r_en,empty);
  parameter ptr_width=3;   //pointer width
  //ports
  input rclk;              //read clock
  input r_en;              //asynchronous read enable
  input rrst_n;            //active low reset
  input[ptr_width:0] g_wptr_sync;   //synchronized write pointer
  output reg [ptr_width:0] b_rptr,g_rptr;   //binary and gray read pointers
  output reg empty;                     //empty flag
  //internal signals
  wire[ptr_width:0] b_rptr_next;
  wire[ptr_width:0]g_rptr_next;
  //next pointer calculation:add 1 to current pointer
  assign b_rptr_next=b_rptr+1;
  //binary to gray conversion
  assign g_rptr_next=(b_rptr_next>>1)^b_rptr_next;
  always@(posedge rclk or negedge rrst_n) //asynchronus reset
    begin
      if(!rrst_n)
        begin
          b_rptr<=0;
          g_rptr<=0;
        end
      else if(r_en&~empty)  //read is done only read enable is active and memory is not empty
        begin
          b_rptr<=b_rptr_next;
          g_rptr<=g_rptr_next;
        end
    end
  //empty flag generation
  //FIFO is empty when read pointer and synchronized write pointer are equal
  always@(posedge rclk or negedge rrst_n) //asynchronous reset
    begin
      if(!rrst_n)
        empty<=1;
      else if(g_wptr_sync==g_rptr_next)
        empty<=1;
      else
        empty<=0;
    end
endmodule