// Modulo del controlador del cajero
module Controlador(
    // Entradas 
    input   clk,
    input  reset, 
    input   TARJETA_RECIBIDA,
    input   TIPO_TRANS,
    input   DIGITO_STB, 
    input    MONTO_STB,
    input   [3:0]  DIGITO, 
    input   [15:0] PIN_CORRECTO, 
    input   [31:0] MONTO, 
    input   [63:0] BALANCE_INICIAL, 
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
reg [1:0]   state, next_state;
reg [15:0]  PIN_INGRESADO; //PARA COMPARAR CON PIN CORRECTO
reg [1:0]   contador_pin; 
reg [3:0]   contador_monto; 
reg [1:0]   cont_errores; 


// Declaracion para el cambio de estado y por si se llega a accionar el RESET

always @(posedge clk || reset) begin

    if (!reset) begin
        state <= ESPERANDO_TARJETA;
        PIN_INGRESADO <= 16'b0; // Resetear pin ingresado
        contador_pin <= 2'b0; // Resetear contador de pin
        contador_monto <= 4'b0; // Resetear contador de monto
        cont_errores <= 2'b0; // Resetear contador de errores
    end else begin
        state <= next_state;
    end

    if (DIGITO_STB && state == ESPERANDO_PIN) begin
        PIN_INGRESADO <= {PIN_INGRESADO[11:0], DIGITO};
        contador_pin <= contador_pin + 1; // Aumentar el valor de contador para que cuando llegue a 4 -> 2'b11 (4 digitos ingresados)
    end

    // Señales de salida

    if (state == E_FONDOS_INSUFICIENTES) begin 
        FONDOS_INSUFICIENTES = 1; 
    end 
    
    if (state == ENTREGANDO_DINERO) begin
        ENTREGA_DINERO = 1; 
    end 

    if (sate == E_ADVERTENCIA) begin
        ADVERTENCIA = 1; 
    end

    if (state = ACTUALIZAR_REGISTRO_BALANCE && !TIPO_TRANS) begin 
        BALANCE_STB = 1; 
    end 



end


always @(*) begin
    next_state = state; 
    PIN_INGRESADO   = 16'b0; // Resetear pin ingresado
    contador_pin    = 2'b0; // Resetear contador de pin
    contador_monto  = 4'b0; // Resetear contador de monto
    cont_errores    = 2'b0; // Resetear contador de errores

    case (state)
        ESPERANDO_TARJETA: begin
            next_state = (TARJETA_RECIBIDA) ? ESPERANDO_PIN : ESPERANDO_TARJETA;
        end
        ESPERANDO_PIN: begin
            if (contador_pin == 2'b11) begin
                if (PIN_INGRESADO == PIN_CORRECTO) begin
                    next_state = (TIPO_TRANS) ? RETIRO : DEPOSITO;
                    cont_errores = 2'b00; // Resetear errores si acierta
                end else begin
                    case (cont_errores)
                        2'b01: next_state = PIN_INCORRECTO_1;
                        2'b10: next_state = PIN_INCORRECTO_2;
                        2'b11: next_state = BLOQUEO;
                        default: next_state = ESPERANDO_PIN; 
                    endcase
                end 
            end 
        end

        PIN_INCORRECTO_1:  begin // ERROR 1
            next_state = ESPERANDO_PIN;
        end
        PIN_INCORRECTO_2: begin // ERROR 2
            next_state = ADVERTENCIA;
        end 
        ADVERTENCIA: begin 
            next_state = ESPERANDO_PIN;
        end 
        BLOQUEO: begin 
            if (reset == 0) begin
                if (reset == 1) begin
                    next_state <= ESPERANDO_TARJETA;
                end else begin 
                    state <= BLOQUEO;
                end 
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
                    BALANCE_ACTUALIZADO = BALANCE_ACTUALIZADO - MONTO;
                    next_state = E_FONDOS_INSUFICIENTES;
                end else if (MONTO <= BALANCE_INICIAL) begin 
                    BALANCE_ACTUALIZADO = BALANCE_INICIAL + MONTO; 
                    next_state = ACTUALIZAR_REGISTRO_BALANCE; 
                end 
            end else if (!TIPO_TRANS && MONTO_STB) begin  // DEPOSITO
                    BALANCE_ACTUALIZADO = BALANCE_INICIAL + MONTO; 
            end else begin 
                next_state = ESPERANDO_MONTO;
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