module probador (
    output reg clk,
    output reg reset,
    output reg TARJETA_RECIBIDA,
    output reg TIPO_TRANS,
    output reg DIGITO_STB,
    output reg MONTO_STB,
    output reg [3:0] DIGITO,
    output reg [15:0] PIN_CORRECTO,
    output reg [31:0] MONTO,
    output reg [63:0] BALANCE_INICIAL,
    input wire [63:0] BALANCE_ACTUALIZADO,
    input wire BALANCE_STB,
    input wire ENTREGA_DINERO,
    input wire PIN_INCORRECTO,
    input wire ADVERTENCIA,
    input wire BLOQUEO,
    input wire FONDOS_INSUFICIENTES
);

initial begin
    clk = 0;
    reset = 0;
    TARJETA_RECIBIDA = 0;
    DIGITO_STB = 0;
    MONTO_STB = 0;
    PIN_CORRECTO = 16'h7259;
    MONTO = 0;
    BALANCE_INICIAL = 64'd500000;

    #10 reset = 1;

// -------------------------------------------------------
    // PRUEBA 1 
    // Inserta tarjeta
    #10 TARJETA_RECIBIDA = 1;
    #10 TARJETA_RECIBIDA = 0;

    // Ingreso de PIN: 7
    #10 DIGITO = 4'b0111; DIGITO_STB = 1;
    #10 DIGITO_STB = 0;

    // Ingreso de PIN: 2
    #10 DIGITO = 4'b0010; DIGITO_STB = 1;
    #10 DIGITO_STB = 0;

    // Ingreso de PIN: 5
    #10 DIGITO = 4'b0101; DIGITO_STB = 1;
    #10 DIGITO_STB = 0;

    // Ingreso de PIN: 9
    #10 DIGITO = 4'b1001; DIGITO_STB = 1;
    #10 DIGITO_STB = 0;

    
    #5 TIPO_TRANS = 0;

    // Ingresa monto
    #10 MONTO = 32'd50000;
    #5 MONTO_STB = 1;
    #10 MONTO_STB = 0;
    
    //reset 
    #50 reset = 0; 
    #5 reset = 1; 
    // PRUEBA 2
    
    // Inserta tarjeta
    #10 TARJETA_RECIBIDA = 1;
    #10 TARJETA_RECIBIDA = 0;

    // Ingreso de PIN: 7
    #10 DIGITO = 4'b0111; DIGITO_STB = 1;
    #10 DIGITO_STB = 0;

    // Ingreso de PIN: 2
    #10 DIGITO = 4'b0010; DIGITO_STB = 1;
    #10 DIGITO_STB = 0;

    // Ingreso de PIN: 5
    #10 DIGITO = 4'b0101; DIGITO_STB = 1;
    #10 DIGITO_STB = 0;

    // Ingreso de PIN: 9
    #10 DIGITO = 4'b1001; DIGITO_STB = 1;
    #10 DIGITO_STB = 0;

   
    #5 TIPO_TRANS = 1;

    // Ingresa monto
    #10 MONTO = 32'd50000;
    #5 MONTO_STB = 1;
    #10 MONTO_STB = 0;


    //reset 
    #50 reset = 0; 
    #5 reset = 1; 

// -------------------------------------------------------
    // PRUEBA 2
    
    BALANCE_INICIAL = 64'd500000;
    // Inserta tarjeta
    #10 TARJETA_RECIBIDA = 1;
    #10 TARJETA_RECIBIDA = 0;

    // Ingreso de PIN: 7
    #10 DIGITO = 4'b0111; DIGITO_STB = 1;
    #10 DIGITO_STB = 0;

    // Ingreso de PIN: 2
    #10 DIGITO = 4'b0010; DIGITO_STB = 1;
    #10 DIGITO_STB = 0;

    // Ingreso de PIN: 5
    #10 DIGITO = 4'b0101; DIGITO_STB = 1;
    #10 DIGITO_STB = 0;

    // Ingreso de PIN: 9
    #10 DIGITO = 4'b1001; DIGITO_STB = 1;
    #10 DIGITO_STB = 0;

    
    #5 TIPO_TRANS = 1;

    // Ingresa monto
    #10 MONTO = 32'd50000;
    #5 MONTO_STB = 1;
    #10 MONTO_STB = 0;


   //reset 
    #50 reset = 0; 
    #5 reset = 1; 

