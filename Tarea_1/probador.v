module probador (
    output reg   clk,
    output reg   reset, 
    output reg   TARJETA_RECIBIDA,
    output reg   TIPO_TRANS,
    output reg   DIGITO_STB, 
    output reg    MONTO_STB,
    output reg   [3:0]  DIGITO, 
    output reg   [15:0] PIN_CORRECTO, 
    output reg   [31:0] MONTO, 
    output reg   [63:0] BALANCE_INICIAL, 
    // Salidas 
    input wire BALANCE_STB, 
    input wire ENTREGA_DINERO, 
    input wire PIN_INCORRECTO, 
    input wire ADVERTENCIA, 
    input wire BLOQUEO, 
    input wire FONDOS_INSUFICIENTES,
    input wire [63:0] BALANCE_ACTUALIZADO

)


initial begin 
    clk                  = 0; 
    reset                = 1;
    BALANCE_STB          = 0;
    ENTREGA_DINERO       = 0;
    PIN_INCORRECTO       = 0;
    ADVERTENCIA          = 0;
    BLOQUEO              = 0;
    FONDOS_INSUFICIENTES = 0;









end 



always begin 
    #10 clk = !clk 
end


endmodule