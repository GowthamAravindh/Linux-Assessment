#!/bin/bash

ERROR_LOG="errors.log"

# Clear previous error log
> "$ERROR_LOG"

show_help() {
cat << EOF
Usage: $0 [OPTIONS]

Options:
  -d <directory>   Directory to search recursively
  -f <file>        File to search directly
  -k <keyword>     Keyword to search
  --help           Display this help menu

Examples:
  $0 -d logs -k error
  $0 -f script.sh -k TODO
  $0 --help
EOF
}


log_error() {
    echo "ERROR: $1" | tee -a "$ERROR_LOG"
}

recursive_search() {
    local dir="$1"
    local keyword="$2"

    for item in "$dir"/*; do
        if [ -d "$item" ]; then
            recursive_search "$item" "$keyword"
        elif [ -f "$item" ]; then
            if grep -q "$keyword" "$item" 2>>"$ERROR_LOG"; then
                echo "Match found in: $item"
            fi
        fi
    done
}


if [ "$#" -eq 0 ]; then
    log_error "No arguments provided. Use --help."
    exit 1
fi

while getopts ":d:f:k:-:" opt; do
    case "$opt" in
        d) DIR="$OPTARG" ;;
        f) FILE="$OPTARG" ;;
        k) KEYWORD="$OPTARG" ;;
        -)
            if [ "$OPTARG" = "help" ]; then
                show_help
                exit 0
            fi
            ;;
        \?)
            log_error "Invalid option: -$OPTARG"
            exit 1
            ;;
        :)
            log_error "Option -$OPTARG requires an argument"
            exit 1
            ;;
    esac
done


if [ -z "$KEYWORD" ]; then
    log_error "Keyword cannot be empty"
    exit 1
fi

if [[ ! "$KEYWORD" =~ ^[a-zA-Z0-9_]+$ ]]; then
    log_error "Invalid keyword format"
    exit 1
fi

# ================================
# File search
# ================================
if [ -n "$FILE" ]; then
    if [ ! -f "$FILE" ]; then
        log_error "File does not exist: $FILE"
        exit 1
    fi

    echo "Searching for '$KEYWORD' in file: $FILE"
    grep --color=auto "$KEYWORD" "$FILE" 2>>"$ERROR_LOG"
    exit 0
fi


if [ -n "$DIR" ]; then
    if [ ! -d "$DIR" ]; then
        log_error "Directory does not exist: $DIR"
        exit 1
    fi

    echo "Recursively searching for '$KEYWORD' in directory: $DIR"
    recursive_search "$DIR" "$KEYWORD"
    exit 0
fi

log_error "Invalid usage. Use --help."
exit 1
