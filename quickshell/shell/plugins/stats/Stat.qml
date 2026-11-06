import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// Indicador de sistema para la barra. Un mismo widget sirve para varios
// indicadores; cual se muestra lo decide `kind` en la entrada de shell.json:
//   { "id": "mi.stat", "kind": "cpu" }
// Cada instancia consulta lo suyo con un proceso corto cada `interval` segundos.
BarWidget {
  id: root
  moduleName: "mi.stat"

  readonly property string kind: String(setting("kind", "cpu"))

  readonly property var defaults: ({
    cpu:      { interval: 3,  click: "kitty -e btop" },
    memory:   { interval: 3,  click: "kitty -e btop" },
    temp:     { interval: 5,  click: "kitty -e btop" },
    disk:     { interval: 60, click: "" },
    docker:   { interval: 5,  click: "kitty -e docker-open", rightClick: "kitty -e docker-open stop" },
    netspeed: { interval: 2,  click: "" }
  })
  readonly property var meta: defaults[kind] || defaults.cpu
  readonly property int interval: Math.max(1, Number(setting("interval", meta.interval)))
  readonly property string clickCommand: String(setting("click", meta.click))
  readonly property string rightClickCommand: String(setting("rightClick", meta.rightClick || ""))

  // Texto, tooltip y estado crítico que se calculan con cada lectura.
  property string label: "…"
  property string tip: ""
  property bool critical: false

  // Estado de la lectura anterior, para las medidas que son una diferencia
  // entre dos instantes (cpu y red).
  property var prev: null

  readonly property var scripts: ({
    cpu:      "head -n1 /proc/stat",
    memory:   "awk '/^MemTotal/{t=$2}/^MemAvailable/{a=$2}/^SwapTotal/{st=$2}/^SwapFree/{sf=$2}END{print t,a,st,sf}' /proc/meminfo",
    temp:     "cat /sys/class/thermal/thermal_zone" + Number(setting("zone", 9)) + "/temp",
    disk:     "df -B1 --output=used,size,pcent / | tail -n1",
    docker:   "systemctl is-active docker",
    netspeed: "cat /proc/net/dev"
  })

  function fmtBytes(b) {
    var u = ["B", "K", "M", "G"]
    var i = 0
    while (b >= 1024 && i < u.length - 1) { b /= 1024; i++ }
    return (i === 0 ? Math.round(b) : b.toFixed(1)) + u[i] + "/s"
  }

  function gib(kib) { return kib / 1048576 }

  function apply(out) {
    var t = String(out).trim()
    var now = Date.now()
    if (kind === "cpu") {
      var f = t.split(/\s+/).slice(1).map(Number)
      var idle = f[3] + (f[4] || 0)
      var total = f.reduce(function(a, b) { return a + b }, 0)
      if (prev && total > prev.total) {
        var pct = Math.round(100 * (1 - (idle - prev.idle) / (total - prev.total)))
        label = "󰻠 " + pct + "%"
        critical = pct >= 90
        tip = "CPU: " + pct + "%"
      }
      prev = { idle: idle, total: total }
    } else if (kind === "memory") {
      var m = t.split(/\s+/).map(Number)
      var used = gib(m[0] - m[1])
      var pctm = 100 * (m[0] - m[1]) / m[0]
      label = "󰍛 " + used.toFixed(1) + "G/" + Math.round(gib(m[0])) + "G"
      critical = pctm >= 90
      tip = "RAM: " + used.toFixed(1) + " GiB de " + gib(m[0]).toFixed(1) + " GiB\n"
        + "Swap: " + gib(m[2] - m[3]).toFixed(1) + " GiB de " + gib(m[2]).toFixed(1) + " GiB"
    } else if (kind === "temp") {
      var c = Math.round(Number(t) / 1000)
      label = "\uf2c9 " + c + "°C"
      critical = c >= 85
      tip = "Temperatura: " + c + "°C"
    } else if (kind === "disk") {
      var d = t.split(/\s+/)
      label = "󰋊 " + parseInt(d[2]) + "%"
      critical = parseInt(d[2]) >= 90
      tip = "/: " + (Number(d[0]) / 1073741824).toFixed(1) + " GiB de " + (Number(d[1]) / 1073741824).toFixed(1) + " GiB"
    } else if (kind === "docker") {
      var on = t === "active"
      label = "󰡨 " + (on ? "on" : "off")
      critical = false
      dimmed = !on
      tip = "Docker: " + (on ? "activo" : "detenido")
    } else if (kind === "netspeed") {
      var rx = 0, tx = 0
      var lines = t.split("\n")
      for (var i = 0; i < lines.length; i++) {
        var p = lines[i].split(":")
        if (p.length < 2) continue
        var name = p[0].trim()
        if (name === "lo" || name === "") continue
        var v = p[1].trim().split(/\s+/).map(Number)
        rx += v[0]; tx += v[8]
      }
      if (prev && now > prev.at) {
        var s = (now - prev.at) / 1000
        var down = Math.max(0, (rx - prev.rx) / s)
        var up = Math.max(0, (tx - prev.tx) / s)
        label = "󰇚 " + fmtBytes(down) + "  󰕒 " + fmtBytes(up)
        tip = ""
      }
      prev = { rx: rx, tx: tx, at: now }
    }
  }

  property bool dimmed: false

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Process {
    id: probe
    command: ["sh", "-c", root.scripts[root.kind] || "true"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.apply(text)
    }
  }

  Timer {
    interval: root.interval * 1000
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: if (!probe.running) probe.running = true
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.label
    active: root.critical
    dimmed: root.dimmed
    tooltipText: root.tip
    interactive: root.clickCommand !== ""
    onPressed: function(b) {
      if (b === Qt.LeftButton && root.clickCommand !== "") root.bar.run(root.clickCommand)
      else if (b === Qt.RightButton && root.rightClickCommand !== "") root.bar.run(root.rightClickCommand)
    }
  }
}
