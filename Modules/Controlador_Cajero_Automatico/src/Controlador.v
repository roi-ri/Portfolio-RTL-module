// Modulo del controlador del cajero
module Controlador(
    // Entradas 
    input wire  clk,
    input wire  reset, 
    input wire  TARJETA_RECIBIDA,
    input wire  TIPO_TRANS,
    input wire  DIGITO_STB, 
    input wire   MONTO_STB,
    input wire  [3:0]  DIGITO, 
    input wire  [15:0] PIN_CORRECTO, 
    input wire  [31:0] MONTO, 
    input wire  [63:0] BALANCE_INICIAL, 
    // Salidas 
    output reg BALANCE_STB, 
    output reg ENTREGA_DINERO, 
    output reg PIN_INCORRECTO, 
    output reg ADVERTENCIA, 
    output reg BLOQUEO, 
    output reg FONDOS_INSUFICIENTES,
    output reg [63:0] BALANCE_ACTUALIZADO
);

// Definicion de estados 
localparam  ESPERANDO_TARJETA           = 12'b000000000001, 
            ESPERANDO_PIN               = 12'b000000000010,
            BLOQUEADO                   = 12'b000000000100,
            E_ADVERTENCIA               = 12'b000000001000,
            RETIRO                      = 12'b000000010000,
            ESPERANDO_MONTO             = 12'b000000100000,
            E_FONDOS_INSUFICIENTES      = 12'b000001000000,
            ACTUALIZAR_REGISTRO_BALANCE = 12'b000010000000,
            ENTREGANDO_DINERO           = 12'b000100000000,
            DEPOSITO                    = 12'b001000000000,
            PIN_INCORRECTO_1            = 12'b010000000000,
            PIN_INCORRECTO_2            = 12'b100000000000;


// Datos internos del programa 
reg [11:0]  state, next_state;
reg [15:0]  PIN_INGRESADO; 
reg [2:0]   contador_pin; 
reg [1:0]   cont_errores; 
reg         reset_prev; 


always @(posedge clk or negedge reset) begin
    
    if (!reset) begin
        state               <= ESPERANDO_TARJETA;
        contador_pin        <= 2'b0;
        cont_errores        <= 3'b0; 
        BALANCE_ACTUALIZADO <= 64'b0;
        BALANCE_STB         <= 0;
        ENTREGA_DINERO      <= 0;
        PIN_INCORRECTO      <= 0;
        ADVERTENCIA         <= 0;
        BLOQUEO             <= 0; 
        FONDOS_INSUFICIENTES<= 0;
    end else begin
        state <= next_state;
        if (next_state == ESPERANDO_TARJETA) begin
            PIN_INGRESADO <= 16'b0;
            contador_pin  <= 3'b0;
            cont_errores  <= 2'b0;
        end

        if (DIGITO_STB && state == ESPERANDO_PIN && contador_pin <= 3'b011) begin
            PIN_INGRESADO <= (PIN_INGRESADO << 4) | DIGITO;
            contador_pin  <= contador_pin + 1;
        end 



          // Actualiza balance
        if (state == ACTUALIZAR_REGISTRO_BALANCE && TIPO_TRANS) begin //Retiro
            BALANCE_ACTUALIZADO <= BALANCE_INICIAL - MONTO;
        end else if (state == ACTUALIZAR_REGISTRO_BALANCE && !TIPO_TRANS) begin //Deposito
            BALANCE_ACTUALIZADO <= BALANCE_INICIAL + MONTO;
        end

        BALANCE_STB         <= (state == ACTUALIZAR_REGISTRO_BALANCE);
        ENTREGA_DINERO      <= (state == ENTREGANDO_DINERO);
        PIN_INCORRECTO      <= (state == PIN_INCORRECTO_1 || state == PIN_INCORRECTO_2);
        ADVERTENCIA         <= (state == E_ADVERTENCIA);
        BLOQUEO             <= (state == BLOQUEADO);
        FONDOS_INSUFICIENTES<= (state == E_FONDOS_INSUFICIENTES);
    end
    
end


always @(*) begin
    next_state = state;
    case (state)
        ESPERANDO_TARJETA: begin
            next_state = (TARJETA_RECIBIDA) ? ESPERANDO_PIN : ESPERANDO_TARJETA;
        end
        ESPERANDO_PIN: begin
            if (contador_pin == 3'b100) begin
                if (PIN_INGRESADO == PIN_CORRECTO) begin
                    next_state = (TIPO_TRANS) ? DEPOSITO : RETIRO ;
                end else begin
                    cont_errores = cont_errores + 1;
                    case (cont_errores)
                        2'b01: next_state = PIN_INCORRECTO_1;
                        2'b10: next_state = PIN_INCORRECTO_2;
                        2'b11: next_state = BLOQUEADO;
                        default: next_state = ESPERANDO_PIN; 
                    endcase
                end 
            end 
        end

        PIN_INCORRECTO_1:  begin // ERROR 1
            PIN_INGRESADO = 3'b0;
            contador_pin  = 2'b0; 
            next_state = ESPERANDO_PIN;
        end
        PIN_INCORRECTO_2: begin // ERROR 2
            PIN_INGRESADO = 3'b0;
            contador_pin  = 2'b0; 
            next_state = E_ADVERTENCIA;
        end 
        E_ADVERTENCIA: begin 
            next_state = ESPERANDO_PIN;
        end 
        BLOQUEO: begin
         // Detecta flanco de subida: reset_prev = 0 y reset = 1
        if (reset_prev == 0 && reset == 1) begin
            next_state = ESPERANDO_TARJETA;
            end else begin
                next_state = BLOQUEO;
            end
        end

        RETIRO: begin
            next_state = ESPERANDO_MONTO;
        end
        DEPOSITO: begin
            next_state = ESPERANDO_MONTO;
        end

        E_FONDOS_INSUFICIENTES: begin 
            next_state = ESPERANDO_TARJETA; 
        end 

        ESPERANDO_MONTO: begin 
            // Para actualizar los balances cuando los montos sean correctos 
            if (TIPO_TRANS && MONTO_STB) begin //RETIRO
                if (MONTO > BALANCE_INICIAL) begin 
                    next_state = E_FONDOS_INSUFICIENTES;
                end else if (MONTO <= BALANCE_INICIAL) begin 
                    next_state = ACTUALIZAR_REGISTRO_BALANCE; 
                end 
            end else if (TIPO_TRANS == 0 && MONTO_STB) begin  // DEPOSITO
                    next_state = ACTUALIZAR_REGISTRO_BALANCE;
            end else begin 
                next_state = ESPERANDO_MONTO;
            end 
        end 
        ACTUALIZAR_REGISTRO_BALANCE: begin 
            if (TIPO_TRANS)begin 
                next_state = ENTREGANDO_DINERO; 
            end else if (!TIPO_TRANS) begin 
                next_state = ESPERANDO_TARJETA;
            end 
        end
        
        ENTREGANDO_DINERO: begin 
            next_state = ESPERANDO_TARJETA; 
        end 

    endcase

end

endmodule