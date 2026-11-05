import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "eoshell.active-window"


  readonly property var toplevel: ToplevelManager.activeToplevel
  readonly property string title: toplevel ? (toplevel.title || toplevel.appId || "") : ""
  readonly property int maxLabelWidth: Number(setting("maxWidth", 280))
  readonly property bool showIcon: setting("showIcon", true)
  readonly property bool showTitle: setting("showTitle", true)

  // Icono de la app enfocada: el appId se resuelve a su .desktop y de ahí al
  // tema de iconos; si no hay entrada se prueba el propio appId.
  readonly property string appId: toplevel ? (toplevel.appId || "") : ""
  readonly property string iconSource: {
    if (!showIcon || appId === "") return ""
    var entry = DesktopEntries.heuristicLookup(appId)
    var names = []
    if (entry && entry.icon) names.push(entry.icon)
    names.push(appId, appId.toLowerCase())
    for (var i = 0; i < names.length; i++) {
      var n = names[i]
      if (n.charAt(0) === "/") return "file://" + n
      var path = Quickshell.iconPath(n, true)
      if (path !== "") return path
    }
    return ""
  }
  readonly property real iconSize: Style.font.body + 6
  readonly property real iconSlot: iconSource !== "" ? iconSize + (showTitle ? Style.space(6) : 0) : 0
  readonly property real titleWidth: showTitle ? Math.min(maxLabelWidth, labelText.implicitWidth) : 0

  visible: title !== "" && !vertical
  implicitWidth: visible ? iconSlot + titleWidth + Style.spacing.controlPaddingX * 2 : 0
  implicitHeight: barSize

  Behavior on implicitWidth {
    NumberAnimation { duration: Style.duration(180); easing.type: Easing.OutCubic }
  }

  Item {
    anchors.fill: parent
    anchors.leftMargin: Style.space(8)
    anchors.rightMargin: Style.space(8)
    clip: true

    Image {
      id: appIcon
      visible: root.iconSource !== ""
      source: root.iconSource
      width: root.iconSize
      height: root.iconSize
      sourceSize: Qt.size(root.iconSize * 2, root.iconSize * 2)
      fillMode: Image.PreserveAspectFit
      smooth: true
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left
    }

    Text {
      id: labelText
      visible: root.showTitle
      textFormat: Text.PlainText
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left
      anchors.leftMargin: root.iconSlot
      width: parent.width - root.iconSlot
      text: root.title
      color: root.bar ? root.bar.barForeground : Commons.Color.foreground
      font.family: root.bar ? root.bar.fontFamily : Style.font.family
      font.pixelSize: Style.font.body
      elide: Text.ElideRight
      opacity: 0.85
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor

    onClicked: function(mouse) {
      if (!root.toplevel) return
      if (mouse.button === Qt.MiddleButton) {
        root.toplevel.close()
      } else if (mouse.button === Qt.RightButton) {
        root.toplevel.close()
      } else {
        root.toplevel.activate()
      }
    }
    onEntered: if (root.bar) root.bar.showTooltip(root, root.title)
    onExited: if (root.bar) root.bar.hideTooltip(root)
  }
}
