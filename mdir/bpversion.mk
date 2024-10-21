SRC_bpversion := \
	$(SRC)/bpversion.c

bpversion:
	$(GCC) $(CFLAG) -I$(INC) $(SRC_bpversion) \
	$(PLATFORM) \
	-o $(OUT_BIN)/bpversion
