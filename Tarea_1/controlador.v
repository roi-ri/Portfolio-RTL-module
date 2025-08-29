// Modulo del controlador del cajero
module Controlador(
    // Entradas 
    input clk; 
    input reset; 
    input TARJETA_RECIBIDA;
    input TIPO_TRASN;
    input DIGITO_STB; 
    input [3:0]  DIGITO; 
    input [15:0] PIN_CORRECTO; 
    input MONTO_STB;
    input [31:0] MONTO; 
    input [63:0] BALANCE_INICIAL; 

    // Salidas 
    output BALANCE_STB; 
    output [63:0] BALANCE_ACTUALIZADO;
    output ENTREGA_DINERO; 
    output PIN_INCORRECTO; 
    output ADVERTENCIA; 
    output BLOQUEO; 
    output FONDOS_INSUFICIENTES;
);

// Definicion de estados 
localparam  PIN_CORRECTO                = 16'b7259, //PIN CORRECTO DESIGNADO 
            ESPERANDO_TARJETA           = 4'b0001,
            ESPERANDO_PIN               = 4'b0010,
            BLOQUEO                     = 4'b0101,
            ADVERTENCIA                 = 4'b0110,
            RETIRO                      = 4'b0111,
            ESPERANDO_MONTO             = 4'b1000,
            FONDOS_INSUFICIENTES        = 4'b1001,
            ACTUALIZAR_REGISTRO_BALANCE = 4'b1010,
            ENTREGA_DINERO              = 4'b1011,
            DEPOSITO                    = 4'b1100,
            PIN_INCORRECTO_1            = 4'b1101,
            PIN_INCORRECTO_2            = 4'b1110;


// regs para almacenar cuentas o numeros 
reg [1:0] state, next_state;
reg [15:0] PIN_INGRESADO; //PARA COMPARAR CON PIN CORRECTO
reg [1:0] contador_pin; 
reg [3:0] contador_monto; 
reg [1:0] cont_errores; 

// Declaracion para el cambio de estado y por si se llega a accionar el RESET

always @(posedge clk or posedge reset) begin

    if (!reset) begin
        state <= ESPERANDO_TARJETA;
        PIN_INGRESADO <= 16'b0; // Resetear pin ingresado
        contador_pin <= 2'b0; // Resetear contador de pin
        contador_monto <= 4'b0; // Resetear contador de monto
        cont_errores <= 2'b0; // Resetear contador de errores
    end else begin
        state <= next_state;
    end

    // Para cada que se reciba DIGITO_STB y esté en el estado de ESPERANDO_PIN
    if (DIGITO_STB && state == ESPERANDO_PIN) begin
        PIN_INGRESADO <= {PIN_INGRESADO[11:0], DIGITO};
        contador_pin <= contador_pin + 1; // Aumentar el valor de contador para que cuando llegue a 4 -> 2'b11 (4 digitos ingresados)
    end

    // Para cada que se reciba DIGITO_STB y esté en el estado de ESPERANDO_MONTO
    if (DIGITO_STB && state == ESPERANDO_MONTO) begin
        MONTO <= {MONTO[27:0], DIGITO};
        contador_monto <= contador_monto + 1; // Aumentar el valor de contador para que cuando llegue a 8 -> 4'b1000 (8 digitos ingresados)
    end

    if (state == BLOQUEO) begin
        if (reset == 0) begin
            if (reset == 1)
                next_state = ESPERANDO_TARJETA;
        end
    end
end


always @(*) begin
    case (state)
        ESPERANDO_TARJETA: begin
            if (TARJETA_RECIBIDA)
                next_state = ESPERANDO_PIN; 
            else
                next_state = ESPERANDO_TARJETA;
        end 
        ESPERANDO_PIN: begin
            if (DIGITO_STB) begin
                if (contador_pin == 2'b11) begin
                    if (PIN_INGRESADO == PIN_CORRECTO) begin
                        next_state = RETIRO;
                        cont_errores <= 2'b00; // Resetear errores si acierta
                    end else begin
                        cont_errores <= cont_errores + 1; // Aumenta errores
                        if (cont_errores)
                            next_state = PIN_INCORRECTO_1; // Primer error
                        else if (cont_errores == 2'b10)      // Segundo error
                            next_state = ADVERTENCIA;
                        else if (cont_errores == 2'b11) // Tercer error
                            next_state = BLOQUEO;
                        end
                end else begin
                    next_state = ESPERANDO_PIN; // Si el contador de digitos aun no esta en 2'b11 sigue esperando pin
                end
            end
        end 

        PIN_INCORRECTO_1:  // ERROR 1
            next_state = ESPERANDO_PIN;

        PIN_INCORRECTO_2:  // ERROR 2 
            next_state = ADVERTENCIA;

        ADVERTENCIA: 
            next_state = ESPERANDO_PIN;



end