`timescale 1ns/1ps
`include "Generator_I2C.v"
`include "Slave_I2C.v"
`include "tester.v"

module I2C_tb;

    // Señales globales y de control
    wire        clk;
    wire        reset;
    wire        START_STB;
    wire        RNW;
    wire [6:0]  I2C_ADDR;
    wire [15:0] WR_DATA_master;
    wire [15:0] RD_DATA_master;

    // Señales de reloj I2C
    wire SCL;

    // Señales SDA del master (salidas del Master)
    wire SDA_OUT_master;
    wire SDA_OE_master;

    // Señal que el slave pone en la línea (salida del Slave)
    wire SDA_slave_drive;

    // Bus SDA modelado (open-drain): 0 si cualquiera tira a 0, 1 si ninguno tira
    wire SDA_bus;
    assign SDA_bus = ((SDA_OE_master && (SDA_OUT_master == 1'b0)) || (SDA_slave_drive == 1'b0)) ? 1'b0 : 1'b1;

    // Datos que el slave debe devolver en lectura (constante para TB)
    wire [15:0] RD_DATA_slave = 16'hB24F;


    probador P0 (
        .clk      (clk),
        .reset    (reset),
        .START_STB(START_STB),
        .RNW      (RNW),
        .I2C_ADDR (I2C_ADDR),
        .WR_DATA  (WR_DATA_master),
        .RD_DATA  (RD_DATA_master),
        .SCL      (SCL),
        .SDA_bus  (SDA_bus)
    );

    // Instancia del Master (Generator)
    Generator_I2C Master (
        .clk      (clk),
        .reset    (reset),
        .RNW      (RNW),
        .I2C_ADDR (I2C_ADDR),
        .WR_DATA  (WR_DATA_master),
        .START_STB(START_STB),
        .SDA_IN   (SDA_bus),        // master lee el bus
        .RD_DATA  (RD_DATA_master),
        .SDA_OUT  (SDA_OUT_master), // maestro intenta conducir
        .SDA_OE   (SDA_OE_master),
        .SCL      (SCL)
        
    );

    // Instancia del Slave (puertos según Slave_I2C.v)
    Slave_I2C Slave (
        .clk       (clk),
        .reset     (reset),
        .SCL       (SCL),
        .SDA_bus   (SDA_bus),         
        .RD_DATA   (RD_DATA_slave),   // datos a enviar en lectura
        .SDA_drive (SDA_slave_drive), // salida del slave hacia el bus (0 = pull low, 1 = release)
        .WR_DATA   ()                
    );

    // Dump y control de simulación
    initial begin
        $dumpfile("resultados.vcd");
        $dumpvars(0, I2C_tb);
        $display("Simulación I2C iniciada");
    end

endmodule
