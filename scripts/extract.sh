#!/usr/bin/env bash

# Exit on any error
set -e

# Trap any errors and display a message before exiting
trap 'echo "An error occurred. Exiting..."; exit 1;' ERR

# Determine OS type
UNAME_S=$(uname -s)

# Update sed syntax for macOS
if [ "$UNAME_S" = "Darwin" ]; then
  SED_INPLACE="-i ''"  # macOS requires an empty backup extension with `-i`
else
  SED_INPLACE="-i"     # Linux or other systems
fi

# Display Help Menu
function display_help() {
    echo "Usage: $0 [source_path]"
    echo
    echo "This script automates the setup for ION-Core by downloading the specified version,"
    echo "extracting it, and preparing the environment for compilation."
    echo
    echo "Arguments:"
    echo "  source_path    Optional. The path to download and extract the ION-Core source."
    echo "                 If not provided, './tmp/ion-open-source-<version>' will be used."
    echo
    echo "Example:"
    echo "  $0              # Uses default path"
    echo "  $0 custom/path  # Uses 'custom/path' for the operation"
    exit 1
}

# Check for help argument
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    display_help
fi

# Get the full path of the script's directory
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Get the root directory of ion-core
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")

# change to the script's parent directory
cd "$ROOT_DIR"

# Set the default source
ION_VER="4.1.3"
ION_SRC_ZIP=https://github.com/nasa-jpl/ION-DTN/archive/refs/tags/ion-open-source-$ION_VER.tar.gz

# Check if a source path was provided

# if not, use the tmp under ion-core
if [[ -z "$1" ]]; then
	# set default source path and clear it
	SOURCE_PATH="$ROOT_DIR/tmp/ion-open-source-$ION_VER"
	rm -rf "$SOURCE_PATH"
	mkdir -p "$SOURCE_PATH"
	echo "No source path specified. ION $ION_VER will be downloaded to location: $SOURCE_PATH"
	# Use wget to download the file
	if wget "$ION_SRC_ZIP"; then
		tar -xzf ion-open-source-$ION_VER.tar.gz -C "$SOURCE_PATH" --strip-components 1
		rm ion-open-source-$ION_VER.tar.gz
		echo "Download and extraction successful."
	else
		echo "Download failed."
		exit 1
	fi
