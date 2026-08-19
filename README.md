# Lid Sleep

An [Omarchy](https://omarchy.org) bar widget plugin that toggles whether your laptop goes to sleep when the lid is closed.

When enabled (Active), it takes a low-level `systemd-inhibit` lock on the lid switch so your system continues running while the screen locks normally.

## Features

- **One-Click Toggle:** Click the top bar icon (`󰌢`) to toggle lid sleep inhibition on or off.
- **Visual Feedback:** Highlights when active and dims when inactive.
- **Short Tooltips:** `"Lid Sleep: Active"` and `"Lid Sleep: Inactive"`.
- **Desktop Notifications:** Displays quick on-screen alerts when toggling.
- **Self-Contained:** Zero dependencies outside standard `systemd` and `bash`. No root or sudo required.

## Installation

### Via Omarchy Plugin Manager

```bash
omarchy plugin add https://github.com/<your-username>/lid-sleep.git --enable
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

- When activated, it spawns `systemd-inhibit --what=handle-lid-switch` in the background.
- When deactivated, it terminates the inhibitor process, restoring standard lid suspend behavior.
- Screen locking on lid close is preserved by Omarchy's window manager bindings.

## License

MIT
