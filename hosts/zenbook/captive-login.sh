# Log in to a captive-portal WiFi (e.g. public library).
#
# System DNS is pinned to blocky -> DoH, so portal hostnames that only the
# hotspot's own resolver knows never resolve. This temporarily points
# /etc/resolv.conf at the DHCP-provided DNS server, opens an HTTP page the
# portal can hijack, and waits until real internet access is confirmed.
#
# Then, if the network lets DoH through, it restores blocky and exits. Some
# networks intercept the public resolvers even after login; in that case it
# keeps the DHCP DNS and stays in the foreground until you press Enter or the
# WiFi disconnects, then restores blocky. Note: blocklists are bypassed while
# the DHCP DNS is in use.

probe_url="http://nmcheck.gnome.org/check_network_status.txt"
doh_url="https://1.1.1.1/dns-query?name=example.com&type=A"
open_url="${1:-http://captive.apple.com/hotspot-detect.html}"

dev=$(nmcli -g DEVICE,TYPE,STATE device | awk -F: '$2=="wifi" && $3=="connected" {print $1; exit}')
if [[ -z "$dev" ]]; then
  echo "captive-login: no connected wifi device" >&2
  exit 1
fi
conn=$(nmcli -g GENERAL.CONNECTION device show "$dev")

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

echo "captive-login: $conn ($dev) -> using DHCP DNS $dns"
printf 'nameserver %s\n' "$dns" | sudo tee /etc/resolv.conf >/dev/null

online() {
  curl -fsS --max-time 5 "$probe_url" 2>/dev/null | grep -q "NetworkManager is online"
}
doh_ok() {
  curl -fsS --max-time 5 -H 'accept: application/dns-json' "$doh_url" >/dev/null 2>&1
}
still_connected() {
  [[ "$(nmcli -g GENERAL.CONNECTION device show "$dev" 2>/dev/null)" == "$conn" ]]
}

# Wait for input for $1 seconds; returns 0 if the user pressed Enter.
wait_or_enter() { read -r -t "$1"; }

if ! online; then
  xdg-open "$open_url" >/dev/null 2>&1 &
  echo "captive-login: opened $open_url in your browser"
  echo "captive-login: waiting for internet access (press Enter to stop early)..."
  while ! online; do
    if wait_or_enter 5; then
      echo "captive-login: stopped by user"
      exit 0
    fi
  done
fi
echo "captive-login: online"

if doh_ok; then
  echo "captive-login: DoH upstreams reachable, handing DNS back to blocky"
  exit 0
fi

echo "captive-login: this network blocks DoH; keeping DHCP DNS $dns (blocklists bypassed)"
echo "captive-login: press Enter or disconnect from '$conn' to restore blocky"
while still_connected; do
  if wait_or_enter 5; then
    echo "captive-login: stopped by user"
    exit 0
  fi
done
echo "captive-login: '$conn' disconnected"
