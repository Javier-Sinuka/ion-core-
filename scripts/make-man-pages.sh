#!/usr/bin/env bash

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

# Debugging output
echo "SOURCE_PATH = $SOURCE_PATH"
echo "POD_DIR = $POD_DIR"

for prog in "${prog_array[@]}"; do
    full_path="${POD_DIR}/${prog}.pod"
    echo "Checking ${full_path}..."

    if [[ -f "$full_path" ]]; then
        echo "File found: $(ls -l "$full_path")"
        if $POD2MAN "$full_path" | gzip -c > "${MAN_OUTPUT_DIR}/${prog}.1.gz"; then
            echo "Generated man page for $prog"
        else
            echo "ERROR: Failed to generate man page for $prog"
        fi
    else
        echo "Documentation for $prog is not available."
        echo "ls output for $full_path: $(ls -l "$full_path")"
        echo "Target file for symlink: $(readlink "$full_path")"
    fi
done
