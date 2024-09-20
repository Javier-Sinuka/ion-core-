# Include ICI Source
include $(MDIR)/libici.mk

# test if inclusion is successful
ifndef LIBICI_INCLUDED
$(error libici.mk is not found or not included, cannot build.)
endif

SRC_owltsim := $(SRC)/owltsim.c \
	$(SRC_libici)

owltsim:
	$(GCC) $(CFLAG) $(SRC_owltsim) \
	-I$(INC) \
	$(PLATFORM) \
	-o $(OUT_BIN)/owltsim
