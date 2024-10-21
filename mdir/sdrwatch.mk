# Include ICI Source
include $(MDIR)/libici.mk

# test if inclusion is successful
ifndef LIBICI_INCLUDED
$(error libici.mk is not found or not included, cannot build.)
endif

#$(info libici.mk has been included, proceed to build.)

SRC_sdrwatch := \
	$(SRC)/sdrwatch.c \
	$(SRC_libici)

sdrwatch:
	$(GCC) $(CFLAG) -I$(INC) $(SRC_sdrwatch) \
	$(PLATFORM) \
	-o $(OUT_BIN)/sdrwatch
