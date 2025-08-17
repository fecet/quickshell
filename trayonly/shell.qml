//@ pragma UseQApplication
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.SystemTray

// Minimal tray-only window
PanelWindow {
  id: win
  color: "transparent"

  // Anchor to top-right corner without stretching
  anchors {
    top: true
    right: true
  }

  // Layer shell placement
  WlrLayershell.namespace: "hyprland-shell:trayonly"
  WlrLayershell.layer: WlrLayer.Overlay

  // Size to content (the SystemTray block)
  implicitWidth: bg.implicitWidth
  implicitHeight: bg.implicitHeight

  // Simple background for clickability
  Rectangle {
    id: bg
    radius: 6
    color: "#33000000" // semi-transparent background
    border.color: "#33000000"
    border.width: 0

    // Size to row content with padding
    implicitWidth: row.implicitWidth + 8
    implicitHeight: row.implicitHeight + 8

    RowLayout {
      id: row
      anchors.centerIn: parent
      spacing: 6

      Repeater {
        model: SystemTray.items

        Item {
          required property SystemTrayItem modelData // from Quickshell.Services.SystemTray

          implicitWidth: icon.implicitWidth
          implicitHeight: icon.implicitHeight

          IconImage {
            id: icon
            source: modelData.icon
            implicitSize: 16
          }

          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: (mouse) => {
              if (mouse.button === Qt.LeftButton) {
                modelData.activate();
              } else if (mouse.button === Qt.RightButton && modelData.hasMenu) {
                menu.open();
              }
              mouse.accepted = true;
            }
          }

          QsMenuAnchor {
            id: menu
            menu: modelData.menu
            anchor.item: icon
          }
        }
      }
    }
  }
}
