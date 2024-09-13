SRC_bptrace := $(SRC)/bptrace.c \
	$(SRC_libici) \
	$(SRC_libbp)

bptrace:
	$(GCC) $(CFLAG) $(SRC_bptrace) \
	-I$(INC) \
	$(PLATFORM) \
	-o $(OUT_BIN)/bptrace
