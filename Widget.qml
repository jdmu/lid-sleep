import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "lid-sleep"

  readonly property bool sleepInhibited: inhibitorProcess.running
  readonly property bool sleepActive: !sleepInhibited

  function toggle() {
    if (inhibitorProcess.running) {
      inhibitorProcess.running = false
      sendNotification("Lid Sleep Enabled", "System will sleep when lid is closed")
    } else {
      inhibitorProcess.running = true
      sendNotification("Lid Sleep Prevented", "System will stay awake when lid is closed")
    }
  }

  function sendNotification(title, message) {
    Quickshell.execDetached([
      "omarchy-notification-send",
      "-g", "\udb80\udf22",
      title,
      message
    ])
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  // Native Quickshell subprocess management.
  // Quickshell's C++ process lifecycle manager directly owns the child PID
  // and automatically terminates it when running = false or when the component unmounts.
  Process {
    id: inhibitorProcess
    running: false
    command: [
      "systemd-inhibit",
      "--what=handle-lid-switch",
      "--who=org.omarchy.plugins.lid-sleep",
      "--why=Prevent sleep on lid close",
      "sleep", "infinity"
    ]
  }

  IpcHandler {
    target: "lid-sleep"

    function toggle(): string {
      root.toggle()
      return root.sleepInhibited ? "inhibited" : "active"
    }

    function status(): string {
      return root.sleepInhibited ? "inhibited" : "active"
    }

    function enable(): string {
      if (root.sleepInhibited) root.toggle()
      return "active"
    }

    function disable(): string {
      if (!root.sleepInhibited) root.toggle()
      return "inhibited"
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "\udb80\udf22"
    active: root.sleepInhibited
    dimmed: root.sleepActive
    slotSize: Style.bar.statusSlot
    fontSize: Style.font.caption
    tooltipText: root.sleepActive ? "Prevent Lid Sleep" : "Enable Lid Sleep"
    onPressed: function(b) {
      root.toggle()
    }
  }
}
