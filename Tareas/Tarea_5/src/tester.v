module probador(
    output reg        clk,
    output reg        reset,
    output reg        CKP,
    output reg        CPH,
    output reg [7:0]  data_out,      // enviado por los slaves
    output reg [7:0]  data_to_send,  // enviado por el master
    output reg        snr_data,      // para send y receive data
    output reg        sor_data,      // para send or receive data
    input  wire       MISO,
    input  wire       MOSI,
    input  wire       SCK,
    input  wire       MISO_1,
    input  wire       MISO_2,
    input  wire       CS
);

    // ------------------------------------------------------------------
    // EStimulo inicial y secuencias de prueba (modos SPI 0..3)
    // Mantengo los comentarios originales, solo limpie formato y tiempos
    // SCK period / timing: usamos #640 para la ventana de byte (8 flancos * 80)
    // ------------------------------------------------------------------

    initial begin
        clk = 0;
        reset = 0;

        #10;
        reset = 1;
        #10;

        // ------------------------------------------------------------------
        // Modo 0  (CKP=0, CPH=0) - primer par de transferencias
        // Envio: 7   (8'b0000_0111)
        // Recibo: 5 (8'b0000_0101)
        // ------------------------------------------------------------------
        data_to_send = 8'b0000_0111; // primer dato a enviar (M->S)
        data_out     = 8'b0000_0101; // dato que el slave devuelve (S->M)
        snr_data     = 1;

        CKP = 'x; CPH = 'x;         // poner X antes de cambiar el modo
        #10;
        CKP = 0; CPH = 0;

        #640; // ventana de transferencia (8 flancos * 80)

        // segunda transferencia en el mismo modo
        data_to_send = 8'b0000_0010; // 2
        data_out     = 8'b0000_1001; // 9

        CKP = 'x; CPH = 'x;
        #10;
        CKP = 0; CPH = 0;

        #640;

        // reinicio breve entre modos
        reset = 0; #10; reset = 1; #30;

        // ------------------------------------------------------------------
        // Modo 1  (CKP=1, CPH=0)
        // ------------------------------------------------------------------
        data_to_send = 8'b0000_0111;
        data_out     = 8'b0000_0101;
        snr_data     = 1;

        CKP = 'x; CPH = 'x; #10;
        CKP = 1; CPH = 0;

        #640;

        data_to_send = 8'b0000_0010;
        data_out     = 8'b0000_1001;

        CKP = 'x; CPH = 'x; #10;
        CKP = 1; CPH = 0;

        #640;

        reset = 0; #10; reset = 1; #30;

        // ------------------------------------------------------------------
        // Modo 2  (CKP=0, CPH=1)
        // ------------------------------------------------------------------
        data_to_send = 8'b0000_0111;
        data_out     = 8'b0000_0101;
        snr_data     = 1;

        CKP = 'x; CPH = 'x; #10;
        CKP = 0; CPH = 1;

        #640;

        data_to_send = 8'b0000_0010;
        data_out     = 8'b0000_1001;

        CKP = 'x; CPH = 'x; #10;
        CKP = 0; CPH = 1;

        #660;

        reset = 0; #10; reset = 1; #30;

        // ------------------------------------------------------------------
        // Modo 3  (CKP=1, CPH=1)
        // ------------------------------------------------------------------
        data_to_send = 8'b0000_0111;
        data_out     = 8'b0000_0101;
        snr_data     = 1;

        CKP = 'x; CPH = 'x; #10;
        CKP = 1; CPH = 1;

        #640;

        data_to_send = 8'b0000_0010;
        data_out     = 8'b0000_1001;

        CKP = 'x; CPH = 'x; #10;
        CKP = 1; CPH = 1;

        #680;

        // Fin de las pruebas
        $finish;
    end


    // generacion del clk de probador (periodo 10)
    always begin
        #5 clk = ~clk;
    end

endmodule