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

# Include LTP Source
include $(MDIR)/libltp.mk

# test if inclusion is successful
ifndef LIBLTP_INCLUDED
$(error libltp.mk is not found or not included, cannot build.)
endif

# Include CFDP Source
include $(MDIR)/libcfdp.mk

# test if inclusion is successful
ifndef LIBCFDP_INCLUDED
$(error libcfdp.mk is not found or not included, cannot build.)
endif

SRC_ionrestart := $(SRC)/ionrestart.c \
	$(SRC)/libcgr.c \
	$(SRC_libcfdp) \
	$(SRC_libltp) \
	$(SRC_libbp) \
	$(SRC_libici) 

ionrestart:
	$(GCC) $(CFLAG) $(SRC_ionrestart) \
	-I$(INC) \
	$(PLATFORM) \
	-o $(OUT_BIN)/ionrestart
