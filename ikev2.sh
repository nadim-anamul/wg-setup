#!/bin/bash

# Define the script path
script_path="/root/bcl-vpn-scripts/ipsec-connection-up-down.sh"

# Check if the script exists
if [[ ! -f "$script_path" ]]; then
  echo "Error: Script $script_path does not exist."
  exit 1
fi

# Backup the original script before modifying
backup_path="${script_path}.bak"
cp "$script_path" "$backup_path"
echo "Backup created at $backup_path."

# Add server_table_name declaration
if ! grep -q 'server_table_name=' "$script_path"; then
  sed -i '/^domain=/a server_table_name="bcl_pro_servers"' "$script_path"
  echo "Added server_table_name declaration."
fi

# Modify ipsec-connection-up.sh call to include server_table_name
sed -i 's/\($folder_path\/ipsec-connection-up\.sh \S\+\s\S\+\s\S\+\s\S\+\)/\1 "$server_table_name"/' "$script_path"

# Modify ipsec-connection-down.sh call to include server_table_name
sed -i 's/\($folder_path\/ipsec-connection-down\.sh \S\+\s\S\+\)/\1 "$server_table_name"/' "$script_path"

echo "Modified $script_path to include server_table_name."

# Confirm changes
echo "Review the updated script to ensure correctness:"
echo "-------------------------------------------------"
cat "$script_path"
echo "-------------------------------------------------"


# Paths to the scripts
up_script="/root/bcl-vpn-scripts/ipsec-connection-up.sh"
down_script="/root/bcl-vpn-scripts/ipsec-connection-down.sh"

# Check if the scripts exist
if [[ ! -f "$up_script" || ! -f "$down_script" ]]; then
  echo "Error: One or both scripts do not exist."
  exit 1
fi

# Backup the original scripts
cp "$up_script" "${up_script}.bak"
cp "$down_script" "${down_script}.bak"
echo "Backups created: ${up_script}.bak and ${down_script}.bak"

# Modify ipsec-connection-up.sh
sed -i '/^domain=/a server_table_name="$5"' "$up_script" # Add server_table_name variable
sed -i '/^#JSON data to be sent in the request body$/,/^DATA=.*$/c\#JSON data to be sent in the request body\nDATA="ip=$ip&user_name=$user_name&client_ip=$client_ip&domain=$domain&server_table_name=$server_table_name"' "$up_script"
echo "Modified $up_script to include server_table_name."

# Modify ipsec-connection-down.sh
sed -i '/^user_name=/a server_table_name="$3"' "$down_script" # Add server_table_name variable
sed -i '/^DATA=.*$/c\DATA="ip=$ip&user_name=$user_name&server_table_name=$server_table_name"' "$down_script"
echo "Modified $down_script to include server_table_name."

# Confirm changes
echo "Updated $up_script and $down_script. Review changes below:"
echo "----------------------------------------------------------"
cat "$up_script"
echo "----------------------------------------------------------"
cat "$down_script"
echo "----------------------------------------------------------"

# Restart StrongSwan
sudo systemctl restart strongswan-starter
echo "Server restarted"
