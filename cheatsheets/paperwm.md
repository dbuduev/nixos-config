# PaperWM Cheatsheet

Scrollable-tiling for GNOME (zenbook). Bindings reflect *this* config
(`home/home.nix` → `dconf.settings`) over PaperWM v143 defaults.

**Legend:** ★ = customized/added in our config · ⚠ = known GNOME conflict (see Gotchas)

> **Super = Caps Lock (held)** — remapped via keyd (`hosts/zenbook/configuration.nix`). Every `Super+…` chord below is a Caps-hold. Control is on the physical Left-Ctrl key.

## Mental model

- The workspace is an **infinite horizontal strip of columns**; you scroll focus across it.
- A **column** holds one or more windows **stacked vertically, all visible** at once (≈ tmux panes).
- Only the columns that fit on screen are shown; the rest scroll off the edges.
- Each **monitor** is its own independent strip; each has its own stack of **workspaces**.
- Mapping from tmux: column-stack ≈ panes · horizontal scroll ≈ a filmstrip of windows (multiple visible at once, unlike tmux).

## Focus (move the highlight)

| Action | Binding |
|---|---|
| ★ Focus column left / right | `Super+h` / `Super+l`  (or `Super+←/→`) |
| ★ Focus window up / down in column | `Super+k` / `Super+j`  (or `Super+↑/↓`) |
| Focus next / previous column | `Super+.` / `Super+,` |
| Last column | `Super+End` |
| Window switcher (live preview) | `Super+Tab` / `Super+Shift+Tab`  ⚠ |

## Move windows (within the strip)

| Action | Binding |
|---|---|
| ★ Move window left / right | `Super+Shift+h` / `Super+Shift+l`  (or `Super+Ctrl+←/→`) |
| ★ Move window up / down in column | `Super+Shift+k` / `Super+Shift+j`  (or `Super+Ctrl+↑/↓`) |
| Take window (grab, scroll, drop) | `Super+t` |

## Columns & stacking (≈ tmux join/break-pane)

| Action | Binding | Note |
|---|---|---|
| Slurp window in | `Super+i` | pulls the **top** window of the right column onto the **bottom** of yours — one at a time |
| Barf window out | `Super+o` | ejects the **bottom** window of your column into a new column |
| Barf the *focused* window out | `Super+Shift+o` | ejects whichever window you're on |

## Sizing

| Action | Binding |
|---|---|
| Cycle column **width** (⅓ / ½ / ⅔ …) | `Super+r`  (back: `Super+Alt+r`) |
| Cycle window **height** | `Super+Shift+r`  (back: `Super+Alt+Shift+r`) |
| Maximize width | `Super+f` |
| Toggle fullscreen | `Super+Shift+f` |
| Fine resize width − / + | `Super+-` / `Super++` |
| Fine resize height − / + | `Super+Shift+-` / `Super+Shift++` |
| Center column horizontally | `Super+c` |
| Center column vertically | `Super+v`  ⚠ |

> `R` cycles size, `Shift` makes it vertical. The `+/-` fine-resize is awkward on the AU layout (`+` = `Shift+=`); lean on the `R` cyclers.

## Across displays (multi-monitor)

| Action | Binding |
|---|---|
| ★ Focus other display | `Super+Ctrl+h` / `Super+Ctrl+l` |
| ★ Move focused window to other display | `Super+Ctrl+Shift+h` / `Super+Ctrl+Shift+l` |
| Swap the two displays' workspaces | `Super+Alt+←` / `Super+Alt+→` |

> `move`-to-display moves the **focused window only**, not a whole multi-window column.
> The arrow-key monitor defaults (`Super+Shift+←/→`) are dead — GNOME grabs them; use the hjkl set above. For vertically stacked displays, ask to add `Super+Ctrl+j/k`.

## Workspaces (4 fixed, per monitor)

| Action | Binding |
|---|---|
| ★ Jump to workspace 1–4 | `Super+1` … `Super+4` |
| ★ Send window to workspace 1–4 (follows) | `Super+Shift+1` … `Super+Shift+4` |
| Switch workspace down / up | `Super+PageDown` / `Super+PageUp` |
| Move window to workspace down / up | `Super+Ctrl+PageDown` / `Super+Ctrl+PageUp` |
| Toggle to previous workspace | ``Super+` `` (key above Tab) |

> 4 fixed workspaces (`dynamic-workspaces = false`). `Super+1..4` are direct jumps — GNOME's dash app-launch was cleared off those keys (`Super+5..9` still launch favourites).

## Windows & apps

| Action | Binding |
|---|---|
| New window of focused app | `Super+Return`  /  `Super+n` |
| Close window | `Super+Backspace` |
| ★ Launch a terminal (Ghostty) from anywhere | `Super+G` |
| Minimize | *(disabled — tiling doesn't use it)* |

## Scratch layer (floating)

| Action | Binding |
|---|---|
| Toggle window to/from scratch | `Super+Escape` |
| Toggle scratch layer visibility | `Super+Shift+Escape` |
| Show only scratch | `Super+Ctrl+Escape` |

## Misc

| Action | Binding |
|---|---|
| Cycle focus mode (default / center / edge) | `Super+Shift+c` |
| Toggle top + position bar | `Super+Ctrl+b` |
| ★ Lock screen | `Super+Ctrl+Delete` |

## Terminal companion (Ghostty, not PaperWM)

| Action | Binding |
|---|---|
| ★ Scrollback → clipboard path (then `hx ` + `Ctrl+Shift+V`) | `Ctrl+Shift+Y` |
| Search scrollback | `Ctrl+Shift+F` … `Esc` |
| Jump prompt-to-prompt | `Ctrl+Shift+PageUp` / `PageDown` |
| Copy / paste | `Ctrl+Shift+C` / `Ctrl+Shift+V` |
| ★ Toggle window decorations | `Ctrl+Shift+D` |
| Reload ghostty config | `Ctrl+Shift+,` |

## The hjkl logic (one rule)

| Level | Focus | Move window |
|---|---|---|
| Strip (columns) | `Super+h/j/k/l` | `Super+Shift+h/j/k/l` |
| Displays | `Super+Ctrl+h/l` | `Super+Ctrl+Shift+h/l` |

`Ctrl` raises the level (strip → display); `Shift` moves the window instead of the focus.

## Gotchas (⚠)

- **GNOME wins `Super+Shift+arrow`** (its own move-to-monitor) — that's why PaperWM's arrow monitor-defaults don't fire. We rebound monitor moves to **hjkl** (above). Letter combos sidestep GNOME entirely.
- **`Super+v`** (center vertically) and **`Super+Tab`** (window switcher) overlap GNOME's message-tray / app-switcher and may be swallowed. If one doesn't work, GNOME is grabbing it — we can rebind it the way we did the monitor keys.
- **`Super+Ctrl+l` is NOT lock** here — it's focus-other-display. Lock moved to `Super+Ctrl+Delete`.
- **PaperWM clears GNOME keys that collide with its own bindings** (`overrideConflicts`). This silently wiped `Super+1` (workspace 1): GNOME's `switch-to-workspace-1` defaults to `Super+Home`, which collided with PaperWM's `switch-first` — so `switch-first` is unbound here to free it. Lesson: if a GNOME keybind you set declaratively keeps reverting, check whether its *default* combo collides with a PaperWM binding.
- All bindings live in `home/home.nix`; gaps are **2px window-gap, 0 margins** (PaperWM default is 20 everywhere). PaperWM re-reads keybindings live on `just switch`; the GNOME custom keys (`Super+G`, lock) apply live too.
