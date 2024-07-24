module cpu_test;
  reg clk,reset;
  wire [7:0] w_q;
  CPU cl(clk,reset,w_q);
  always #5 clk = ~clk;
  
  initial 
  begin
        clk = 0;
        reset = 1;
    #10 reset = 0;
    #2000000 $stop;
  end
endmodule