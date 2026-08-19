import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "prevent-lid-sleep"

  property bool active: false
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
      root.active = (exitCode === 0)
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
    target: "prevent-lid-sleep"

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
    active: root.active
    dimmed: !root.active
    slotSize: Style.bar.statusSlot
    fontSize: Style.font.caption
    tooltipText: root.active ? "Prevent Lid Sleep: Active" : "Prevent Lid Sleep: Inactive"
    onPressed: function(b) {
      root.toggle()
    }
  }
}
