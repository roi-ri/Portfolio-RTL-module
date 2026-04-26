module master (

    input   wire            clk, 
    input   wire            reset,
    input   wire            CKP, // Polaridad del SCK
    input   wire            CPH, // Fase del SCK
    input   wire    [7:0]   data_to_send, // Informacion que se va a enviar, recibida desde el testbench
    input   wire            MISO,
    input   wire            snr_data, // para send y revieve data
    input   wire            sor_data, // para send or recieve data
    output  reg             MOSI, 
    output  reg             SCK, 
    output  reg             CS 

); 



/*
ESTADOS DE MAQUINA DE ESTADOS
*/

localparam  IDLE            = 8'b00000001, 
            MODE_0          = 8'b00000010, 
            MODE_1          = 8'b00000100, 
            MODE_2          = 8'b00001000,     
            MODE_3          = 8'b00010000, 
            S_R_DATA        = 8'b00100000,     
            RECIEVE_DATA    = 8'b01000000, 
            SEND_DATA       = 8'b10000000; 

/*
DATOS INTERNOS DEL PROGAMA
*/

reg [1:0]  mode; 
reg [1:0]  clk_cont; 
reg [7:0]  state, next_state; 
reg [2:0]  bit_cont; 
reg [7:0]  recieved_data; //Data recivida
reg [3:0]  bits_recieved; // Contador para cantidad de bits recibidos
reg        p_SCK; // posedge SCK 
reg [3:0] SCK_cont; 
reg       stop_cond; 




