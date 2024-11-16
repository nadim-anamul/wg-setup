#!/bin/bash
echo "Current time: $(date)"
get_default_gateway_interface() {
    ip route show default | awk '/default/ {print $5}'
}
echo $(get_default_gateway_interface)
# Detect internet gateway interface
internet_gateway=$(get_default_gateway_interface)

folder_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
file_path="$folder_path/wg0.conf"
WG_CONF_FILE="/etc/wireguard/wg0.conf"
SERVER_PRIVATE_KEY=$(sudo cat /etc/wireguard/private.key)
sudo chmod 744 $file_path
# Create a temporary file to hold the modified content
temp_file=$(mktemp)
# Update PrivateKey and internet_gateway with the actual values
sed -e "s|^PrivateKey = \"\"|PrivateKey = $SERVER_PRIVATE_KEY|" \
    -e "s|internet_gateway|$internet_gateway|g" "$file_path" > "$temp_file"
# Move the temporary file content to WG_CONF_FILE
mv "$temp_file" "$WG_CONF_FILE"
# Set correct permissions for the WireGuard config file
chmod 600 "$WG_CONF_FILE"

systemctl reload wg-quick@wg0.service
echo "Wireguard service reloaded successfully at:  $(date)"
echo "Wireguard service restart command started at:  $(date)" 
if sudo systemctl restart wg-quick@wg0.service; then
    echo "Wireguard service restarted successfully at:  $(date)"
fi
