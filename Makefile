
#DATA_MEM_IN - input for mem
#DATA_MEM_OUT - out file for mem
#CLK_NUM - num of clk to emulate
#DUMP_DM - dump mempory
#DUMP_REG
#-D

VERILOG=iverilog
INCLUDE=-I./ -I./src/
SRC_TOP_TB=./tests/cpu_top_lvl_tb.v
FLAGS=

ifdef DATA_MEM_IN
	FLAGS+=-DDATA_MEM_IN=\"$(DATA_MEM_IN)\"
endif

ifdef DATA_MEM_OUT
	FLAGS+=-DDATA_MEM_OUT=\"$(DATA_MEM_OUT)\"
endif

ifdef CLK_NUM
	FLAGS+=-DCLK_NUM=$(CLK_NUM)
endif

ifdef INSTRUCTION_MEM_OUT
	FLAGS+=-DINSTRUCTION_MEM_OUT=\"$(INSTRUCTION_MEM_OUT)\"
endif

ifdef INSTRUCTION_MEM_IN
	FLAGS+=-DINSTRUCTION_MEM_IN=\"$(INSTRUCTION_MEM_IN)\"
endif

ifdef REGISTER_DATA_IN
	FLAGS+=-DREGISTER_DATA_IN=\"$(REGISTER_DATA_IN)\"
endif

ifdef REGISTER_DATA_OUT
	FLAGS+=-DREGISTER_DATA_OUT=\"$(REGISTER_DATA_OUT)\"
endif

ifdef VCD_DUMP
	FLAGS+=-DVCD_DUMP=\"$(VCD_DUMP)\"
endif

ifdef DUMP_DM
	FLAGS+=-DDUMP_DM
endif

ifdef DUMP_REG
	FLAGS+=-DDUMP_REG
endif

ifdef DEBUG
	FLAGS+=-DDUMP_REG
	FLAGS+=-DDUMP_DM
endif

ifdef GET_AFTER_INCLUDE
	FLAGS+=-E
endif
	
all: cpu_testbench run

cpu_testbench:
	$(VERILOG) $(INCLUDE) $(SRC_TOP_TB) -o ./cpu $(FLAGS)

run:
	vvp ./cpu


