module tb_RISC_V_1
();

reg clk, reset;


RISC_V_Processor_1 risc_v
(
    .clk(clk),
    .reset(reset)
);

initial 
 
 begin 
  
  clk = 1'b0; 
   
  reset = 1'b1; 
   
  #10 reset = 1'b0; 
 end 
  
  
always  
 
 #5 clk = ~clk; 

endmodule // tb_RISC_V