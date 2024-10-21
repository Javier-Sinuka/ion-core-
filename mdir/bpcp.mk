# Include ICI Source
include $(MDIR)/libici.mk

# test if inclusion is successful
ifndef LIBICI_INCLUDED
$(error libici.mk is not found or not included, cannot build.)
endif

# Include CFDP Source
include $(MDIR)/libcfdp.mk

# test if inclusion is successful
ifndef LIBCFDP_INCLUDED
$(error libcfdp.mk is not found or not included, cannot build.)
endif

SRC_bpcp := $(SRC)/bpcp.c \
	$(SRC_libici) \
	$(SRC_libcfdp)

bpcp:
	$(GCC) $(CFLAG) -I$(INC) $(SRC_bpcp) \
	$(PLATFORM) \
	-o $(OUT_BIN)/bpcp