SRC_DIR = src
SRC     = $(SRC_DIR)/testbench.v
OUT     = SPI.out
VCD     = resultados.vcd

# ===================================
# Reglas principales
# ===================================

all: run wave

compile:
	@echo "Compilando Protocolo SPI..."
	iverilog -I $(SRC_DIR) -o $(OUT) $(SRC)

run: compile
	@echo "Ejecutando simulación..."
	vvp $(OUT)

wave: $(VCD)
	@echo "Abriendo GTKWave..."
	gtkwave $(VCD) &

clean:
	@echo "Limpiando archivos temporales..."
	rm -f $(OUT) $(VCD)

.PHONY: all compile run wave clean
