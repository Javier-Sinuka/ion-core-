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

# Include CFDP Source
include $(MDIR)/libcfdp.mk

# test if inclusion is successful
ifndef LIBCFDP_INCLUDED
$(error libcfdp.mk is not found or not included, cannot build.)
endif

SRC_cfdptest := $(SRC)/cfdptest.c \
	$(SRC_libici) \
	$(SRC_libbp) \
	$(SRC_libcfdp)

cfdptest:
	$(GCC) $(CFLAG) $(SRC_cfdptest) \
	-I$(INC) \
	$(PLATFORM) \
	-o $(OUT_BIN)/cfdptest