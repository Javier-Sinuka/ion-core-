#!/bin/bash
SOURCE_PATH="$1"
PROGRAMS="$2"

# Check if SOURCE_PATH is provided
if [[ -z "$SOURCE_PATH" ]]; then
  echo "Error: You must supply a relative path to the ION open source code."
  exit 1
fi

# Check if PROGRAMS is provided
if [[ -z "$PROGRAMS" ]]; then
  echo "Error: You must supply a list of programs."
  exit 1
fi

POD2MAN=pod2man
POD_DIR="${SOURCE_PATH}/man"
MAN_OUTPUT_DIR="./man"

# Ensure the man output directory exists
mkdir -p "$MAN_OUTPUT_DIR"

# Split PROGRAMS into an array
IFS=' ' read -r -a prog_array <<< "$PROGRAMS"

for prog in "${prog_array[@]}"; do
	full_path="${POD_DIR}/$prog.pod"
	if [[ -f "$full_path" ]]; then
		if $POD2MAN "$full_path" | gzip -c > "${MAN_OUTPUT_DIR}/${prog}.1.gz"; then
			echo "Generated man page for $prog"
		else
			echo "ERROR: Failed to generate man page for $prog"
		fi
	else
		echo "Documentation for $prog is not available."
	fi
done
