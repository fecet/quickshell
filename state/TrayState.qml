pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io // IpcHandler
Singleton {
  id: root

  // Visibility gate for embedded tray in the bar
  property bool visible: true

  IpcHandler {
    target: "tray"

    function setVisible(v: int): void { root.visible = !!v; }
    function toggleVisible(): void { root.visible = !root.visible; }
    function getVisible(): bool { return root.visible; }
  }
}

