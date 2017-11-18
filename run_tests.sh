#!/bin/bash

TEST_DIR="./tests/isa/"
DM_FILE="data_memory.txt"
IM_FILE="instruction_memory.txt"
REG_FILE="register_file.txt"
DM_OUT="data_memory_out.txt"
REG_OUT="register_file_out.txt"
DM_GOLD="data_memory_gold.txt"
REG_GOLD="register_file_gold.txt"

for test_name in $(ls $TEST_DIR)
do
	echo "Running test for opcode $test_name"
	TEST_PATH="$TEST_DIR$test_name"

	TEST_DM_GOLD="$TEST_PATH/$DM_GOLD"
	TEST_REG_GOLD="$TEST_PATH/$REG_GOLD"

	TEST_DM_FILE="$TEST_PATH/$DM_FILE"
	TEST_IM_FILE="$TEST_PATH/$IM_FILE"
	TEST_REG_FILE="$TEST_PATH/$REG_FILE"

	TEST_DM_OUT="$TEST_PATH/$DM_OUT"
	TEST_REG_OUT="$TEST_PATH/$REG_OUT"

	TEST_VCD_LOG="$TEST_PATH/log.vcd"
	TEST_CLK_NUM=$(wc -l $TEST_IM_FILE | sed 's/\ .*//')
	MAKE_FLAG=" DEBUG=1 CLK_NUM=$TEST_CLK_NUM INSTRUCTION_MEM_IN="$TEST_IM_FILE" REGISTER_DATA_IN="$TEST_REG_FILE" DATA_MEM_IN="$TEST_DM_FILE" DATA_MEM_OUT="$TEST_DM_OUT" REGISTER_DATA_OUT="$TEST_REG_OUT" VCD_DUMP="$TEST_VCD_LOG" "
	make $MAKE_FLAG > /dev/null
	TEST_DM_DIFF=$(diff --strip-trailing-cr $TEST_DM_GOLD $TEST_DM_OUT)
	if [ -n "${TEST_DM_DIFF}" ]; then
		echo "DATA MEMORY DIFFERS. TEST FAILED."
		echo $TEST_DM_DIFF
	fi
	TEST_REG_DIFF=$(diff --strip-trailing-cr $TEST_REG_GOLD $TEST_REG_OUT)
	if [ -n "${TEST_REG_DIFF}" ]; then
		echo "REGISTERS DIFFER. TEST FAILED."
	fi
	echo "==="
done
