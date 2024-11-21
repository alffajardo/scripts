#!/bin/bash

# Check if directory is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

# Directory to process
TARGET_DIR="$1"

# Find all files and directories recursively in the target directory
find "$TARGET_DIR" -print0 | while IFS= read -r -d '' file; do
    # Check if the file has the quarantine attribute
    if xattr -p com.apple.quarantine "$file" &>/dev/null; then
        # Remove the quarantine attribute
        xattr -d com.apple.quarantine "$file"
        echo "Removed quarantine attribute from: $file"
    fi
done

echo "All files in $TARGET_DIR have been processed."
