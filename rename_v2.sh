#!/bin/bash

# Script Name: rename.sh
# Description: This script allows for batch renaming of files in the current directory. 
# It provides options to replace a specific string in file names with a new string. 
# Additionally, it can replace spaces in file names with underscores when invoked with the -s flag.
# Usage: ./rename.sh [-o <old_string>] [-n <new_string>] [-s] [-d]

# Function to display usage information
show_usage() {
    echo "Usage: $0 [-o <old_string>] [-n <new_string>] [-s] [-d]"
    echo "Options:"
    echo "  -o <old_string>   Specify the old string to replace"
    echo "  -n <new_string>   Specify the new string"
    echo "  -s                Replace spaces with underscores in file names"
    echo "  -d                Dry run mode (print changes without applying)"
    echo "  -h                Show this help message"
}

# Function to print in pink
print_pink() {
    echo -e "\e[95m$1\e[0m"
}

# Function to print in bold
print_bold() {
    echo -e "\e[1m$1\e[0m"
}

# Function to print an empty line
print_empty_line() {
    echo ""
}

# Function to get file extension
get_extension() {
    echo "${1##*.}"
}

# Function to get file name without extension
get_name_without_extension() {
    echo "${1%.*}"
}

# Initialize variables
old_string=""
new_string=""
replace_spaces=false
dry_run=false

# Get command line arguments
args=("$@")

# Parse command line arguments
for ((i=0; i<${#args[@]}; i++)); do
    if [[ ${args[i]} == "-o" ]]; then
        old_string=${args[i+1]}
    elif [[ ${args[i]} == "-n" ]]; then
        new_string=${args[i+1]}
    elif [[ ${args[i]} == "-s" ]]; then
        replace_spaces=true
    elif [[ ${args[i]} == "-d" ]]; then
        dry_run=true
    elif [[ ${args[i]} == "-h" ]]; then
        show_usage
        exit 0
    fi
done

# If no arguments are provided, display usage information
if [ $# -eq 0 ]; then
    show_usage
    exit 0
fi

# Check if replacing spaces is requested
if [ "$replace_spaces" = true ]; then
    for file in *; do
        if [ -f "$file" ]; then
            extension=$(get_extension "$file")
            name_without_extension=$(get_name_without_extension "$file")
            nuevo_nombre=$(echo "$name_without_extension" | tr ' ' '_')."$extension"
            if [ "$dry_run" = true ]; then
                print_pink "Replacing spaces with underscores in file name:"
                print_bold "$file -----> $nuevo_nombre"
                print_empty_line
            else
                mv "$file" "$nuevo_nombre"
                echo "File renamed: $file -> $nuevo_nombre"
            fi
        fi
    done
    exit 0
fi

# Check if the necessary arguments are provided
if [ -z "$old_string" ] || [ -z "$new_string" ]; then
    echo "Error: Missing required arguments."
    show_usage
    exit 1
fi

# Escape special characters in the old string
old_string_escaped=$(echo "$old_string" | sed 's/[]\/$*.^|[]/\\&/g')

# Iterate over files in the current directory
for file in *; do
    if [ -f "$file" ]; then
        extension=$(get_extension "$file")
        name_without_extension=$(get_name_without_extension "$file")
        # Check if the file contains the old string
        if [[ "$name_without_extension" == *"$old_string_escaped"* ]]; then
            # Rename the file by substituting the old string with the new one
            new_name=$(echo "$name_without_extension" | sed "s/$old_string_escaped/$new_string/g")
            nuevo_nombre="$new_name.$extension"
            if [ "$dry_run" = true ]; then
                print_pink "Replacing '$old_string' with '$new_string' in file name:"
                print_bold "$file -----> $nuevo_nombre"
                print_empty_line
            else
                mv "$file" "$nuevo_nombre"
                echo "File renamed: $file -> $nuevo_nombre"
            fi
        fi
    fi
done

