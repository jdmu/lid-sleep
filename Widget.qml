import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "lid-sleep"

  // sleepActive is true when lid sleep is active (normal behavior).
  // sleepActive is false when lid sleep is inactive (inhibitor running, stay awake).
  property bool sleepActive: true
  readonly property bool sleepInhibited: !sleepActive
  readonly property string toggleScriptPath: Qt.resolvedUrl("toggle.sh").toString().replace(/^file:\/\//, "")

  function refresh() {
    if (!statusProc.running) statusProc.running = true
  }

  function toggle() {
    if (root.bar) {
      root.bar.run(toggleScriptPath)
    }
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Process {
    id: statusProc
    command: ["pgrep", "-f", "systemd-inhibit --what=handle-lid-switch"]
    onExited: function(exitCode) {
      // If inhibitor is running (exit code 0), sleep is inactive (inhibited).
      // Otherwise, sleep is active (normal).
      root.sleepActive = (exitCode !== 0)
    }
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  IpcHandler {
    target: "lid-sleep"

    function toggle(): void {
      root.toggle()
    }
    function refresh(): void {
      root.refresh()
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰌢"
    active: root.sleepInhibited
    dimmed: root.sleepActive
    slotSize: Style.bar.statusSlot
    fontSize: Style.font.caption
    tooltipText: root.sleepActive ? "Lid Sleep: Active" : "Lid Sleep: Inactive"
    onPressed: function(b) {
      root.toggle()
    }
  }
}
