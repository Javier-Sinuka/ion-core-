SRC_psmwatch := \
	$(SRC)/psmwatch.c \
	$(SRC)/platform.c \
	$(SRC)/platform_sm.c \
	$(SRC)/memmgr.c \
	$(SRC)/psm.c \
	$(SRC)/smlist.c \
	$(SRC)/sptrace.c

psmwatch:
	$(GCC) $(CFLAG) -I$(INC) $(SRC_psmwatch) \
	$(PLATFORM) \
	-o $(OUT_BIN)/psmwatch
