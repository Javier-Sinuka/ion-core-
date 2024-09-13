SRC_bplist := $(SRC)/bplist.c \
	$(SRC_libici) \
	$(SRC_libbp)

bplist:
	$(GCC) $(CFLAG) $(SRC_bplist) \
	-I$(INC) \
	$(PLATFORM) \
	-o $(OUT_BIN)/bplist
