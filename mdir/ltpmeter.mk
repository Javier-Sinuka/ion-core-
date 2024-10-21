# Include ICI Source
include $(MDIR)/libici.mk

# test if inclusion is successful
ifndef LIBICI_INCLUDED
$(error libici.mk is not found or not included, cannot build.)
endif

# Include LTP Source
include $(MDIR)/libltp.mk

# test if inclusion is successful
ifndef LIBLTP_INCLUDED
$(error libltp.mk is not found or not included, cannot build.)
endif

SRC_ltpmeter := $(SRC)/ltpmeter.c \
	$(SRC_libltp) \
	$(SRC)/libudplsa.c \
	$(SRC_libici)

ltpmeter:
	$(GCC) $(CFLAG) -I$(INC) $(SRC_ltpmeter) \
	$(PLATFORM) \
	-o $(OUT_BIN)/ltpmeter










