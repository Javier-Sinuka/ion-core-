#################################
# Makefile for ION-Core
#################################

# bring in the build list
include ./build-list.mk

# test if inclusion is successful
ifndef BUILD_LIST_INCLUDED
$(error build-list.mk is not found or not included, cannot build.)
endif

$(info build-list.mk has been included, proceed to build.)

###########################
# Build Rules
###########################
# This is probably the only thing users would want to change:
INSTALL_PATH = /usr/local/

PWD := $(shell pwd)

export SRC = $(PWD)/src
export INC = $(PWD)/inc
export OUT_BIN = $(PWD)/bin
export MAN = $(PWD)/man
export SCR = $(PWD)/scripts
export TESTS = $(PWD)/tests

# Just locally:
MDIR = $(PWD)/mdir
LIB = $(PWD)/lib

###########################
# Compiler Flags
###########################
# SPACE_ORDER of 3 specifies 64 bit systems.
# SPACE_ORDER of 2 specifies 32 bit systems.
# BP_EXTENDED is required enables extension blocks required for QoS.

export CFLAG = -g -Wall -DSPACE_ORDER=${ARCH} -DBP_EXTENDED ${EXT_FLAGS} -lm -pthread
export PLATFORM = -lm -pthread
export GCC = /usr/bin/gcc

# Just locally:
MAKE = /usr/bin/make -f

# Collect all source files from SRC_{PROGRAM} variables defined in .mk files
ALL_SRC_FILES := $(sort $(foreach prog,$(PROGRAMS),$(SRC_$(prog))))

# Convert source file paths to object file paths
OBJ_FILES := $(patsubst $(SRC)/%.c,$(LIB)/obj/%.o,$(ALL_SRC_FILES))

# Ensure the obj directory exists
_OBJ_DIR := $(shell mkdir -p $(LIB)/obj)

################################
# Define build targets
################################
.PHONY: all $(PROGRAMS) clean distclean install man uninstall

# Default target to build selected programs
all: $(PROGRAMS)

# Construct .mk file paths
MK_FILES := $(addprefix $(MDIR)/,$(addsuffix .mk,$(PROGRAMS)))

# Include.mk files
include $(MK_FILES)

# After inclusion of all .mk files, the SRC_{PROGRAM} variables are now 
# visible to the rest of the Makefile.

# Collect all source files from SRC_{PROGRAM} variables defined in .mk files
ALL_SRC_FILES := $(sort $(foreach prog,$(PROGRAMS),$(SRC_$(prog))))

# Convert source file paths to object file paths
OBJ_FILES := $(patsubst $(SRC)/%.c,$(LIB)/obj/%.o,$(ALL_SRC_FILES))

# Ensure the obj directory exists
_OBJ_DIR := $(shell mkdir -p $(LIB)/obj)

# Specify test list on build-list options
# Left side of ":" is a list of programs, joined by '+'
# Right side of ":" is a list of tests to execute, joined by '+'
# Each test on the right side should appear only once.
COMBINATION_TESTS := \
	cfdpadmin+ltpcli+owltsim:bench-cfdp \
	stcpcli:bench-stcp \
	udpcli:bench-udp \
	ltpcli:bench-ltp

# Static library target
lib: $(OBJ_FILES)
	ar rcs $(LIB)/libioncore.a $^

# Object files compile rule for static library #
# *** Remember to check if there are different flags for different programs. ***
# *** This rule here assumes they are all the same, which is true for 4.1.2. ***
$(LIB)/obj/%.o: $(SRC)/%.c
	$(GCC) $(CFLAG) -I$(INC) -c $< $(PLATFORM) -o $@
				
install:
	cp -v $(OUT_BIN)/* $(INSTALL_PATH)/bin
	cp -v $(OUT_BIN)/ionstart $(INSTALL_PATH)/bin
	cp -v $(OUT_BIN)/ionstart.awk $(INSTALL_PATH)/bin
	cp -v $(OUT_BIN)/ionstop $(INSTALL_PATH)/bin
	cp -v $(OUT_BIN)/killm $(INSTALL_PATH)/bin

man:
	./scripts/make-man-pages.sh $(SRC) "$(PROGRAMS)"
	cp -v $(MAN)/* $(INSTALL_PATH)/man || true

clean:
	@find $(OUT_BIN) -type f ! -name '.gitkeep' ! -name 'ionstart' ! -name 'ionstart.awk' ! -name 'ionstop' ! -name 'killm' -exec rm -f {} + > /dev/null
	@find $(LIB) -type f ! -name '.gitkeep' -exec rm -f {} + > /dev/null

test:
	@echo "Processing PROGRAMS list from $(BUILD_LIST)..."
	@ALL_TESTS_TO_RUN=""; \
	for combo in $(COMBINATION_TESTS); do \
		COMB=$$(echo $$combo | cut -d':' -f1); \
		TESTS_TO_RUN=$$(echo $$combo | cut -d':' -f2 | tr '+' ' '); \
		COMB_FOUND=1; \
		for prog in $$(echo $$COMB | tr '+' ' '); do \
			if ! echo "$(PROGRAMS)" | grep -q "$$prog"; then \
				COMB_FOUND=0; \
				break; \
			fi; \
		done; \
		if [ $$COMB_FOUND -eq 1 ]; then \
			echo "Combination found: $$COMB. Adding tests: $$TESTS_TO_RUN"; \
			ALL_TESTS_TO_RUN="$$ALL_TESTS_TO_RUN $$TESTS_TO_RUN"; \
		else \
			echo "Combination not found: $$COMB"; \
		fi; \
	done; \
	if [ -n "$$ALL_TESTS_TO_RUN" ]; then \
		echo "Running the following tests: $$ALL_TESTS_TO_RUN"; \
		cd $(TESTS) && ./runtests $$ALL_TESTS_TO_RUN; \
	else \
		echo "No valid combinations found. No tests to run."; \
	fi

uninstall:
	@rm -f $(INSTALL_PATH)/bin/*
	@rm -f $(INSTALL_PATH)/man/*

## Clean up all build artifacts + all source files extracted from ION open source code
distclean:
	@find $(INC) -mindepth 1 ! -name '.gitkeep' -exec rm -rf {} + > /dev/null
	@find $(SRC) -mindepth 1 ! -name '.gitkeep' -exec rm -rf {} + > /dev/null
	@find $(LIB) -mindepth 1 ! -name '.gitkeep' -exec rm -rf {} + > /dev/null
	@find $(OUT_BIN) -mindepth 1 ! -name '.gitkeep' -exec rm -rf {} + > /dev/null
	@find $(MAN) -mindepth 1 ! -name '.gitkeep' -exec rm -rf {} + > /dev/null
	@find $(TESTS) -mindepth 1 ! -name '.gitkeep' -exec rm -rf {} + > /dev/null
	@rm system_up > /dev/null









