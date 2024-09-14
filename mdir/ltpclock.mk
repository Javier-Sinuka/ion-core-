# Include ICI Source
include $(MDIR)/libici.mk

# test if inclusion is successful
ifndef LIBICI_INCLUDED
$(error libici.mk is not found or not included, cannot build.)
endif

SRC_ltpclock := $(SRC)/ltpclock.c \
	$(SRC)/libltpP.c \
	$(SRC)/ltpei.c \
	$(SRC_libici)
	
ltpclock:
	$(GCC) $(CFLAG) $(SRC_ltpclock) \
	-I$(INC) \
	$(PLATFORM) \
	-o $(OUT_BIN)/ltpclock
















