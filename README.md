# Lid Sleep

An [Omarchy](https://omarchy.org) bar widget plugin that toggles whether your laptop goes to sleep when the lid is closed.

## States

- **`Lid Sleep: Active` (Normal):** Lid sleep is active. Closing your laptop lid will put the machine to sleep normally. (Widget icon is quiet/dimmed).
- **`Lid Sleep: Inactive` (Stay Awake):** Lid sleep is inactive. An inhibitor lock keeps the machine awake and running when the lid is closed while still locking the screen. (Widget icon is highlighted/active).

## Features

- **Action-Based Status:** Clear tooltips referencing the actual action: `"Lid Sleep: Active"` (normal) vs `"Lid Sleep: Inactive"` (stay awake).
- **One-Click Toggle:** Click the top bar icon (`󰌢`) to toggle lid sleep on or off.
- **Visual Feedback:** Highlights when lid sleep is inactive (stay-awake mode) to alert you that sleep is disabled.
- **Desktop Notifications:** Displays quick on-screen alerts when toggling.
- **Self-Contained:** Zero external configuration or root/sudo required.

## Installation

### Via Omarchy Plugin Manager

```bash
omarchy plugin add https://github.com/jdmu/lid-sleep.git --enable
```

### Manual Installation

Clone or copy this directory into your Omarchy plugins directory:

```bash
mkdir -p ~/.config/omarchy/plugins/
cp -r lid-sleep ~/.config/omarchy/plugins/
omarchy-shell shell rescanPlugins
omarchy-shell shell enablePlugin lid-sleep '{}'
```

## How It Works

- When toggled to **Inactive**, it spawns `systemd-inhibit --what=handle-lid-switch` in the background.
- When toggled back to **Active**, it terminates the inhibitor process, restoring standard suspend behavior.
- Screen locking on lid close is preserved by Omarchy's window manager bindings.

## License

MIT
