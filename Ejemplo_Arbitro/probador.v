module probador (
  clock, 
  reset, 
  req0,
  req1, 
  gnt0,
  gnt1);

  output clock, reset, req0, req1;
  input gnt0, gnt1;

  wire gnt0, gnt1;
  reg clock, reset, req0, req1;

  initial begin
    clock = 0;
    reset = 0;
    req0 = 0;
    req1 = 0;
    #5 reset = 1;
    #15 reset = 0;
    #20 req0 = 1;
    #20 req0 = 0;
    #20 req1 = 1;
    #20 req1 = 0;
    #20 {req0,req1} = 2'b11;
    #20 {req0,req1} = 2'b00;
    #200 $finish;
  end

  always begin
    #5 clock = !clock;
  end

endmodule
