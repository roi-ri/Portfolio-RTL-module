SRC_DIR = src
SRC     = $(SRC_DIR)/testbench.v
OUT     = a.out
VCD     = resultados.vcd

all: run wave

compile:
	iverilog -I $(SRC_DIR) -o $(OUT) $(SRC)

run: compile
	vvp $(OUT)

wave: $(VCD)
	gtkwave $(VCD)

clean:
	rm -f $(OUT) $(VCD)