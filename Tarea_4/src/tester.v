module probador(
    output reg        clk,
    output reg        reset,
    output reg        START_STB,
    output reg        RNW,
    output reg [6:0]  I2C_ADDR,
    output reg [15:0] WR_DATA,

    input  wire [15:0] RD_DATA,
    input  wire        SCL,
    input  wire        SDA_bus
);

    // Parámetros de temporización
    localparam CLK_PERIOD = 10;      // Periodo del reloj del sistema (10ns)
    localparam I2C_BIT_TIME = 40;    // Tiempo para un bit I2C (4 ciclos de CLK)

    initial begin
        // Inicialización señales
        clk       = 0;
        reset     = 0;       // reset activo-LOW al inicio (0 = reset)
        START_STB = 0;
        I2C_ADDR  = 7'b0111011;  // Dirección del esclavo (59 decimal)

        // Reset inicial
        #50;
        reset = 1; // release reset
        #20;

        $display("");
        $display("==============================================");
        $display("==== INICIO DE SIMULACION ====");
        $display("==============================================");
        $display("");

        // ========================================
        // PRUEBA 1: Escritura (WRITE)
        // ========================================
        $display("");
        $display(">>> PRUEBA 1: Transaccion de ESCRITURA I2C");
        $display("    Direccion: 7'b%b (0x%h)", I2C_ADDR, I2C_ADDR);
        $display("    Datos a escribir: 0x%h", 16'hA55A);
        #50;
        
        WR_DATA = 16'hA55A;
        RNW = 0;
        START_STB = 1;
        #CLK_PERIOD;
        START_STB = 0;

        // Esperar a que termine la transacción
        #1200;
        
        $display("    Transaccion de escritura completada");
        $display("");

        // ========================================
        // RESET entre transacciones
        // ========================================
        $display(">>> Aplicando RESET entre transacciones");
        #50;
        reset = 0;
        #30;
        reset = 1;
        #50;

        // ========================================
        // PRUEBA 2: Lectura (READ)
        // ========================================
        $display("");
        $display(">>> PRUEBA 2: Transaccion de LECTURA I2C");
        $display("    Direccion: 7'b%b (0x%h)", I2C_ADDR, I2C_ADDR);
        $display("    Esperando leer: 0xB24F");
        #50;
        
        RNW = 1;
        START_STB = 1;
        #CLK_PERIOD;
        START_STB = 0;

        // Esperar a que termine la transacción
        #1200;
        
        $display("    Transaccion de lectura completada");
        $display("    Datos leidos por el master: 0x%h", RD_DATA);
        $display("");

        // ========================================
        // PRUEBA 3: RESET durante transacción
        // ========================================
        $display(">>> PRUEBA 3: RESET durante transaccion");
        #50;
        
        WR_DATA = 16'hFACE;
        RNW = 0;
        START_STB = 1;
        #CLK_PERIOD;
        START_STB = 0;

        #300;
        $display("    Aplicando RESET durante transaccion...");
        reset = 0;
        #30;
        reset = 1;
        #100;
        $display("    Transaccion abortada por RESET");
        $display("");

        // ========================================
        // PRUEBA 4: ADDRESS NO MATCH
        // ========================================
        $display(">>> PRUEBA 4: ADDRESS NO MATCH");
        #50;

        I2C_ADDR = 7'b1111111;  // Dirección incorrecta

        $display("    Direccion: 7'b%b (0x%h)", I2C_ADDR, I2C_ADDR);
        $display("    Datos a escribir: 0x%h", 16'hA55A);
        #50;
        
        WR_DATA = 16'hA55A;
        RNW = 0;
        START_STB = 1;
        #CLK_PERIOD;
        START_STB = 0;


        reset = 0;
        #30;
        reset = 1;

        // Esperar a que termine la transacción
        #1200;


        $display("");
        $display("==============================================");
        $display("==== FIN DE SIMULACION ====");
        $display("==============================================");
        $display("");
        
        #100;
        $finish;
    end

    // Generación de reloj de sistema (periodo 10 time units)
    always begin
        #5 clk = ~clk;
    end

endmodule