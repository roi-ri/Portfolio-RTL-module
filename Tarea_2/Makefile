SRC_DIR = src
TESTBENCH = $(SRC_DIR)/testbench.v
CMOS_CELLS = Archivos_Sintesis/cmos_cells.v
CMOS_CELLS_RET = Archivos_Sintesis/cmos_cells_ret.v
OUT = a.out
VCD = resultados.vcd

# Default target - Original RTL simulation
all:
	iverilog -I $(SRC_DIR) -o $(OUT) $(TESTBENCH) $(SRC_DIR)/Controlador.v
	vvp $(OUT)
	gtkwave $(VCD)

# CMOS synthesis simulation
cmos:
	cd $(SRC_DIR) && yosys -s Controlador.ys
	iverilog -I $(SRC_DIR) -o $(OUT) $(TESTBENCH) $(CMOS_CELLS) $(SRC_DIR)/Controlador_Synth.v
	vvp $(OUT)
	gtkwave $(VCD)

# Default synthesis simulation
def:
	cd $(SRC_DIR) && yosys -p "read_verilog Controlador.v; synth; write_verilog Controlador_default_Synth.v"
	iverilog -I $(SRC_DIR) -o $(OUT) $(TESTBENCH) $(CMOS_CELLS) $(SRC_DIR)/Controlador_default_Synth.v
	vvp $(OUT)
	gtkwave $(VCD)

# Retiro synthesis simulation
ret:
	cd $(SRC_DIR) && yosys -s Controlador.ys
	iverilog -I $(SRC_DIR) -o $(OUT) $(TESTBENCH) $(CMOS_CELLS_RET) $(SRC_DIR)/Controlador_Synth.v
	vvp $(OUT)
	gtkwave $(VCD)

# Utility targets
clean:
	rm -f $(OUT) $(VCD)
	rm -f *.vcd *.out

clean-synth:
	rm -f $(SRC_DIR)/Controlador_Synth.v $(SRC_DIR)/Controlador_default_Synth.v 

clean-all: clean clean-synth
