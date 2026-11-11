import QtQuick
import Quickshell
import Quickshell.Wayland

Item {
  id: root

  property var shell: null
  readonly property int offAfterSeconds: 10
  readonly property string device: "kbd_backlight"

  function brightnessctl(args) {
    Quickshell.execDetached(["brightnessctl", "-q", "-d", root.device].concat(args))
  }

  // Undo an "off" left behind if the shell restarted while idle.
  Component.onCompleted: brightnessctl(["-r"])

  IdleMonitor {
    timeout: root.offAfterSeconds
    // Video players inhibit idle; the keyboard light should still go off while watching.
    respectInhibitors: false
    // -s/-r save and restore the level, so brightness-key changes are kept.
    onIsIdleChanged: root.brightnessctl(isIdle ? ["-s", "set", "0"] : ["-r"])
  }
}
