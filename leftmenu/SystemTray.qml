import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import Qt5Compat.GraphicalEffects
import "../config" as C

WrapperRectangle {
  id: root
  // flatten style when embedded in bar
  property bool embedded: false
  // external visibility gate
  property bool show: true
  resizeChild: false
  color: embedded ? "transparent" : C.Config.applySecondaryOpacity(C.Config.theme.surface_container)
  margin: embedded ? 0 : 5
  radius: embedded ? 0 : 5
  opacity: (SystemTray.items && SystemTray.items.values.length > 0 && root.show) ? 1 : 0
  visible: opacity > 0
  Behavior on opacity {
    NumberAnimation {
      duration: C.Globals.anim_FAST
      easing.type: Easing.Linear
    }
  }

  // Add error handling for SystemTray initialization
  Component.onCompleted: {
    if (!SystemTray) {
      console.warn("SystemTray not available");
      root.visible = false;
    }
  }

  RowLayout {
    Repeater {
      model: SystemTray.items || null

      WrapperMouseArea {
        id: delegate
        required property SystemTrayItem modelData

        Item {
          implicitWidth: trayIcon.implicitWidth
          implicitHeight: trayIcon.implicitHeight

          IconImage {
            id: trayIcon
            source: delegate.modelData ? delegate.modelData.icon : ""
            implicitSize: 16
            visible: !C.Config.settings.tray.monochromeIcons

            // Add error handling for icon loading
            onStatusChanged: {
              if (status === Image.Error) {
                console.debug("SystemTray: Failed to load icon for", delegate.modelData ? delegate.modelData.id : "unknown item");
              }
            }
          }

          Loader {
            active: C.Config.settings.tray.monochromeIcons
            anchors.fill: trayIcon
            sourceComponent: Item {
              Desaturate {
                id: desaturatedIcon
                visible: false // There's already color overlay
                anchors.fill: parent
                source: trayIcon
                desaturation: 1 // 1.0 means fully grayscale
              }
              ColorOverlay {
                anchors.fill: desaturatedIcon
                source: desaturatedIcon
                color: C.Config.theme.on_surface
              }
            }
          }
        }

        acceptedButtons: Qt.RightButton | Qt.LeftButton

        onClicked: event => {
          if (!delegate.modelData) {
            event.accepted = true;
            return;
          }

          try {
            switch (event.button) {
            case Qt.LeftButton:
              if (delegate.modelData.activate) {
                delegate.modelData.activate();
              }
              break;
            case Qt.RightButton:
              if (delegate.modelData.hasMenu && menu) {
                menu.open();
              }
              break;
            }
          } catch (error) {
            console.warn("SystemTray click error:", error);
          }
          event.accepted = true;
        }

        QsMenuAnchor {
          id: menu
          menu: delegate.modelData.menu
          onVisibleChanged: QsWindow.window.inhibitGrab = visible

          anchor {
            item: trayIcon
            edges: Edges.Left | Edges.Bottom
            gravity: Edges.Right | Edges.Bottom
            adjustment: PopupAdjustment.FlipX
          }
        }
      }
    }
  }
}
