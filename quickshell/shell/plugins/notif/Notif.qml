import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// Campana de notificaciones para la barra. El demonio sigue siendo swaync
// (dueño de org.freedesktop.Notifications); esto solo muestra su estado y
// abre su panel. `swaync-client -swb` emite una línea JSON por cada cambio:
//   {"text":"3","alt":"notification"|"none"|"dnd-notification"|"dnd-none",...}
BarWidget {
  id: root
  moduleName: "mi.notif"

  property int count: 0
  property bool dnd: false

  readonly property string glyph: dnd ? "" : (count > 0 ? "" : "")

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function apply(line) {
    try {
      var s = JSON.parse(line)
      count = parseInt(s.text) || 0
      dnd = String(s.alt || "").indexOf("dnd") === 0
    } catch (e) {}
  }

  Process {
    id: watcher
    command: ["swaync-client", "-swb"]
    running: true
    stdout: SplitParser {
      onRead: function(line) { root.apply(line) }
    }
    // Si swaync se reinicia, el cliente termina: volver a suscribirse.
    onExited: restart.start()
  }

  Timer {
    id: restart
    interval: 2000
    onTriggered: watcher.running = true
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.glyph + (root.count > 0 && !root.dnd ? " " + root.count : "")
    active: root.count > 0 && !root.dnd
    dimmed: root.dnd
    tooltipText: root.dnd ? "No molestar activado"
      : (root.count > 0 ? root.count + " notificaciones" : "Sin notificaciones")
    onPressed: function(b) {
      if (b === Qt.RightButton) root.bar.run("swaync-client -d -sw")
      else root.bar.run("swaync-client -t -sw")
    }
  }
}
