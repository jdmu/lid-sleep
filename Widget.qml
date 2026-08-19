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
      root.bar.run(toggleScriptPath + " toggle")
    }
  }

  function cleanup() {
    if (root.sleepInhibited && root.bar) {
      root.bar.run(toggleScriptPath + " stop false")
    }
  }

  Component.onDestruction: root.cleanup()

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Process {
    id: statusProc
    command: [toggleScriptPath, "status"]
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
    function stop(): void {
      root.cleanup()
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
