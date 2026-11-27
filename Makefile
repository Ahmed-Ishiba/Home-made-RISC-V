BUILD := build
STD   := --std=08 --workdir=$(BUILD)

NAME ?=
TOP  := tb_$(NAME)
TB   := testBench/tb_$(NAME).vhd
WAVE := $(BUILD)/$(NAME).ghw
GTKW := scripts/$(NAME).gtkw

# Source files each module needs, in compile order.
# Add a line here for each new module you want to test.
SRC_generic       := rtl/generic.vhd
SRC_extend        := rtl/generic.vhd
SRC_alu           := rtl/alu.vhd
SRC_register_file := rtl/regfile.vhd
SRC_control_unit  := rtl/aludec.vhd rtl/maindec.vhd rtl/controller.vhd

SRC_riscv := \
	rtl/generic.vhd \
    rtl/regfile.vhd \
    rtl/alu.vhd \
    rtl/datapath.vhd \
    rtl/maindec.vhd \
    rtl/aludec.vhd \
    rtl/controller.vhd \
    rtl/riscvsingle.vhd \
    rtl/imem.vhd \
    rtl/dmem.vhd \
    rtl/top.vhd

SRC := $(SRC_$(NAME))

.PHONY: sim view clean

sim: | $(BUILD)
	@test -n "$(NAME)" || { echo "usage: make sim NAME=alu"; exit 1; }
	@test -n "$(SRC)"  || { echo "No SRC_$(NAME) defined in Makefile"; exit 1; }
	@test -f $(TB)     || { echo "Missing $(TB)"; exit 1; }
	ghdl -a $(STD) $(SRC) $(TB)
	ghdl -e $(STD) $(TOP)
	ghdl -r $(STD) $(TOP) --wave=$(WAVE)

# Opens GTKWave, reloading your saved signal layout if one exists
view: sim
	gtkwave $(WAVE) $(wildcard $(GTKW))

$(BUILD):
	mkdir -p $(BUILD)

clean:
	rm -rf $(BUILD)