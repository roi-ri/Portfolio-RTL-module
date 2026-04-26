module BUF(A, Y);
  input A;
  output Y;
  assign #0.2 Y = A;  // Retardo de 0.2ns
endmodule

module NOT(A, Y);
  input A;
  output Y;
  assign #0.1 Y = ~A;  // Retardo de 0.1ns
endmodule

module NAND(A, B, Y);
  input A, B;
  output Y;
  assign #0.3 Y = ~(A & B);  // Retardo de 0.3ns
endmodule

module NOR(A, B, Y);
  input A, B;
  output Y;
  assign #0.3 Y = ~(A | B);  // Retardo de 0.3ns
endmodule

module DFF(C, D, Q);
  input C, D; 
  output reg Q;
  always @(posedge C) #0.5 Q <= D;  // Retardo de 0.5ns en el flip-flop
endmodule