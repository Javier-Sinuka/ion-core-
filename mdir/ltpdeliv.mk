# Include ICI Source
include $(MDIR)/libici.mk

# test if inclusion is successful
ifndef LIBICI_INCLUDED
$(error libici.mk is not found or not included, cannot build.)
endif

SRC_ltpdeliv := $(SRC)/ltpdeliv.c \
	$(SRC)/libltpP.c \
	$(SRC)/ltpei.c \
	$(SRC_libici)
	

ltpdeliv:
	$(GCC) $(CFLAG) $(SRC_ltpdeliv) \
	-I$(INC) \
	$(PLATFORM) \
	-o $(OUT_BIN)/ltpdeliv
