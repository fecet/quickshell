import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import "../config" as C
import "../commonwidgets" as CW

RowLayout {
  id: root
  property real percentage: UPower.displayDevice.percentage
  // charging/discharging flags come from UPower state
  property bool charging: UPower.displayDevice.state === UPowerDeviceState.Charging
  property bool discharging: UPower.displayDevice.state === UPowerDeviceState.Discharging
  // current charge/discharge power in watts (UPower EnergyRate magnitude)
  property real changeRate: UPower.displayDevice.changeRate
  property color color: (!charging && percentage * 100 < C.Config.settings.bar.battery.low) ? C.Config.theme.error : C.Config.theme.on_background
  spacing: 0

  CW.FontIcon {
    Layout.alignment: Qt.AlignVCenter
    color: root.color
    iconSize: 15
    text: {
      const iconNumber = Math.round(root.percentage * 7);
      return root.charging ? "battery_android_bolt" : `battery_android_${iconNumber >= 7 ? "full" : iconNumber}`;
    }
  }

  CW.StyledText {
    Layout.alignment: Qt.AlignVCenter
    Layout.fillHeight: true
    Layout.leftMargin: 2
    text: `${Math.round(percentage * 100)}%`
    color: root.color
  }

  CW.StyledText {
    Layout.alignment: Qt.AlignVCenter
    Layout.leftMargin: 4
    // sign from state; magnitude from EnergyRate; hide when near zero or not charging/discharging
    visible: (root.charging || root.discharging) && Math.abs(root.changeRate) >= 0.05
    text: `${root.charging ? "+" : (root.discharging ? "-" : "")} ${Math.abs(root.changeRate).toFixed(1)}W`
    // turn red when discharging power magnitude exceeds 25W
    color: (root.discharging && Math.abs(root.changeRate) > 25) ? C.Config.theme.error : root.color
  }
}
