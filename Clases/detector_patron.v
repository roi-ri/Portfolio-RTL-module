
module detector_patron (
    input  wire       clk,
    input  wire       reset,        
    input  wire [3:0] digito,       
    input  wire       cerrar,       
    output reg        desasegurar,  
    output reg        asegurar     
);

// 
  localparam NINGUNO = 6'b000001; // 0 buenos
  localparam B1      = 6'b000010; // 1 bueno (5)
  localparam B2      = 6'b000100; // 2 buenos (57)
  localparam B3      = 6'b001000; // 3 buenos (579)
  localparam B4      = 6'b010000; // 4 buenos (5793)
  localparam ABIERTO = 6'b100000; // combinación correcta

  reg [5:0] estado, prox_estado;

// Logica secuencial

  always @(posedge clk) begin
    if (!reset) estado <= NINGUNO;
    else        estado <= prox_estado;
  end

// Logica combinacional
  always @(*) begin
    prox_estado   = estado;
    desasegurar   = 1'b0;
    asegurar      = 1'b0;

    case (estado)

      NINGUNO: begin
        if (digito == 4'd5) prox_estado = B1;
    
      end

      // B1 = 5
      B1: begin
        if (digito == 4'd7) prox_estado = B2;
        else begin 
            prox_estado = NINGUNO; 
        end
    end 
      // B2 = 57 
      B2: begin
        if (digito == 4'd9) prox_estado = B3;
        else begin 
            prox_estado = NINGUNO; 
        end 
      end

      // B3 = 579
      B3: begin
        if (digito == 4'd3) prox_estado = B4;
        else begin
            prox_estado = NINGUNO;
        end
    end 

      // B4 = 5793
      B4: begin
        if (digito == 4'd6) begin
          prox_estado = ABIERTO;  
          desasegurar = 1'b1;   // Salida  
        end else
          prox_estado = NINGUNO;  
      end

      ABIERTO: begin
        if (cerrar) begin
          asegurar    = 1'b1;     // pulso al cerrar
          prox_estado = NINGUNO;  // volver a inicio
        end
        // si no se cierra, permanece en ABIERTO
      end

    endcase
  end
endmodule