always @(posedge clk or posedge reset) begin 
    if (!reset) begin 
        state <= IDLE; 
        stop_cond <= 0; 
        SCK_cont <= 4'b0000;
        clk_cont <= 2'b0; 
        recieved_data <= 8'b00000000; 
        bit_cont <= 3'b111;
        CS <= 1; 
        mode <= 2'b00; // valor determinista tras reset
    end else begin 
        state <= next_state;

        // Para crear el SCK con una frecuencia de 25% de clk
        if(!CS) begin 
            if (clk_cont == 2'b11) begin 
                clk_cont <= 2'b00; 
                SCK <= ~SCK; // cambia cada 4 ciclos de clk 
            end else begin 
                clk_cont <= clk_cont + 1; 
            end 
        end
        // Asignacion del SCK IDLE segun cada modo
        if (state == IDLE) begin 
            CS <= 1; 
            if (mode == 2'b00 || mode == 2'b01) begin 
                SCK <= 0; 
            end else if (mode == 2'b10 || mode == 2'b11) begin 
                SCK <= 1;
            end 
            if (mode == 2'b00) begin
                p_SCK <= 1; 
            end else if (mode == 2'b01)begin
                p_SCK <= 0; 
            end else if (mode == 2'b10) begin
                p_SCK <= 0; 
            end else if (mode == 2'b11) begin 
                p_SCK <= 1; 
            end 
        end 
    end 



end



// Bloque combinacional
always @(*) begin 
    next_state = state;
    case(state) 
        IDLE:begin 
                recieved_data = 8'b00000000; 
            if (CKP == 0) begin 
                if(CPH == 0) begin 
                    next_state = MODE_0; 
                    mode = 2'b00;
                end else if (CPH == 1) begin 
                    next_state = MODE_1;
                    mode = 2'b01;
                end 
            end else if (CKP == 1) begin 
                if(CPH == 0) begin 
                    next_state = MODE_2;
                    mode = 2'b10;
                end else if (CPH == 1) begin 
                    next_state = MODE_3;
                    mode = 2'b11;
                end 
            end else 
                next_state = IDLE; 
        end 

        MODE_0:begin
            CS  = 0;
            if (snr_data == 1) begin 
                next_state = S_R_DATA;
            end else if (snr_data == 0) begin 
                if(sor_data == 1) begin 
                    next_state = SEND_DATA;  
                end else if(sor_data == 0) begin 
                    next_state = RECIEVE_DATA;
                end else 
                    next_state = MODE_0; 
            end 
        end 
        MODE_1:begin
            CS  = 0;
            if (snr_data == 1) begin 
                next_state = S_R_DATA;
            end else if (snr_data == 0) begin 
                if(sor_data == 1) begin 
                    next_state = SEND_DATA;  
                end else if(sor_data == 0) begin 
                    next_state = RECIEVE_DATA;
                end else 
                    next_state = MODE_0; 
            end 
        end 

        MODE_2:begin 
            CS  = 0;
            if (snr_data == 1) begin 
                next_state = S_R_DATA;
            end else if (snr_data == 0) begin 
                if(sor_data == 1) begin 
                    next_state = SEND_DATA;  
                end else if(sor_data == 0) begin 
                    next_state = RECIEVE_DATA;
                end else 
                    next_state = MODE_0; 
            end 
        end 

        MODE_3:begin 
            CS  = 0; 
            if (snr_data == 1) begin 
                next_state = S_R_DATA;
            end else if (snr_data == 0) begin 
                if(sor_data == 1) begin 
                    next_state = SEND_DATA;  
                end else if(sor_data == 0) begin 
                    next_state = RECIEVE_DATA;
                end else 
                    next_state = MODE_0; 
            end 
        end 

        S_R_DATA:begin 
            if (stop_cond == 1) begin 
                next_state = IDLE; 
            end 
        end 
         

        RECIEVE_DATA:begin 
            if (stop_cond == 1) begin 
                next_state = IDLE; 
            end 
        end 

        
        SEND_DATA:begin 
            if (stop_cond == 1) begin 
                next_state = IDLE; 
            end     
        end
        
        default: next_state = IDLE; 
    endcase 
end


always @(posedge CS) begin 
    if (mode == 2'b00) begin
        SCK <= 0; 
    end else if (mode == 2'b01)begin
        SCK <= 0; 
    end else if (mode == 2'b10) begin
        SCK <= 1; 
    end else if (mode == 2'b11) begin 
        SCK <= 1;
    end   

end


always @(posedge SCK) begin
    if(CS == 0) begin 
        if (p_SCK == 0) begin
            // Si está en modo envío o envío/recepción simultánea
            if (state == S_R_DATA || state == SEND_DATA) begin
                MOSI <= data_to_send[bit_cont];   // Enviar bit actual
            end
        end

        if (p_SCK == 1) begin
            if (state == S_R_DATA || state == RECIEVE_DATA) begin
                MOSI <= data_to_send[bit_cont];
                recieved_data[bit_cont] <= MISO;   // Leer bit recibido
                bit_cont <= bit_cont - 1;          // Decrementar posición
                bits_recieved <= bits_recieved + 1;
            end
            SCK_cont <= SCK_cont + 1;
        end
    end 
    if (SCK_cont == 4'b1000) begin
        stop_cond <= 1;
    end else begin
        stop_cond <= 0;
    end
end



always @(negedge SCK) begin
    if (CS == 0) begin 
        if (p_SCK == 1) begin
            if (state == S_R_DATA || state == SEND_DATA) begin
                MOSI <= data_to_send[bit_cont];   // Enviar bit actual
            end
        end

        if (p_SCK == 0) begin
            if (state == S_R_DATA || state == RECIEVE_DATA) begin
                recieved_data[bit_cont] <= MISO;  // Leer bit recibido
                bit_cont <= bit_cont - 1;
                bits_recieved <= bits_recieved + 1;
            end
            SCK_cont <= SCK_cont + 1;
        end


        if (SCK_cont == 4'b1000) begin
            stop_cond <= 1;
        end else begin
            stop_cond <= 0;
        end
    end
end 

always @(negedge CS) begin
    // Usamos asignaciones blocking para que la precarga sea determinista
    bit_cont  = 3'd7;      // arranca en MSB SIEMPRE
    SCK_cont  = 4'd0;
    stop_cond = 1'b0;

    // Asegurar p_SCK conocido antes de que SCK empiece a togglear
    if (CKP == 1'b0) begin
        if (CPH == 1'b0) p_SCK = 1; else p_SCK = 0;
    end else begin
        if (CPH == 1'b0) p_SCK = 0; else p_SCK = 1;
    end

    // Precargar el MSB directamente (evita indexar con bit_cont no actualizado)
    if (CPH == 1'b0) // solo precargar en modos CPHA=0 (modo 0 y 2)
        MOSI = data_to_send[3'd7];
end

endmodule