# Lid Sleep

An [Omarchy](https://omarchy.org) bar widget plugin that toggles whether your laptop goes to sleep when the lid is closed.

## Behavior & Tooltips

- **Lid Sleep Allowed (Default):** Hover tooltip displays **`Prevent Lid Sleep`**. Clicking activates sleep inhibition so your laptop stays awake when the lid is closed. (Widget icon is quiet/dimmed).
- **Lid Sleep Prevented (Stay Awake):** Hover tooltip displays **`Enable Lid Sleep`**. Clicking releases the inhibitor lock, restoring normal sleep behavior. (Widget icon is highlighted/active).

## Features

- **Action-Oriented Tooltips:** Hovering tells you what clicking will do: **`Prevent Lid Sleep`** or **`Enable Lid Sleep`**.
- **One-Click Toggle:** Click the top bar icon (💻) to toggle lid sleep on or off.
- **Visual Feedback:** Highlights when lid sleep is inactive (stay-awake mode) to alert you that sleep is disabled.
- **Desktop Notifications:** Displays quick on-screen alerts when toggling.
- **Self-Contained:** Zero external configuration required. Runs entirely in user space.

## Installation

### Via Omarchy Plugin Manager

```bash
omarchy plugin add https://github.com/jdmu/lid-sleep.git --enable
```

### Manual Installation & Live Reload

Clone or copy this directory into your Omarchy plugins directory:

```bash
mkdir -p ~/.config/omarchy/plugins/
cp -r lid-sleep ~/.config/omarchy/plugins/
omarchy restart shell
```

## Removal

### Via Omarchy Plugin Manager

```bash
omarchy plugin remove lid-sleep
```

### Manual Removal

```bash
rm -rf ~/.config/omarchy/plugins/lid-sleep
omarchy restart shell
```

## Usage & IPC

- **Bar Interaction:** Left-click the bar icon to toggle lid sleep on or off.
- **CLI / Keybinding:** Control the plugin via shell IPC:
  ```bash
  omarchy-shell lid-sleep toggle
  omarchy-shell lid-sleep status
  omarchy-shell lid-sleep enable
  omarchy-shell lid-sleep disable
  ```

## Configuration

Move the widget to a different bar section using the Omarchy CLI or by dragging the icon:

```bash
omarchy bar move lid-sleep --section center
```

## Optional Keybinding

To toggle Lid Sleep with a global keyboard shortcut in Omarchy:

### Adding a Keybinding

Add the following line to `~/.config/hypr/bindings.lua` (for example, using `SUPER + SHIFT + Z`):

```lua
-- Toggle Lid Sleep
o.bind("SUPER + SHIFT + Z", "Toggle Lid Sleep", "omarchy-shell lid-sleep toggle")
```

Changes apply immediately upon saving the file (or reload manually with `hyprctl reload`).

### Removing the Keybinding

To remove the shortcut, delete the line from `~/.config/hypr/bindings.lua`, or explicitly unbind it:

```lua
hl.unbind("SUPER + SHIFT + Z")
```

## How It Works

- **Toggle Sleep:** Uses standard `systemd-inhibit` to pause lid-close sleep when enabled, and releases the lock when disabled.
- **Purely In-Memory:** Runs completely in memory without modifying any system settings or configuration files.
- **Automatic Cleanup:** When the plugin is disabled or uninstalled, sleep inhibition is stopped automatically.
- **Screen Lock Preserved:** Screen locking on lid close remains active for security.

## Dependencies

- `systemd-inhibit` (standard component of `systemd`)

## License

MIT
