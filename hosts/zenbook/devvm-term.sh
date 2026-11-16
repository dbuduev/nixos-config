# Open a Ghostty window attached to a persistent zmx session on devvm.
#
# Lists the VM's sessions in fuzzel: pick one to reattach, or type a new name
# to create it. The session lives on the VM, so closing the window (or
# restarting Ghostty) only detaches; the shell keeps running.
#
# Sessions that already have a terminal are listed last and marked
# "(attached)"; picking one mirrors it rather than opening a second shell.
#
# Bound to Mod+Alt+G in home/niri/config.kdl.

host=devvm

notify() {
  notify-send --app-name="$host" "$1" "${2:-}"
}

rc=0
listing=$(ssh -o BatchMode=yes -o ConnectTimeout=3 "$host" zmx ls 2>/dev/null) || rc=$?
if [ "$rc" -eq 255 ]; then
  notify "$host is not reachable" "Start it with: just vm-start"
  exit 1
elif [ "$rc" -ne 0 ]; then
  notify "zmx failed on $host (exit $rc)" "Is zmx installed? Rebuild with: just vm-build"
  exit 1
fi

# `zmx ls` prints one session per line as tab-separated key=value fields,
# e.g. "  name=api<TAB>pid=123<TAB>clients=1<TAB>...". Anything else (such as
# "no sessions found") has no name= field and is skipped.
marker="  (attached)"
sessions=$(
  printf '%s\n' "$listing" | awk -F'\t' -v marker="$marker" '
    {
      name = ""; clients = 0
      for (i = 1; i <= NF; i++) {
        if (i == 1 && match($i, /name=/)) name = substr($i, RSTART + 5)
        else if ($i ~ /^clients=/) clients = substr($i, 9) + 0
      }
      if (name == "") next
      if (clients > 0) attached = attached name marker "\n"
      else printf "%s\n", name
    }
    END { printf "%s", attached }
  '
)

name=$(
  if [ -n "$sessions" ]; then printf '%s\n' "$sessions"; fi |
    fuzzel --dmenu --prompt "$host session> "
) || exit 0
name=${name%"$marker"}
[ -n "$name" ] || exit 0

# The name is interpolated into a remote shell command, so keep it boring.
if ! [[ $name =~ ^[A-Za-z0-9._-]+$ ]]; then
  notify "Invalid session name: $name" "Use letters, digits, dot, dash or underscore."
  exit 1
fi

exec ghostty -e ssh -t "$host" zmx attach "$name"
