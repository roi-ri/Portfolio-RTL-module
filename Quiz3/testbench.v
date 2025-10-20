`include "detector_patron.v"

module tb_caja_fuerte_fsm;

    // Señales del testbench
    reg clk;
    reg reset;
    reg [3:0] digito;
    reg cerrar;
    wire desasegurar;
    wire asegurar;

    // Instancia del módulo bajo prueba
    detector_patron uut (
        .clk(clk),
        .reset(reset),
        .digito(digito),
        .cerrar(cerrar),
        .desasegurar(desasegurar),
        .asegurar(asegurar)
    );

    // Generación del reloj (periodo de 10ns = 100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Tarea para enviar un dígito
    task enviar_digito;
        input [3:0] dig;
        begin
            digito = dig;
            @(posedge clk);
            #1;
            digito = 4'b0000;
            @(posedge clk);
        end
    endtask

    // Tarea para activar señal cerrar
    task activar_cerrar;
        begin
            cerrar = 1'b1;
            @(posedge clk);
            #1;
            cerrar = 1'b0;
            @(posedge clk);
        end
    endtask

    // Proceso de prueba
    initial begin
        // Inicialización de señales
        reset = 0;
        digito = 4'b0000;
        cerrar = 1'b0;

        // Crear archivo VCD para visualización
        $dumpfile("tb_caja_fuerte_fsm.vcd");
        $dumpvars(0, tb_caja_fuerte_fsm);

        // Mostrar encabezado
        $display("\n========================================");
        $display("  TEST: Máquina de Caja Fuerte FSM");
        $display("  Patrón correcto: 57936");
        $display("========================================\n");

        // Aplicar reset
        $display("T=%0t: Aplicando reset...", $time);
        #20;
        reset = 1;
        #20;
        $display("T=%0t: Reset liberado. Estado inicial: NINGUNO\n", $time);

        // ============================================
        // TEST 1: Secuencia correcta completa (57936)
        // ============================================
        $display("--- TEST 1: Secuencia correcta 57936 ---");
        enviar_digito(4'd5);
        $display("T=%0t: Enviado dígito 5 -> Estado: B1", $time);
        
        enviar_digito(4'd7);
        $display("T=%0t: Enviado dígito 7 -> Estado: B2", $time);
        
        enviar_digito(4'd9);
        $display("T=%0t: Enviado dígito 9 -> Estado: B3", $time);
        
        enviar_digito(4'd3);
        $display("T=%0t: Enviado dígito 3 -> Estado: B4", $time);
        
        enviar_digito(4'd6);
        $display("T=%0t: Enviado dígito 6 -> Estado: ABIERTO", $time);
        
        if (desasegurar) 
            $display("T=%0t: ✓ DESASEGURAR activado correctamente\n", $time);
        else 
            $display("T=%0t: ✗ ERROR: DESASEGURAR no se activó\n", $time);
        
        #40;

        // ============================================
        // TEST 2: Cerrar la caja fuerte
        // ============================================
        $display("--- TEST 2: Cerrar caja fuerte desde ABIERTO ---");
        activar_cerrar();
        if (asegurar) 
            $display("T=%0t: ✓ ASEGURAR activado correctamente", $time);
        else 
            $display("T=%0t: ✗ ERROR: ASEGURAR no se activó", $time);
        $display("T=%0t: Estado: NINGUNO\n", $time);
        
        #40;

        // ============================================
        // TEST 3: Secuencia incorrecta (5799X)
        // ============================================
        $display("--- TEST 3: Secuencia incorrecta 5799 ---");
        enviar_digito(4'd5);
        $display("T=%0t: Enviado dígito 5 -> Estado: B1", $time);
        
        enviar_digito(4'd7);
        $display("T=%0t: Enviado dígito 7 -> Estado: B2", $time);
        
        enviar_digito(4'd9);
        $display("T=%0t: Enviado dígito 9 -> Estado: B3", $time);
        
        enviar_digito(4'd9);  // Dígito incorrecto (debería ser 3)
        $display("T=%0t: Enviado dígito 9 (incorrecto) -> Estado: NINGUNO", $time);
        
        if (!desasegurar) 
            $display("T=%0t: ✓ Sistema correctamente NO desaseguró\n", $time);
        else 
            $display("T=%0t: ✗ ERROR: Sistema desaseguró incorrectamente\n", $time);
        
        #40;

        // ============================================
        // TEST 4: Secuencia parcial y reset
        // ============================================
        $display("--- TEST 4: Secuencia parcial 57 y luego dígito incorrecto ---");
        enviar_digito(4'd5);
        $display("T=%0t: Enviado dígito 5 -> Estado: B1", $time);
        
        enviar_digito(4'd7);
        $display("T=%0t: Enviado dígito 7 -> Estado: B2", $time);
        
        enviar_digito(4'd3);  // Incorrecto (debería ser 9)
        $display("T=%0t: Enviado dígito 3 (incorrecto) -> Estado: NINGUNO\n", $time);
        
        #40;

        // ============================================
        // TEST 5: Dígitos aleatorios antes de secuencia correcta
        // ============================================
        $display("--- TEST 5: Dígitos aleatorios y luego secuencia correcta ---");
        enviar_digito(4'd2);
        $display("T=%0t: Enviado dígito 2 -> Estado: NINGUNO", $time);
        
        enviar_digito(4'd8);
        $display("T=%0t: Enviado dígito 8 -> Estado: NINGUNO", $time);
        
        enviar_digito(4'd5);
        $display("T=%0t: Enviado dígito 5 -> Estado: B1", $time);
        
        enviar_digito(4'd7);
        $display("T=%0t: Enviado dígito 7 -> Estado: B2", $time);
        
        enviar_digito(4'd9);
        $display("T=%0t: Enviado dígito 9 -> Estado: B3", $time);
        
        enviar_digito(4'd3);
        $display("T=%0t: Enviado dígito 3 -> Estado: B4", $time);
        
        enviar_digito(4'd6);
        $display("T=%0t: Enviado dígito 6 -> Estado: ABIERTO", $time);
        
        if (desasegurar) 
            $display("T=%0t: ✓ DESASEGURAR activado correctamente\n", $time);
        else 
            $display("T=%0t: ✗ ERROR: DESASEGURAR no se activó\n", $time);
        
        #40;

        // ============================================
        // TEST 6: Múltiples intentos de cerrar
        // ============================================
        $display("--- TEST 6: Cerrar y verificar estado NINGUNO ---");
        activar_cerrar();
        $display("T=%0t: Puerta cerrada -> Estado: NINGUNO", $time);
        
        activar_cerrar();
        if (asegurar) 
            $display("T=%0t: ✓ ASEGURAR activado desde NINGUNO", $time);
        else 
            $display("T=%0t: ✗ ERROR: ASEGURAR no se activó desde NINGUNO", $time);
        
        #40;

        // ============================================
        // TEST 7: Secuencia correcta pero interrumpida en B4
        // ============================================
        $display("\n--- TEST 7: Secuencia correcta hasta B4, luego dígito incorrecto ---");
        enviar_digito(4'd5);
        enviar_digito(4'd7);
        enviar_digito(4'd9);
        enviar_digito(4'd3);
        $display("T=%0t: Estado: B4 (5793 ingresado)", $time);
        
        enviar_digito(4'd2);  // Incorrecto (debería ser 6)
        $display("T=%0t: Enviado dígito 2 (incorrecto) -> Estado: NINGUNO", $time);
        
        if (!desasegurar) 
            $display("T=%0t: ✓ Sistema NO desaseguró (correcto)\n", $time);
        else 
            $display("T=%0t: ✗ ERROR: Sistema desaseguró incorrectamente\n", $time);

        #40;

        // ============================================
        // Finalización
        // ============================================
        $display("\n========================================");
        $display("  SIMULACIÓN COMPLETADA");
        $display("========================================\n");
        
        #100;
        $finish;
    end

    // Monitor para observar cambios en las señales
    initial begin
        $monitor("T=%0t | Reset=%b | Digito=%d | Cerrar=%b | Desasegurar=%b | Asegurar=%b | Estado=%b", 
                 $time, reset, digito, cerrar, desasegurar, asegurar, uut.estado);
    end

endmodule