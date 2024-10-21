# Include ICI Source
include $(MDIR)/libici.mk

# test if inclusion is successful
ifndef LIBICI_INCLUDED
$(error libici.mk is not found or not included, cannot build.)
endif

SRC_owltsim := $(SRC)/owltsim.c \
	$(SRC_libici)

owltsim:
	$(GCC) $(CFLAG) -I$(INC) $(SRC_owltsim) \
	$(PLATFORM) \
	-o $(OUT_BIN)/owltsim
