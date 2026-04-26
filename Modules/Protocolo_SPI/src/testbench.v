`timescale 1ns/1ps
`include "Master_SPI.v"
`include "Slave_1_SPI.v"
`include "Slave_2_SPI.v"
`include "tester.v"


module SPI_tb; 

    wire            clk; 
    wire            reset;
    wire            CKP; // Polaridad del SCK
    wire            CPH; // Fase del SCK

    // PAra definir que se va a enviar hacia slave 1 o Slave 2, esto lo recibe master
    wire    [7:0]   data_to_send; // Informacion que se va a enviar
    
    // Para definir que se va a enviar hacia el master, esto lo recibe Slave 1 
    wire    [7:0]   data_out;
    
    wire            MISO_1;
    wire            MOSI; 
    wire            SCK; 
    wire            CS; 
    wire            snr_data; // para send y revieve data
    wire            sor_data; // para send or recieve data

probador P0(
    .clk(clk), 
    .reset(reset), 
    .CKP(CKP), 
    .CPH(CPH), 
    .sor_data(sor_data), 
    .snr_data(snr_data), 
    .data_to_send(data_to_send), 
    .data_out(data_out), 
    .MOSI(MOSI), 
    .MISO_1(MISO_1),  
    .SCK(SCK), 
    .CS(CS)
); 

master master_tb(
    .clk(clk), 
    .reset(reset), 
    .CKP(CKP), 
    .CPH(CPH), 
    .data_to_send(data_to_send), 
    .MISO(MISO),  
    .MOSI(MOSI), 
    .snr_data(snr_data),
    .sor_data(sor_data),
    .SCK(SCK), 
    .CS(CS)
);

slave_1 slave_1_tb(
    .CKP(CKP), 
    .CPH(CPH), 
    .data_out(data_out), 
    .MISO(MISO_1), 
    .MOSI(MOSI), 
    .SCK(SCK), 
    .SS(CS)
);

slave_2 slave_2_tb(
    .CKP(CKP), 
    .CPH(CPH), 
    .data_out(data_out), 
    .MISO(MISO), 
    .MOSI(MISO_1), 
    .SCK(SCK), 
    .SS(CS)
); 


    // Dump y control de simulación
    initial begin
        $dumpfile("resultados.vcd");
        $dumpvars(0, SPI_tb);
        $display("Simulación SPI iniciada");
    end

endmodule
