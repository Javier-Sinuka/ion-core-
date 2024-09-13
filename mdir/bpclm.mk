# Include ICI Source
include $(MDIR)/libici.mk

# test if inclusion is successful
ifndef LIBICI_INCLUDED
$(error libici.mk is not found or not included, cannot build.)
endif

# Include BP Source
include $(MDIR)/libbp.mk

# test if inclusion is successful
ifndef LIBBP_INCLUDED
$(error libbp.mk is not found or not included, cannot build.)
endif

SRC_bpadmin := $(SRC)/bpadmin.c \
	$(SRC_libici) \
	$(SRC_libbp)

SRC_bpclm := $(SRC)/bpclm.c \
	$(SRC_libici) \
	$(SRC_libbp) \

bpclm:
	$(GCC) $(CFLAG) $(SRC_bpclm) \
	-I$(INC) \
	$(PLATFORM) \
	-o $(OUT_BIN)/bpclm