// -------------------------------------------------------
    // PRUEBA 3
    BALANCE_INICIAL = 64'd500;
    // Inserta tarjeta
    #10 TARJETA_RECIBIDA = 1;
    #10 TARJETA_RECIBIDA = 0;

    // Ingreso de PIN: 7
    #10 DIGITO = 4'b0111; DIGITO_STB = 1;
    #10 DIGITO_STB = 0;

    // Ingreso de PIN: 2
    #10 DIGITO = 4'b0010; DIGITO_STB = 1;
    #10 DIGITO_STB = 0;

    // Ingreso de PIN: 5
    #10 DIGITO = 4'b0101; DIGITO_STB = 1;
    #10 DIGITO_STB = 0;

    // Ingreso de PIN: 9
    #10 DIGITO = 4'b1001; DIGITO_STB = 1;
    #10 DIGITO_STB = 0;

    
    #5 TIPO_TRANS = 1;

    // Ingresa monto
    #10 MONTO = 32'd50000;
    #5 MONTO_STB = 1;
    #10 MONTO_STB = 0;


   //reset 
    #50 reset = 0; 
    #5 reset = 1; 


// -------------------------------------------------------

//PRUEBA 4

    // Inserta tarjeta
    #10 TARJETA_RECIBIDA = 1;
    #10 TARJETA_RECIBIDA = 0;

    // Ingreso de PIN: 7
    #10 DIGITO = 4'b0111; DIGITO_STB = 1;
    #10 DIGITO_STB = 0;

    // Ingreso de PIN: 3
    #10 DIGITO = 4'b0011; DIGITO_STB = 1;
    #10 DIGITO_STB = 0;

    // Ingreso de PIN: 5
    #10 DIGITO = 4'b0101; DIGITO_STB = 1;
    #10 DIGITO_STB = 0;

    // Ingreso de PIN: 9
    #10 DIGITO = 4'b1001; DIGITO_STB = 1;
    #10 DIGITO_STB = 0;

    // Nuevo intento de PIN

    // Ingreso de PIN: 7
    #30 DIGITO = 4'b0111; DIGITO_STB = 1;
    #10 DIGITO_STB = 0;

    // Ingreso de PIN: 3
    #10 DIGITO = 4'b0011; DIGITO_STB = 1;
    #10 DIGITO_STB = 0;

    // Ingreso de PIN: 5
    #10 DIGITO = 4'b0101; DIGITO_STB = 1;
    #10 DIGITO_STB = 0;

    // Ingreso de PIN: 9
    #10 DIGITO = 4'b1001; DIGITO_STB = 1;
    #10 DIGITO_STB = 0;

    // Nuevo intento de PIN

    // Ingreso de PIN: 7
    #30 DIGITO = 4'b0111; DIGITO_STB = 1;
    #10 DIGITO_STB = 0;

    // Ingreso de PIN: 3
    #10 DIGITO = 4'b0011; DIGITO_STB = 1;
    #10 DIGITO_STB = 0;

    // Ingreso de PIN: 5
    #10 DIGITO = 4'b0101; DIGITO_STB = 1;
    #10 DIGITO_STB = 0;

    // Ingreso de PIN: 9
    #10 DIGITO = 4'b1001; DIGITO_STB = 1;
    #10 DIGITO_STB = 0;
    
    // Reset para quitar el bloqueo. 
    #55 reset = 0; 
    #10 reset = 1; 

    // Espera a que termine la operación
    #100 $finish;
end


always begin
    #5 clk = !clk;
end


endmodule