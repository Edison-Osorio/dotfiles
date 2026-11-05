import QtQuick
import qs.Commons
import qs.Ui

// Campana de notificaciones para la barra, conectada al demonio del propio
// shell (plugin eoshell.notifications), que es dueño de org.freedesktop.Notifications.
//
//   clic izquierdo  reabre las últimas notificaciones (historial) y marca todo como visto
//   clic medio      descarta las tarjetas que hay en pantalla
//   clic derecho    activa/desactiva No molestar
//
// El contador son las tarjetas en pantalla más las que se cerraron sin que las
// miraras: lo posterior al arranque del shell o a tu último clic en la campana.
BarWidget {
  id: root
  moduleName: "mi.notif"

  readonly property var service: bar?.shell?.firstPartyServiceFor("eoshell.notifications")
  readonly property bool dnd: service ? !!service.doNotDisturb : false

  // Segundos desde epoch; las filas del historial traen `closed_ts` en la misma unidad.
  property real seenAt: Date.now() / 1000

  readonly property int live: service && service.liveEntries ? service.liveEntries.length : 0
  readonly property int unseen: {
    if (!service || !service.historyEntries) return 0
    var n = 0
    var rows = service.historyEntries
    for (var i = 0; i < rows.length; i++)
      if (Number(rows[i].closed_ts) > seenAt) n++
    return n
  }
  readonly property int count: live + unseen

  readonly property string glyph: dnd ? "" : (count > 0 ? "" : "")

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.glyph + (root.count > 0 && !root.dnd ? " " + root.count : "")
    active: root.count > 0 && !root.dnd
    dimmed: root.dnd
    tooltipText: root.dnd ? "No molestar activado (clic derecho para desactivar)"
      : (root.count > 0 ? root.count + " sin ver · clic: abrir · medio: descartar" : "Sin notificaciones nuevas")
    onPressed: function(b) {
      if (!root.service) return
      if (b === Qt.RightButton) {
        root.service.setDoNotDisturb(!root.service.doNotDisturb)
      } else if (b === Qt.MiddleButton) {
        root.service.clearAll("dismissed", false)
      } else {
        root.seenAt = Date.now() / 1000
        root.service.replayHistory()
      }
    }
  }
}
