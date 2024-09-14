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

SRC_udpcli := $(SRC)/udpcli.c \
	$(SRC)/libudpcla.c \
	$(SRC_libici) \
	$(SRC_libbp)
	
udpcli:
	$(GCC) $(CFLAG) $(SRC_udpcli) \
	-I$(INC) \
	$(PLATFORM) \
	-o $(OUT_BIN)/udpcli
