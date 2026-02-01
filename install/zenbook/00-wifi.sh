#!/usr/bin/env bash
set -euo pipefail

# Connect to WiFi network
# Usage: ./00-wifi.sh "SSID" "PASSWORD"

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <SSID> <PASSWORD>"
    exit 1
fi

SSID="$1"
PASSWORD="$2"

echo "=== Connecting to WiFi ==="

# Add and configure network
NETWORK_ID=$(wpa_cli -i wlan0 add_network | tail -1)
wpa_cli -i wlan0 set_network "$NETWORK_ID" ssid "\"$SSID\""
wpa_cli -i wlan0 set_network "$NETWORK_ID" psk "\"$PASSWORD\""
wpa_cli -i wlan0 set_network "$NETWORK_ID" key_mgmt WPA-PSK
wpa_cli -i wlan0 enable_network "$NETWORK_ID"

echo "Waiting for connection..."
sleep 5

# Verify connectivity
if ping -c 3 nixos.org > /dev/null 2>&1; then
    echo "=== Connected successfully ==="
else
    echo "=== Connection failed. Check SSID/password or try manually ==="
    exit 1
fi
