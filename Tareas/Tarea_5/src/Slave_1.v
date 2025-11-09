module slave_1 (

    input   wire                 CKP, // Polaridad del SCK, lo estoy viendo como un cable conectado de manera externa hacia el master y slaves
    input   wire                 CPH, // Fase del SCK, lo estoy viendo como un cable conectado de manera externa hacia el master y slaves
    input   wire    [7:0]        data_out, // Informacion que se va a enviar, recibida desde el testbench
    input   wire                 MOSI, 
    input   wire                 SCK, 
    input   wire                 SS, 
    output  reg                  MISO
); 



/*
DATOS INTERNOS DEL PROGAMA
*/           
reg [1:0]  mode;
reg [7:0]  data_in;     // Data que recibe
reg [2:0]  bit_cont;
reg        p_SCK;  // psedge SCK
reg [3:0]  bits_recieved;








always @(posedge SCK) begin
    if (SS == 0 && p_SCK == 0) begin
        MISO <= data_out[bit_cont];
    end
    if (p_SCK == 1 && SS == 0) begin 
        data_in[bit_cont] <=  MOSI;
        bit_cont <= bit_cont - 1; 
        bits_recieved <= bits_recieved + 1; 
    end
end

always @(negedge SCK) begin
    if (SS == 0 && p_SCK == 1) begin
        MISO <= data_out[bit_cont];
    end
    if (p_SCK == 0 && SS == 0) begin 
        data_in[bit_cont] <=  MOSI;
        bit_cont <= bit_cont - 1; 
        bits_recieved <= bits_recieved + 1;  
    end 
end


// COMO un reset
always @(posedge SS) begin 
    data_in <= 8'b0000000;
    bit_cont <= 3'b111; 
    bits_recieved <= 4'b0000;
end


// ACTIVACION
always @(negedge SS) begin 
    data_in <= 8'b0000000;
    MISO <= data_out[3'b111];
    if (CKP == 0) begin 
        if(CPH == 0) begin 
            p_SCK <= 1;  // MODO 0
        end else if (CPH == 1) begin 
            p_SCK <= 0; // MODO 1 
        end 
    end else if (CKP == 1) begin 
        if(CPH == 0) begin 
            p_SCK <= 0; // MODO_2
        end else if (CPH == 1) begin 
            p_SCK <= 1; // MODO_3
        end 
    end
end 


endmodule