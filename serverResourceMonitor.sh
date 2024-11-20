#!/bin/bash
server_table_name="bcl_pro_servers"

ip_address=$(curl -s ipinfo.io/ip)
ram_usage=$(awk '/MemTotal/ {total=$2} /MemAvailable/ {available=$2} END {print ((total - available) / total) * 100}' /proc/meminfo)
disk_usage=$(df -h --output=pcent / | tail -n 1 | tr -d '%')
cpu_usage=$(awk '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else printf "%.2f\n", ($2+$4-u1) * 100 / (t-t1); }' <(grep 'cpu ' /proc/stat) <(
  sleep 5
  grep 'cpu ' /proc/stat
))

# Check if ifstat is installed
if ! command -v ifstat &>/dev/null; then
  echo "ifstat is not installed. Installing it now..."

  # Check the package manager (apt for Debian/Ubuntu, yum for CentOS)
  if command -v apt-get &>/dev/null; then
    sudo apt-get update
    sudo apt-get install -y ifstat
  elif command -v yum &>/dev/null; then
    sudo yum install -y ifstat
  else
    echo "Unsupported package manager. Please install ifstat manually."
    exit 1
  fi

  echo "ifstat is now installed."
else
  echo "ifstat is already installed."
fi

# Function to get the active network interface
get_active_interface() {
  # Use ip command to get the active network interface
  ip route get 8.8.8.8 | awk '{print $5; exit}'
}

# Get the active network interface
interface=$(get_active_interface)

# Check if the interface is not empty
if [ -n "$interface" ]; then
  # Get the network speed using ifstat
  network_speed=$(ifstat -i "$interface" 1 1 | tail -n 1 | awk '{print $1, $2}')

  # Extract inbound and outbound speeds into variables (in Kbit/s)
  inbound_speed_kb=$(echo "$network_speed" | awk '{printf "%.2f", $1}')
  outbound_speed_kb=$(echo "$network_speed" | awk '{printf "%.2f", $2}')

  # Print the values
  echo "Inbound Speed: $inbound_speed_kb Kbit/s"
  echo "Outbound Speed: $outbound_speed_kb Kbit/s"
else
  echo "Error: Unable to determine the active network interface."
fi

TOKEN="c2Rma2xqanNsZGZrc2xrZGZqc2xramZsc2RramZsc2tkZmpsa2RzZg=="
#Set the URL endpoint
URL="http://monitoring-api-vpn.interlinkapi.com/bcl-server/save-server-resource-consumption-data"
#JSON data to be sent in the request body
DATA="ip=$ip_address&ram=$ram_usage&cpu=$cpu_usage&disk=$disk_usage&bw_inbound=$inbound_speed_kb&bw_outbound=$outbound_speed_kb&server_table_name=$server_table_name"
#Make the POST request using CURL
response=$(curl -X POST -H "Authorization: $TOKEN" -d "$DATA" "$URL")
