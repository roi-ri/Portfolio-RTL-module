module slave_2 (

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



// Bloques utilizados para enviar datos o recibir
always @(posedge SCK) begin 
    if (p_SCK == 1 && SS == 0) begin 
        //Envio
        MISO <= data_out[bit_cont]; 
        bit_cont <= bit_cont - 1; 
        // Si tambien tiene que recibir
        data_in <= MOSI;
        bits_recieved <= bits_recieved + 1; 
    end
end 


always @(negedge SCK) begin 
    if (p_SCK == 0 && SS == 0) begin 
        //Envio
        MISO <= data_out[bit_cont]; 
        bit_cont <= bit_cont - 1; 
        // Si tambien tiene que recibir
        data_in <= MOSI;
        bits_recieved <= bits_recieved + 1;  
    end 
end 



always @(posedge SS) begin 
    case ({CKP, CPH})
        2'b00: p_SCK <= 1;  // Modo 0
        2'b01: p_SCK <= 0;  // Modo 1
        2'b10: p_SCK <= 0;  // Modo 2
        2'b11: p_SCK <= 1;  // Modo 3
        default: p_SCK <= 1'bx;
    endcase
end


endmodule