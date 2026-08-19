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

## How It Works

- **Native Subprocess Lifecycle:** Uses Quickshell's native `Process` engine to manage `systemd-inhibit` directly as a managed child process.
- **Zero PID Files:** Operates completely in-memory with zero disk writes, state files, or `/proc` polling.
- **Guaranteed Cleanup:** When the plugin is unloaded, disabled, or removed, Quickshell automatically terminates the child process.
- **IPC Control:** Supports direct shell IPC via `omarchy-shell lid-sleep toggle`, `enable`, `disable`, and `status`.
- Screen locking on lid close is preserved by Omarchy's window manager bindings.

## License

MIT
