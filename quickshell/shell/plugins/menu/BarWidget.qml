import QtQuick
import qs.Ui

BarWidget {
  id: root
  moduleName: "eoshell.menu"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "\ue900"
    fontFamily: "eoshell"
    onPressed: function(button) {
      if (!root.bar) return
      if (button === Qt.RightButton) root.bar.run("xdg-terminal-exec")
      else root.bar.run("eoshell-shell shell toggle eoshell.menu '{\"menu\":\"root\"}'")
    }
  }
}
