BUILD := build
STD   := --std=08 --workdir=$(BUILD)
RTL   := $(shell find rtl -name '*.vhd')

NAME  ?=
TOP   := $(NAME)_tb
TB    := testBench/$(TOP).vhd
DUT   := rtl/$(NAME).vhd
WAVE  := $(BUILD)/$(NAME).ghw

.PHONY: sim view clean

ifeq ($(NAME),)
sim: | $(BUILD)
	ghdl -i $(STD) $(RTL)
	@for e in $$(grep -ihoP '^\s*entity\s+\K\w+(?=\s+is)' $(RTL)); do \
		echo "Compiling $$e"; \
		ghdl -m $(STD) $$e || exit 1; \
	done

view:
	@echo "view needs a module: make view NAME=alu"; exit 1
else
sim: | $(BUILD)
	@test -f $(DUT) || { echo "Missing $(DUT)"; exit 1; }
	@test -f $(TB)  || { echo "Missing $(TB)";  exit 1; }
	ghdl -i $(STD) $(RTL) $(TB)
	ghdl -m $(STD) $(TOP)
	ghdl -r $(STD) $(TOP) --wave=$(WAVE)

view: sim
	gtkwave $(WAVE)
endif

$(BUILD):
	mkdir -p $(BUILD)

clean:
	rm -rf $(BUILD)	