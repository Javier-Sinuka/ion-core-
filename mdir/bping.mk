SRC_bping := $(SRC)/bping.c \
	$(SRC_libici) \
	$(SRC_libbp)

bping:
	$(GCC) $(CFLAG) $(SRC_bping) \
	-I$(INC) \
	$(PLATFORM) \
	-o $(OUT_BIN)/bping

