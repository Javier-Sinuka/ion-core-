
SRC_bprecvfile := $(SRC)/bprecvfile.c \
	$(SRC_libici) \
	$(SRC_libbp)

bprecvfile:
	$(GCC) $(CFLAG) $(SRC_bprecvfile) \
	-I$(INC) \
	$(PLATFORM) \
	-o $(OUT_BIN)/bprecvfile
