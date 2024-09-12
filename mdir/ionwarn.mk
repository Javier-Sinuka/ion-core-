# Include ICI Source
include $(MDIR)/libici.mk

# test if inclusion is successful
ifndef LIBICI_INCLUDED
$(error libici.mk is not found or not included, cannot build.)
endif

#$(info libici.mk has been included, proceed to build.)

SRC_ionwarn := \
	$(SRC)/ionwarn.c \
	$(SRC_libici)

ionwarn:
	$(GCC) $(CFLAG) $(SRC_ionwarn) \
	-I$(INC) \
	$(PLATFORM) \
	-o $(OUT_BIN)/ionwarn







