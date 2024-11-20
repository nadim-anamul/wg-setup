#!/bin/bash

# Define file paths
SOURCE_FILE="/root/wg-setup/serverResourceMonitor.sh"
TARGET_FILE="/root/bcl-vpn-scripts/serverResourceMonitor.sh"

# Check if source file exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: Source file $SOURCE_FILE does not exist."
    exit 1
fi

# Create a backup of the target file if it exists
if [ -f "$TARGET_FILE" ]; then
    BACKUP_FILE="${TARGET_FILE}.bak"
    echo "Creating a backup of the target file at $BACKUP_FILE"
    cp "$TARGET_FILE" "$BACKUP_FILE"
fi

# Replace the target file with the source file
echo "Replacing $TARGET_FILE with $SOURCE_FILE"
cp "$SOURCE_FILE" "$TARGET_FILE"

# Set appropriate permissions
chmod +x "$TARGET_FILE"

echo "Replacement complete."
