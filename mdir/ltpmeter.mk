# Include ICI Source
include $(MDIR)/libici.mk

# test if inclusion is successful
ifndef LIBICI_INCLUDED
$(error libici.mk is not found or not included, cannot build.)
endif

SRC_ltpmeter := $(SRC)/ltpmeter.c \
	$(SRC)/libltpP.c \
	$(SRC)/libudplsa.c \
	$(SRC)/ltpei.c \
	$(SRC_libici)

ltpmeter:
	$(GCC) $(CFLAG) $(SRC_ltpmeter) \
	-I$(INC) \
	$(PLATFORM) \
	-o $(OUT_BIN)/ltpmeter