else
	# Use the provided source path

	# Determine the full path to source code
	# Check if the path is relative or absolute
		if [[ "$1" = /* ]]; then
			# It's already an absolute path
			SOURCE_PATH="$1"
		else
			# It's a relative path, prepend the current working directory
			SOURCE_PATH="$(pwd)/$1"
		fi

	# Normalize the path to remove any redundant components like ../ or ./
	SOURCE_PATH=$(cd "$(dirname "$SOURCE_PATH")" && pwd)/$(basename "$SOURCE_PATH")
	
	echo "Using provided source path: $SOURCE_PATH"

	# Check if the source path exists
	if [[ ! -d "$SOURCE_PATH" ]]; then
		echo "Source path does not exist. Please provide a valid source path."
		exit 1
	fi
fi

# Set the output directories
SRC="$ROOT_DIR/src"
INC="$ROOT_DIR/inc"
OUT_BIN="$ROOT_DIR/bin"
MAN="$ROOT_DIR/man"
TESTS="$ROOT_DIR/tests"

# List of source files to link
SOURCES=(
# BPv7
	$SOURCE_PATH/bpv7/bibe/bibe.c
	$SOURCE_PATH/bpv7/bpsec/instr/bpsec_instr.c
	$SOURCE_PATH/bpv7/bpsec/policy/bpsec_policy_event.c
	$SOURCE_PATH/bpv7/bpsec/policy/bpsec_policy_eventset.c
	$SOURCE_PATH/bpv7/bpsec/policy/bpsec_policy_rule.c
	$SOURCE_PATH/bpv7/bpsec/policy/bpsec_policy.c
	$SOURCE_PATH/bpv7/bpsec/sci/bcb_aes_gcm_sc.c
	$SOURCE_PATH/bpv7/bpsec/sci/bib_hmac_sha2_sc.c
	$SOURCE_PATH/bpv7/bpsec/sci/ion_test_sc.c
	$SOURCE_PATH/bpv7/bpsec/sci/rfc9173_utils.c
	$SOURCE_PATH/bpv7/bpsec/sci/sc_util.c
	$SOURCE_PATH/bpv7/bpsec/sci/sc_value.c
	$SOURCE_PATH/bpv7/bpsec/sci/sci_valmap.c
	$SOURCE_PATH/bpv7/bpsec/sci/sci.c
	$SOURCE_PATH/bpv7/bpsec/utils/bpsec_asb.c
	$SOURCE_PATH/bpv7/bpsec/utils/bpsec_util.c
	$SOURCE_PATH/bpv7/cgr/libcgr.c
	$SOURCE_PATH/bpv7/daemon/bpclm.c
	$SOURCE_PATH/bpv7/daemon/bpclock.c
	$SOURCE_PATH/bpv7/daemon/bptransit.c
	$SOURCE_PATH/bpv7/imc/libimcfw.c
	$SOURCE_PATH/bpv7/ipn/ipnadmin.c
	$SOURCE_PATH/bpv7/ipn/ipnadminep.c
	$SOURCE_PATH/bpv7/ipn/ipnfw.c
	$SOURCE_PATH/bpv7/ipn/libipnfw.c
	$SOURCE_PATH/bpv7/library/bei.c
	$SOURCE_PATH/bpv7/library/eureka.c
	$SOURCE_PATH/bpv7/library/ext/bae/bae.c
	$SOURCE_PATH/bpv7/library/ext/bpq/bpq.c
	$SOURCE_PATH/bpv7/library/ext/bpsec/bcb.c
	$SOURCE_PATH/bpv7/library/ext/bpsec/bib.c
	$SOURCE_PATH/bpv7/library/ext/hcb/hcb.c
	$SOURCE_PATH/bpv7/library/ext/imc/imc.c
	$SOURCE_PATH/bpv7/library/ext/meb/meb.c
	$SOURCE_PATH/bpv7/library/ext/pnb/pnb.c
	$SOURCE_PATH/bpv7/library/ext/snw/snw.c
	$SOURCE_PATH/bpv7/library/libbp.c
	$SOURCE_PATH/bpv7/library/libbpP.c
	$SOURCE_PATH/bpv7/ltp/ltpcli.c
	$SOURCE_PATH/bpv7/ltp/ltpclo.c
	$SOURCE_PATH/bpv7/saga/saga.c
	$SOURCE_PATH/bpv7/stcp/stcpcli.c
	$SOURCE_PATH/bpv7/stcp/stcpclo.c
	$SOURCE_PATH/bpv7/stcp/libstcpcla.c
	$SOURCE_PATH/bpv7/test/bpchat.c
	$SOURCE_PATH/bpv7/test/bpcounter.c
	$SOURCE_PATH/bpv7/test/bpdriver.c
	$SOURCE_PATH/bpv7/test/bpecho.c
	$SOURCE_PATH/bpv7/test/bping.c
	$SOURCE_PATH/bpv7/test/bpsink.c
	$SOURCE_PATH/bpv7/test/bpsource.c
	$SOURCE_PATH/bpv7/udp/libudpcla.c
	$SOURCE_PATH/bpv7/udp/udpcli.c
	$SOURCE_PATH/bpv7/udp/udpclo.c
	$SOURCE_PATH/bpv7/utils/bpadmin.c
	$SOURCE_PATH/bpv7/utils/bpcancel.c
	$SOURCE_PATH/bpv7/utils/bplist.c
	$SOURCE_PATH/bpv7/utils/bprecvfile.c
	$SOURCE_PATH/bpv7/utils/bpsendfile.c
	$SOURCE_PATH/bpv7/utils/bpstats.c
	$SOURCE_PATH/bpv7/utils/bptrace.c
	$SOURCE_PATH/bpv7/utils/bpversion.c
	$SOURCE_PATH/bpv7/utils/lgagent.c
	$SOURCE_PATH/bpv7/utils/lgsend.c
# CFDP
	$SOURCE_PATH/cfdp/bp/bputa.c
	$SOURCE_PATH/cfdp/daemon/cfdpclock.c
	$SOURCE_PATH/cfdp/library/libcfdp.c
	$SOURCE_PATH/cfdp/library/libcfdpops.c
	$SOURCE_PATH/cfdp/library/libcfdpP.c
	$SOURCE_PATH/cfdp/test/cfdptest.c
	$SOURCE_PATH/cfdp/utils/bpcp.c
	$SOURCE_PATH/cfdp/utils/bpcpd.c
	$SOURCE_PATH/cfdp/utils/cfdpadmin.c
# ICI
	$SOURCE_PATH/ici/bulk/STUB_BULK/bulk.c
	$SOURCE_PATH/ici/crypto/NULL_SUITES/csi.c
	$SOURCE_PATH/ici/daemon/rfxclock.c
	$SOURCE_PATH/ici/library/cbor.c
	$SOURCE_PATH/ici/library/crc.c
	$SOURCE_PATH/ici/library/ion.c
	$SOURCE_PATH/ici/library/ionsec.c
	$SOURCE_PATH/ici/library/lyst.c
	$SOURCE_PATH/ici/library/memmgr.c
	$SOURCE_PATH/ici/library/platform_sm.c
	$SOURCE_PATH/ici/library/platform.c
	$SOURCE_PATH/ici/library/psm.c
	$SOURCE_PATH/ici/library/radix.c
	$SOURCE_PATH/ici/library/rfx.c
	$SOURCE_PATH/ici/library/smlist.c
	$SOURCE_PATH/ici/library/smrbt.c
	$SOURCE_PATH/ici/library/sptrace.c
	$SOURCE_PATH/ici/library/zco.c
	$SOURCE_PATH/ici/sdr/sdrcatlg.c
	$SOURCE_PATH/ici/sdr/sdrhash.c
	$SOURCE_PATH/ici/sdr/sdrlist.c
	$SOURCE_PATH/ici/sdr/sdrmgt.c
	$SOURCE_PATH/ici/sdr/sdrstring.c
	$SOURCE_PATH/ici/sdr/sdrtable.c
	$SOURCE_PATH/ici/sdr/sdrxn.c
	$SOURCE_PATH/ici/utils/ionadmin.c
	$SOURCE_PATH/ici/utils/ionwarn.c
	$SOURCE_PATH/ici/utils/psmwatch.c
	$SOURCE_PATH/ici/utils/sdrwatch.c
	$SOURCE_PATH/ici/test/owltsim.c
# LTP
	$SOURCE_PATH/ltp/daemon/ltpclock.c
	$SOURCE_PATH/ltp/daemon/ltpdeliv.c
	$SOURCE_PATH/ltp/daemon/ltpmeter.c
	$SOURCE_PATH/ltp/library/ext/ltpextensions.c
	$SOURCE_PATH/ltp/library/libltp.c
	$SOURCE_PATH/ltp/library/libltpP.c
	$SOURCE_PATH/ltp/library/ltpei.c
	$SOURCE_PATH/ltp/sda/libsda.c
	$SOURCE_PATH/ltp/udp/libudplsa.c
	$SOURCE_PATH/ltp/udp/udplsi.c
	$SOURCE_PATH/ltp/udp/udplso.c
	$SOURCE_PATH/ltp/utils/ltpadmin.c
# restart
	$SOURCE_PATH/restart/utils/ionrestart.c
)

HEADERS=(
# BPv7
	$SOURCE_PATH/bpv7/bibe/bibe.h
	$SOURCE_PATH/bpv7/bibe/bibeP.h
	$SOURCE_PATH/bpv7/bpsec/instr/bpsec_instr.h
	$SOURCE_PATH/bpv7/bpsec/policy/bpsec_policy_event.h
	$SOURCE_PATH/bpv7/bpsec/policy/bpsec_policy_eventset.h
	$SOURCE_PATH/bpv7/bpsec/policy/bpsec_policy_rule.h
	$SOURCE_PATH/bpv7/bpsec/policy/bpsec_policy.h
	$SOURCE_PATH/bpv7/bpsec/sci/bcb_aes_gcm_sc.h
	$SOURCE_PATH/bpv7/bpsec/sci/bib_hmac_sha2_sc.h
	$SOURCE_PATH/bpv7/bpsec/sci/ion_test_sc.h
	$SOURCE_PATH/bpv7/bpsec/sci/rfc9173_utils.h
	$SOURCE_PATH/bpv7/bpsec/sci/sc_util.h
	$SOURCE_PATH/bpv7/bpsec/sci/sc_value.h
	$SOURCE_PATH/bpv7/bpsec/sci/sci_structs.h
	$SOURCE_PATH/bpv7/bpsec/sci/sci_valmap.h
	$SOURCE_PATH/bpv7/bpsec/sci/sci.h
	$SOURCE_PATH/bpv7/bpsec/utils/bpsec_asb.h
	$SOURCE_PATH/bpv7/bpsec/utils/bpsec_util.h 
	$SOURCE_PATH/bpv7/dtn2/dtn2fw.h
	$SOURCE_PATH/bpv7/imc/imcfw.h
	$SOURCE_PATH/bpv7/include/bp.h
	$SOURCE_PATH/bpv7/include/eureka.h
	$SOURCE_PATH/bpv7/ipn/ipnfw.h
	$SOURCE_PATH/bpv7/library/bei.h
	$SOURCE_PATH/bpv7/library/bpP.h
	$SOURCE_PATH/bpv7/library/cgr.h
	$SOURCE_PATH/bpv7/library/ext/bae/bae.h
	$SOURCE_PATH/bpv7/library/ext/bpextensions.c
	$SOURCE_PATH/bpv7/library/ext/bpq/bpq.h
	$SOURCE_PATH/bpv7/library/ext/bpsec/bcb.h
	$SOURCE_PATH/bpv7/library/ext/bpsec/bib.h
	$SOURCE_PATH/bpv7/library/ext/hcb/hcb.h
	$SOURCE_PATH/bpv7/library/ext/imc/imc.h
	$SOURCE_PATH/bpv7/library/ext/meb/meb.h
	$SOURCE_PATH/bpv7/library/ext/pnb/pnb.h
	$SOURCE_PATH/bpv7/library/ext/snw/snw.h
	$SOURCE_PATH/bpv7/ltp/ltpcla.h
	$SOURCE_PATH/bpv7/saga/saga.h
	$SOURCE_PATH/bpv7/stcp/stcpcla.h
	$SOURCE_PATH/bpv7/udp/udpcla.h
	$SOURCE_PATH/bpv7/utils/bpsecadmin_config.h
	$SOURCE_PATH/bpv7/utils/jsmn.h
# CFDP
	$SOURCE_PATH/cfdp/include/bputa.h
	$SOURCE_PATH/cfdp/include/cfdp.h
	$SOURCE_PATH/cfdp/include/cfdpops.h
	$SOURCE_PATH/cfdp/library/cfdpP.h
	$SOURCE_PATH/cfdp/utils/bpcp.h
# ICI
	$SOURCE_PATH/ici/crypto/csi_debug.h
	$SOURCE_PATH/ici/include/bulk.h
	$SOURCE_PATH/ici/include/cbor.h
	$SOURCE_PATH/ici/include/crc.h
	$SOURCE_PATH/ici/include/crypto.h
	$SOURCE_PATH/ici/include/csi.h
	$SOURCE_PATH/ici/include/ion.h
	$SOURCE_PATH/ici/include/ionsec.h
	$SOURCE_PATH/ici/include/lyst.h
	$SOURCE_PATH/ici/include/memmgr.h
	$SOURCE_PATH/ici/include/platform_sm.h
	$SOURCE_PATH/ici/include/platform.h
	$SOURCE_PATH/ici/include/psm.h
	$SOURCE_PATH/ici/include/radix.h
	$SOURCE_PATH/ici/include/rfx.h
	$SOURCE_PATH/ici/include/sdr.h
	$SOURCE_PATH/ici/include/sdrhash.h
	$SOURCE_PATH/ici/include/sdrlist.h
	$SOURCE_PATH/ici/include/sdrmgt.h
	$SOURCE_PATH/ici/include/sdrstring.h
	$SOURCE_PATH/ici/include/sdrtable.h
	$SOURCE_PATH/ici/include/sdrxn.h
	$SOURCE_PATH/ici/include/smlist.h
	$SOURCE_PATH/ici/include/smrbt.h
	$SOURCE_PATH/ici/include/sptrace.h
	$SOURCE_PATH/ici/include/zco.h
	$SOURCE_PATH/ici/library/lystP.h
	$SOURCE_PATH/ici/library/radixP.h
	$SOURCE_PATH/ici/sdr/sdrP.h
# LTP
	$SOURCE_PATH/ltp/include/ltp.h
	$SOURCE_PATH/ltp/include/sda.h
	$SOURCE_PATH/ltp/library/ltpei.h
	$SOURCE_PATH/ltp/library/ltpP.h
	$SOURCE_PATH/ltp/udp/udplsa.h
	)

SCRIPTS=(
	$SOURCE_PATH/ionstart
	$SOURCE_PATH/ionstop
	$SOURCE_PATH/ionstart.awk
	$SOURCE_PATH/killm
		)

MANPAGE=(
# BPv7
	$SOURCE_PATH/bpv7/doc/pod1/bpadmin.pod
	$SOURCE_PATH/bpv7/doc/pod1/bpchat.pod
	$SOURCE_PATH/bpv7/doc/pod1/bpclm.pod
	$SOURCE_PATH/bpv7/doc/pod1/bpclock.pod
	$SOURCE_PATH/bpv7/doc/pod1/bpcounter.pod
	$SOURCE_PATH/bpv7/doc/pod1/bpdriver.pod
	$SOURCE_PATH/bpv7/doc/pod1/bpecho.pod
	$SOURCE_PATH/bpv7/doc/pod1/bping.pod
	$SOURCE_PATH/bpv7/doc/pod1/bplist.pod
	$SOURCE_PATH/bpv7/doc/pod1/bprecvfile.pod
	$SOURCE_PATH/bpv7/doc/pod1/bpsendfile.pod
	$SOURCE_PATH/bpv7/doc/pod1/bpsink.pod
	$SOURCE_PATH/bpv7/doc/pod1/bpsource.pod
	$SOURCE_PATH/bpv7/doc/pod1/bpstats.pod
	$SOURCE_PATH/bpv7/doc/pod1/bptrace.pod
	$SOURCE_PATH/bpv7/doc/pod1/bptransit.pod
	$SOURCE_PATH/bpv7/doc/pod1/ipnadmin.pod
	$SOURCE_PATH/bpv7/doc/pod1/ipnadminep.pod
	$SOURCE_PATH/bpv7/doc/pod1/ipnfw.pod
	$SOURCE_PATH/bpv7/doc/pod1/lgagent.pod
	$SOURCE_PATH/bpv7/doc/pod1/lgsend.pod
	$SOURCE_PATH/bpv7/doc/pod1/ltpcli.pod
	$SOURCE_PATH/bpv7/doc/pod1/ltpclo.pod
	$SOURCE_PATH/bpv7/doc/pod1/stcpcli.pod
	$SOURCE_PATH/bpv7/doc/pod1/stcpclo.pod
	$SOURCE_PATH/bpv7/doc/pod1/udpcli.pod
	$SOURCE_PATH/bpv7/doc/pod1/udpclo.pod
# CFDP
	$SOURCE_PATH/cfdp/doc/pod1/bpcp.pod
	$SOURCE_PATH/cfdp/doc/pod1/bpcpd.pod
	$SOURCE_PATH/cfdp/doc/pod1/bputa.pod
	$SOURCE_PATH/cfdp/doc/pod1/cfdpadmin.pod
	$SOURCE_PATH/cfdp/doc/pod1/cfdpclock.pod
	$SOURCE_PATH/cfdp/doc/pod1/cfdptest.pod
	$SOURCE_PATH/cfdp/doc/pod3/cfdp.pod
	$SOURCE_PATH/cfdp/doc/pod5/cfdprc.pod
# ICI
	$SOURCE_PATH/ici/doc/pod1/ionadmin.pod
	$SOURCE_PATH/ici/doc/pod1/owltsim.pod
	$SOURCE_PATH/ici/doc/pod1/psmwatch.pod
	$SOURCE_PATH/ici/doc/pod1/rfxclock.pod
	$SOURCE_PATH/ici/doc/pod1/sdrwatch.pod
# LTP
	$SOURCE_PATH/ltp/doc/pod1/ltpadmin.pod
	$SOURCE_PATH/ltp/doc/pod1/ltpclock.pod
	$SOURCE_PATH/ltp/doc/pod1/ltpmeter.pod
	$SOURCE_PATH/ltp/doc/pod1/udplsi.pod
	$SOURCE_PATH/ltp/doc/pod1/udplso.pod
# Restart
	$SOURCE_PATH/restart/doc/pod1/ionrestart.pod
	)

TEST_SCRIPTS=(
	$SOURCE_PATH/tests/runtests
	$SOURCE_PATH/tests/cleanup
	$SOURCE_PATH/tests/setacs.sh
	# system_up will be link directly to root folder in ion-core
	#$SOURCE_PATH/system_up
)

TEST_DIRS=(
	$SOURCE_PATH/demos/bench-udp
	$SOURCE_PATH/demos/bench-ltp
	$SOURCE_PATH/demos/bench-stcp
	$SOURCE_PATH/demos/bench-cfdp
#	To Do: Add issue-352-bpcp-ltp and stcp tests for 4.1.3s
)

# Function to clear the content of a directory
clear_directory() {
    if [ -d "$1" ] && [ "$(ls -A "$1")" ]; then
        echo "Clearing contents of: $1"
        rm -rf "$1"/*
    else
        echo "Directory $1 is empty."
    fi
}

# Clear the directories
clear_directory "$SRC"
clear_directory "$INC"
clear_directory "$OUT_BIN"
clear_directory "$TESTS"

# Extract .c files
echo "Extracting source .c files from $SOURCE_PATH to $SRC"
count=0
while [ "x${SOURCES[count]}" != "x" ]
do
    # Get the target source file path
    target="${SOURCES[count]}"
    
    # Extract the filename from the full path
    filename=$(basename "$target")
    
    # Destination path
    destination="$SRC/$filename"
    
    # Create symbolic link in the src directory
    if ln -s "$target" "$destination"
    then
        echo "Linked $target to $destination"
    else
        echo "ERROR: $target is missing or has moved. Aborting."
        exit 1
    fi
    
    count=$((count + 1))
done

# Extract .h files
echo "Extracting header .h files from $SOURCE_PATH to $INC"
count=0
while [ "x${HEADERS[count]}" != "x" ]
do
    # Get the target header file path
    target="${HEADERS[count]}"
    
    # Extract the filename from the full path
    filename=$(basename "$target")
    
    # Destination path in $INC
    destination="$INC/$filename"
    
    # Create symbolic link in the INC directory
    if ln -s "$target" "$destination"
    then
        echo "Linked $target to $destination"
    else
        echo "ERROR: $target is missing or has moved. Aborting."
        exit 1
    fi
    
    count=$((count + 1))
done

# Extract ION scripts
echo "Extracting ION scripts from $SOURCE_PATH to $OUT_BIN"
count=0
while [ "x${SCRIPTS[count]}" != "x" ]
do
    # Get the target script file path
    target="${SCRIPTS[count]}"
    
    # Extract the filename from the full path
    filename=$(basename "$target")
    
    # Destination path in $OUT_BIN
    destination="$OUT_BIN/$filename"
    
    # Create symbolic link in the OUT_BIN directory
    if ln -s "$target" "$destination"
    then
        echo "Linked $target to $destination"
    else
        echo "ERROR: $target is missing or has moved. Aborting."
        exit 1
    fi
    
    count=$((count + 1))
done


# Extract man page .pod files
echo "Linking man page .pod files from $SOURCE_PATH to $SRC/man"

# Create the directory, if it doesn't exist.
mkdir -p "$SRC/man"

count=0
while [ "x${MANPAGE[count]}" != "x" ]
do
    # Get the target man page file path
    target="${MANPAGE[count]}"
    
    # Extract the filename from the full path
    filename=$(basename "$target")
    
    # Destination path in $SRC/$MAN
    destination="$SRC/man/$filename"
    
    # Create symbolic link in the MAN directory
    if ln -s "$target" "$destination"
    then
        echo "Linked $target to $destination"
    else
        echo "ERROR: $target is missing or has moved. Aborting."
        exit 1
    fi
    
    count=$((count + 1))
done


# Extract regression test scripts
echo "Extracting test scripts from $SOURCE_PATH to $TESTS"
count=0
while [ "x${TEST_SCRIPTS[count]}" != "x" ]
do
    # Get the target test script file path
    target="${TEST_SCRIPTS[count]}"
    
    # Extract the filename from the full path
    filename=$(basename "$target")
    
    # Destination path in $TESTS
    destination="$TESTS/$filename"
    
    # Create symbolic link in the TESTS directory
    if ln -s "$target" "$destination"
    then
        echo "Linked $target to $destination"
    else
        echo "ERROR: $target is missing or has moved. Aborting."
        exit 1
    fi
    
    count=$((count + 1))
done

# Link the 'system_up' script 
# Check if system_up symlink or file exists from previous runs and remove it
if [ -L "$ROOT_DIR/system_up" ] || [ -e "$ROOT_DIR/system_up" ]; then
  echo "'system_up' already exists. Removing it..."
  rm -f "$ROOT_DIR/system_up"
fi

echo "Link 'system_up' script in root directory"
ln -s "$SOURCE_PATH/system_up" "$ROOT_DIR/system_up"


# Extract test sets
echo "Extracting test sets from $SOURCE_PATH to $TESTS"
count=0
while [ "x${TEST_DIRS[count]}" != "x" ]
do
    # Get the target test set directory path
    target="${TEST_DIRS[count]}"
    
    # Extract the filename from the full path
    filename=$(basename "$target")
    
    # Destination path in $TESTS
    destination="$TESTS/$filename"
    
    # Create symbolic link in the TESTS directory
    if ln -s "$target" "$destination"
    then
        echo "Linked $target to $destination"
    else
        echo "ERROR: $target is missing or has moved. Aborting."
        exit 1
    fi
    
    count=$((count + 1))
done


#
# Copy modified ION-core version of bpextension.c to original source code
# Modified bpextension.c support custom build options in build-list.mk
echo "Replacing bpextension with customized ion-core version in ./scripts"
symlink="$INC/bpextensions.c"
target=$(ls -l "$symlink" | sed 's/.* -> //')
cp $SCRIPT_DIR/bpextensions-ion-core.c $target
echo "Overwritten source file: $target"

echo "Updating path to header file bpsecadmin_config.h in file bpsec_policy_rule.c"

# Resolve the symlink and apply sed to the target file
# Some sed do not follow symlinks, so use readlink to get the real path
symlink="$SRC/bpsec_policy_rule.c"
target=$(ls -l "$symlink" | sed 's/.* -> //')

# Output the actual target
sed $SED_INPLACE 's!#include "../../utils/bpsecadmin_config.h"!#include "bpsecadmin_config.h"!g' $target
echo "Apply modification source file: $target"

echo "Done"
exit

###################################



