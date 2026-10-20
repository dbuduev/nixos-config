# Log in to a captive-portal WiFi (e.g. public library).
#
# System DNS is pinned to blocky -> DoH, so portal hostnames that only the
# hotspot's own resolver knows never resolve.
# This temporarily points /etc/resolv.conf at the DHCP-provided DNS server,
# opens an HTTP page the portal can hijack, waits until real internet access
# is confirmed (or you press Enter), then restores the original resolv.conf.

probe_url="http://nmcheck.gnome.org/check_network_status.txt"
open_url="${1:-http://captive.apple.com/hotspot-detect.html}"

dev=$(nmcli -g DEVICE,TYPE,STATE device | awk -F: '$2=="wifi" && $3=="connected" {print $1; exit}')
if [[ -z "$dev" ]]; then
  echo "captive-login: no connected wifi device" >&2
  exit 1
fi

# nmcli joins multiple servers with " | "; take the first one.
dns=$(nmcli -g IP4.DNS device show "$dev" | sed 's/ |.*//')
if [[ -z "$dns" ]]; then
  echo "captive-login: $dev has no DHCP-provided DNS server" >&2
  exit 1
fi

backup=$(mktemp)
cp /etc/resolv.conf "$backup"

restore() {
  sudo cp "$backup" /etc/resolv.conf
  rm -f "$backup"
  echo "captive-login: restored system DNS (blocky)"
}
trap restore EXIT

echo "captive-login: $dev -> using DHCP DNS $dns until login completes"
printf 'nameserver %s\n' "$dns" | sudo tee /etc/resolv.conf >/dev/null

online() {
  curl -fsS --max-time 5 "$probe_url" 2>/dev/null | grep -q "NetworkManager is online"
}

if online; then
  echo "captive-login: already online, nothing to do"
  exit 0
fi

xdg-open "$open_url" >/dev/null 2>&1 &
echo "captive-login: opened $open_url in your browser"
echo "captive-login: waiting for internet access (press Enter to stop early)..."

while ! online; do
  if read -r -t 5; then
    echo "captive-login: stopped by user"
    exit 0
  fi
done
echo "captive-login: online"
