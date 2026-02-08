#!/bin/bash

# ===============================
# Validate input
# ===============================
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="output.txt"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file does not exist"
    exit 1
fi

# Clear output file
> "$OUTPUT_FILE"

# ===============================
# Read input line by line
# ===============================
while IFS= read -r line; do

    # Extract frame.time
    if [[ "$line" == *"frame.time"* ]]; then
        value=$(echo "$line" | cut -d':' -f2- | xargs)
        echo "\"frame.time\": \"$value\"," >> "$OUTPUT_FILE"
    fi

    # Extract wlan.fc.type
    if [[ "$line" == *"wlan.fc.type"* ]]; then
        value=$(echo "$line" | cut -d':' -f2 | xargs)
        echo "\"wlan.fc.type\": \"$value\"," >> "$OUTPUT_FILE"
    fi

    # Extract wlan.fc.subtype
    if [[ "$line" == *"wlan.fc.subtype"* ]]; then
        value=$(echo "$line" | cut -d':' -f2 | xargs)
        echo "\"wlan.fc.subtype\": \"$value\"," >> "$OUTPUT_FILE"
    fi

done < "$INPUT_FILE"

echo "Extraction completed. Output saved to output.txt"

