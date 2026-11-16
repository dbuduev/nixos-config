# Niri Cheatsheet

Scrollable-tiling Wayland compositor (zenbook), selectable in GDM next to GNOME.
Bindings reflect `home/niri/config.kdl`. They follow the PaperWM conventions
(`cheatsheets/paperwm.md`); differences are marked ≠.

> **Super = Caps Lock (held)** via keyd. `Super+Shift+/` shows niri's own hotkey overlay.

## Getting in and out

| Action | How |
|---|---|
| Start a niri session | GDM password screen → gear icon (bottom right) → **Niri** |
| Back to GNOME | `Super+Shift+E` (confirm) → pick **GNOME** in GDM |
| Reload config | automatic on `just switch` (niri watches the file) |
| Check config | `niri validate` |

## Programs

| Action | Binding |
|---|---|
| Terminal (Ghostty) | `Super+G` |
| ≠ Terminal on devvm (pick or name a persistent zmx session) | `Super+Alt+G` |
| ≠ App launcher (fuzzel) | `Super+D` |
| ≠ Overview | `Super+A` (or top-left hot corner / 4-finger swipe up) |
| Window switcher with titles | `Alt+Tab` / `Super+Tab` |
| Lock screen | `Super+Ctrl+Delete` |
| Close window | `Super+Backspace` |

## Focus and move

| Action | Binding |
|---|---|
| Focus column left / right (wraps) | `Super+h` / `Super+l` |
| Focus window up / down in column (wraps) | `Super+k` / `Super+j` |
| First / last column | `Super+Home` / `Super+End` |
| Move column left / right | `Super+Shift+h` / `Super+Shift+l` |
| Move window up / down in column | `Super+Shift+k` / `Super+Shift+j` |

## Columns and stacking

| Action | Binding |
|---|---|
| Slurp: pull window from the right column into yours | `Super+i` |
| Barf: expel window into its own column | `Super+o` |
| Expel the focused window to the right | `Super+Shift+o` |
| ≠ Toggle column as tabs | `Super+w` |

## Sizing

| Action | Binding |
|---|---|
| Cycle column width (⅓ / ½ / ⅔) | `Super+r` (back: `Super+Alt+r`) |
| Cycle window height | `Super+Shift+r` (back: `Super+Alt+Shift+r`) |
| Reset window height | `Super+Ctrl+r` |
| Maximize column / fullscreen | `Super+f` / `Super+Shift+f` |
| Fill remaining width | `Super+Ctrl+f` |
| Center column | `Super+c` |
| Fine width − / + | `Super+-` / `Super+=` |
| Fine height − / + | `Super+Shift+-` / `Super+Shift+=` |

## Displays

| Action | Modifier (+ `hjkl`) |
|---|---|
| Focus other display | `Super+Ctrl+` |
| Move focused window to other display | `Super+Ctrl+Shift+` |
| Move workspace to other display | `Super+Alt+Shift+` |

> ≠ No "swap workspaces between displays" (`Super+Alt+hjkl` in PaperWM).
> Displays are stacked vertically (Dell above, laptop panel below), so
> `j`/`k` are the live keys; `h`/`l` no-op.

## Workspaces

| Action | Binding |
|---|---|
| Jump to workspace 1–4 | `Super+1` … `Super+4` |
| Send window to workspace 1–4 (follows) | `Super+Shift+1` … `Super+Shift+4` |
| Workspace down / up | `Super+PageDown` / `Super+PageUp` |
| Move window to workspace down / up | `Super+Ctrl+PageDown` / `Super+Ctrl+PageUp` |
| Previous workspace | ``Super+` `` |

> ≠ Workspaces are dynamic and per display: there is always exactly one empty
> workspace after the used ones, and an index past the end lands on it.

## Floating

| Action | Binding |
|---|---|
| Toggle window floating | `Super+Escape` |
| Switch focus floating ↔ tiling | `Super+Shift+Escape` |

## Misc

| Action | Binding |
|---|---|
| Screenshot region / screen / window | `Print` / `Ctrl+Print` / `Alt+Print` |
| Power off monitors | `Super+Shift+P` |
| Un-stick shortcuts grabbed by an app | `Super+Ctrl+Escape` |

## Gotchas

- **Output positions are pinned** in `home/niri/config.kdl` (`HDMI-A-1` above
  `eDP-1`). On a different external monitor, check `niri msg outputs` and
  adjust; an unknown output is placed to the right automatically.
- **X11 apps** run through `xwayland-satellite`, which niri starts on demand.
- **Polkit agent**: `polkit-gnome-agent.service` (user unit, niri only) draws GUI
  privilege prompts. Check it with `systemctl --user status polkit-gnome-agent`.
- Bar, notifications, lock and idle-lock are separate programs: waybar
  (`home/niri/waybar.jsonc`), mako, swaylock, swayidle (10 min + before suspend).
- **Bluetooth has no GUI or bar entry**; use `bluetoothctl` (run it bare for an
  interactive prompt with MAC completion). `power on|off`, `devices`,
  `connect|disconnect <MAC>`; new device: `scan on`, then `pair`, `trust`,
  `connect <MAC>`. Paired devices reconnect on their own. If this gets
  tedious, `bluetui` (in nixpkgs) is the `nmtui`-style option, not installed.
