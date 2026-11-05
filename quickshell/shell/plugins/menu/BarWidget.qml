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
    // Logo de Fedora (nf-linux-fedora) de la Nerd Font instalada.
    text: root.setting("icon", "\uf30a")
    fontFamily: "JetBrainsMono Nerd Font"
    onPressed: function(button) {
      if (!root.bar) return
      if (button === Qt.RightButton) root.bar.run("kitty")
      else root.bar.run("eoshell-shell shell toggle eoshell.menu '{\"menu\":\"root\"}'")
    }
  }
}
