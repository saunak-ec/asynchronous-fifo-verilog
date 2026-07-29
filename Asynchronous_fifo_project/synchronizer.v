// synchronizer for asynchronous FIFO
//description: a 2 stage flop synchronizer for clock domain crossing in asynchronous fifo,it mitigates metastability by allowing signals form source clock domain to settle before being used in destination clock domain
module synchronizer(clk,rst_n,din,dout);
  parameter data_width=4; //width of data bus to be synchronized
  // ports
  input clk;     //destination clock domain
  input rst_n;   //active-low reset input
  input[data_width-1:0] din;  //asynchronous input
  output reg[data_width-1:0] dout;  //synchronized output
  // internal signals
  reg [data_width-1:0] w;  //wire connceting the 2 flops to mitigate metastability
  always @ (posedge clk or negedge rst_n)  //asynchronous reset
    if(!rst_n)  
      begin
        w<=0;
        dout<=0;
      end
    else 
      begin
        w<=din;
        dout<=w;
      end
endmodule
      