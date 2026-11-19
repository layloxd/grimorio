// Tablero: lienzo infinito de referencias y moodboard (modo PureRef).
//
// Permite arrastrar imágenes, organizarlas libremente, escalarlas, rotarlas,
// auto-empaquetarlas en mosaico (Ctrl+P), dejarlas flotando siempre encima
// de otros programas de dibujo o escultura 3D, y activar el modo fantasma (Ctrl+T).
import QtQuick
import QtQuick.Window

Window {
    id: tablero
    title: qsTr("Tablero de Referencias")
    width: 1200
    height: 800
    minimumWidth: 400
    minimumHeight: 300
    color: tema.fondo
    visible: false

    property bool siempreEncima: false
    property bool sinBordes: false
    property bool modoFantasma: false
    property real opacidadVentana: 1.0

    flags: Qt.Window
           | (siempreEncima ? Qt.WindowStaysOnTopHint : 0)
           | (sinBordes ? Qt.FramelessWindowHint : 0)
           | (modoFantasma ? Qt.WindowTransparentForInput : 0)

    opacity: opacidadVentana

    property real mundoX: width / 2
    property real mundoY: height / 2
    property real mundoZoom: 1.0
    property int indiceSeleccionado: -1
    readonly property int totalElementos: modeloElementos.count

    // Modelo de datos para las imágenes colocadas en el lienzo
    ListModel {
        id: modeloElementos
    }

    // ------------------------------------------------------------- Navegación
    // Zoom enfocado en el cursor del ratón (igual que PureRef)
    function zoomAlPunto(factor, px, py) {
        const viejoZoom = mundoZoom
        const nuevoZoom = Math.max(0.02, Math.min(30.0, viejoZoom * factor))
        if (Math.abs(nuevoZoom - viejoZoom) < 0.0001) return
        const k = nuevoZoom / viejoZoom
        mundoX = px - (px - mundoX) * k
        mundoY = py - (py - mundoY) * k
        mundoZoom = nuevoZoom
    }

    // Ajustar todos los elementos en el campo visual
    function centrarTodo() {
        if (modeloElementos.count === 0) {
            mundoX = width / 2
            mundoY = height / 2
            mundoZoom = 1.0
            return
        }

        let minX = 999999, minY = 999999
        let maxX = -999999, maxY = -999999

        for (let i = 0; i < modeloElementos.count; i++) {
            const item = modeloElementos.get(i)
            const w = Math.max(32, item.ancho * item.escala)
            const h = Math.max(32, item.alto * item.escala)
            minX = Math.min(minX, item.posX)
            minY = Math.min(minY, item.posY)
            maxX = Math.max(maxX, item.posX + w)
            maxY = Math.max(maxY, item.posY + h)
        }

        const margen = 80
        const cajaW = Math.max(100, maxX - minX + margen * 2)
        const cajaH = Math.max(100, maxY - minY + margen * 2)

        const escalaW = width / cajaW
        const escalaH = height / cajaH
        mundoZoom = Math.max(0.05, Math.min(4.0, Math.min(escalaW, escalaH)))

        const centroCajaX = (minX + maxX) / 2
        const centroCajaY = (minY + maxY) / 2
        mundoX = width / 2 - centroCajaX * mundoZoom
        mundoY = height / 2 - centroCajaY * mundoZoom
    }

    // Enfocar un único elemento en el centro
    function enfocarElemento(idx) {
        if (idx < 0 || idx >= modeloElementos.count) return
        const item = modeloElementos.get(idx)
        const w = Math.max(32, item.ancho * item.escala)
        const h = Math.max(32, item.alto * item.escala)
        const centroX = item.posX + w / 2
        const centroY = item.posY + h / 2

        const factor = Math.min((width * 0.7) / w, (height * 0.7) / h)
        mundoZoom = Math.max(0.1, Math.min(5.0, factor))
        mundoX = width / 2 - centroX * mundoZoom
        mundoY = height / 2 - centroY * mundoZoom
        indiceSeleccionado = idx
    }

    // ----------------------------------------------------------- Auto-packing
    // Auto-empaquetado inteligente (PureRef Ctrl+P)
    function autoEmpaquetar() {
        const n = modeloElementos.count
        if (n === 0) return

        let items = []
        let areaTotal = 0
        const gap = 24

        for (let i = 0; i < n; i++) {
            const it = modeloElementos.get(i)
            const w = Math.max(32, it.ancho * it.escala)
            const h = Math.max(32, it.alto * it.escala)
            areaTotal += (w + gap) * (h + gap)
            items.push({ index: i, w: w, h: h })
        }

        // Ordenar por altura descendente para mejor empaquetado
        items.sort(function(a, b) { return b.h - a.h })

        // Relación de aspecto objetivo panorámica ~ 16:10
        const anchoObjetivo = Math.max(800, Math.sqrt(areaTotal * 1.6))

        let filaX = 0
        let filaY = 0
        let filaMaxH = 0
        let maxX = 0
        let maxY = 0

        for (let i = 0; i < items.length; i++) {
            const it = items[i]
            if (filaX + it.w > anchoObjetivo && filaX > 0) {
                filaX = 0
                filaY += filaMaxH + gap
                filaMaxH = 0
            }

            const modelItem = modeloElementos.get(it.index)
            modelItem.posX = filaX
            modelItem.posY = filaY

            filaX += it.w + gap
            filaMaxH = Math.max(filaMaxH, it.h)
            maxX = Math.max(maxX, filaX)
            maxY = Math.max(maxY, filaY + filaMaxH)
        }

        // Centrar todas las coordenadas respecto a (0, 0)
        const dx = maxX / 2
        const dy = maxY / 2
        for (let i = 0; i < n; i++) {
            const m = modeloElementos.get(i)
            m.posX -= dx
            m.posY -= dy
        }

        centrarTodo()
    }

    // ------------------------------------------------------------- Elementos
    function seleccionar(idx) {
        indiceSeleccionado = idx
    }

    function agregarElemento(idElem, ruta, nombre, px, py) {
        let posX = px !== undefined ? px : ((-mundoX + width / 2) / mundoZoom)
        let posY = py !== undefined ? py : ((-mundoY + height / 2) / mundoZoom)

        // Pequeño desplazamiento aleatorio para no apilar exactamente en el mismo pixel
        if (px === undefined) {
            posX += (modeloElementos.count % 5) * 40 - 80
            posY += (modeloElementos.count % 5) * 40 - 80
        }

        let fuente = ""
        if (idElem && idElem.length > 0) {
            fuente = "image://grim/previa/" + idElem
        } else if (ruta && ruta.length > 0) {
            fuente = nucleo.imagenDeRuta(ruta)
        }

        modeloElementos.append({
            idElemento: idElem || "",
            ruta: ruta || "",
            fuente: fuente,
            nombre: nombre || "",
            posX: posX,
            posY: posY,
            ancho: 400,
            alto: 300,
            escala: 1.0,
            giro: 0,
            orden: modeloElementos.count + 1,
            espejoH: false
        })

        indiceSeleccionado = modeloElementos.count - 1
    }

    function agregarVarios(lista) {
        if (!lista || lista.length === 0) return
        for (let i = 0; i < lista.length; i++) {
            const it = lista[i]
            agregarElemento(it.id, it.ruta, it.nombre)
        }
        autoEmpaquetar()
    }

    function vaciar() {
        modeloElementos.clear()
        indiceSeleccionado = -1
        centrarTodo()
    }

    function conmutarFantasma() {
        modoFantasma = !modoFantasma
    }

    // --------------------------------------------------------- Guardar/Cargar
    function guardarTablero() {
        const ruta = nucleo.elegirRutaGuardar(qsTr("Guardar Tablero"), qsTr("Tablero Grimorio (*.grimboard *.json)"))
        if (!ruta || ruta.length === 0) return

        let elems = []
        for (let i = 0; i < modeloElementos.count; i++) {
            const it = modeloElementos.get(i)
            elems.push({
                idElemento: it.idElemento,
                ruta: it.ruta,
                fuente: it.fuente,
                nombre: it.nombre,
                posX: it.posX,
                posY: it.posY,
                ancho: it.ancho,
                alto: it.alto,
                escala: it.escala,
                giro: it.giro,
                orden: it.orden,
                espejoH: it.espejoH
            })
        }

        const datos = {
            version: 1,
            camara: { x: mundoX, y: mundoY, zoom: mundoZoom },
            elementos: elems
        }

        nucleo.guardarTexto(ruta, JSON.stringify(datos, null, 2))
    }

    function abrirTablero() {
        const ruta = nucleo.elegirRutaAbrir(qsTr("Abrir Tablero"), qsTr("Tablero Grimorio (*.grimboard *.json)"))
        if (!ruta || ruta.length === 0) return

        const texto = nucleo.leerTexto(ruta)
        if (!texto || texto.length === 0) return

        try {
            const datos = JSON.parse(texto)
            modeloElementos.clear()
            if (datos.elementos && Array.isArray(datos.elementos)) {
                for (let i = 0; i < datos.elementos.length; i++) {
                    const it = datos.elementos[i]
                    modeloElementos.append({
                        idElemento: it.idElemento || "",
                        ruta: it.ruta || "",
                        fuente: it.fuente || "",
                        nombre: it.nombre || "",
                        posX: it.posX || 0,
                        posY: it.posY || 0,
                        ancho: it.ancho || 400,
                        alto: it.alto || 300,
                        escala: it.escala || 1.0,
                        giro: it.giro || 0,
                        orden: it.orden || i,
                        espejoH: !!it.espejoH
                    })
                }
            }
            if (datos.camara) {
                mundoX = datos.camara.x
                mundoY = datos.camara.y
                mundoZoom = datos.camara.zoom
            } else {
                centrarTodo()
            }
        } catch (e) {
            console.warn("Error al cargar tablero:", e)
        }
    }

    function exportarPng() {
        const ruta = nucleo.elegirRutaGuardar(qsTr("Exportar Lienzo"), qsTr("Imagen PNG (*.png)"))
        if (!ruta || ruta.length === 0) return

        mundo.grabToImage(function(resultado) {
            resultado.saveToFile(ruta)
        })
    }

    // ------------------------------------------------------------- Drop Area
    DropArea {
        id: zonaSoltar
        anchors.fill: parent

        onDropped: function(drop) {
            if (drop.hasUrls) {
                for (let i = 0; i < drop.urls.length; i++) {
                    const u = String(drop.urls[i])
                    const localPath = u.startsWith("file:///") ? decodeURIComponent(u.substring(8)) : u
                    const nombre = localPath.split("/").pop().split("\\").pop()
                    const wx = (drop.x - mundoX) / mundoZoom
                    const wy = (drop.y - mundoY) / mundoZoom
                    agregarElemento("", localPath, nombre, wx, wy)
                }
                drop.acceptProposedAction()
            }
        }
    }

    // ------------------------------------------------------- Lienzo Infinito
    MouseArea {
        id: zonaNavegacion
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        hoverEnabled: true

        property real ultimoX: 0
        property real ultimoY: 0
        property bool arrastrandoCamara: false

        onPressed: function(mouse) {
            if (mouse.button === Qt.RightButton || mouse.button === Qt.MiddleButton || (mouse.button === Qt.LeftButton && (mouse.modifiers & Qt.AltModifier))) {
                arrastrandoCamara = true
                ultimoX = mouse.x
                ultimoY = mouse.y
            } else if (mouse.button === Qt.LeftButton) {
                // Deseleccionar al hacer clic en el vacío
                tablero.indiceSeleccionado = -1
            }
        }

        onPositionChanged: function(mouse) {
            if (arrastrandoCamara) {
                const dx = mouse.x - ultimoX
                const dy = mouse.y - ultimoY
                tablero.mundoX += dx
                tablero.mundoY += dy
                ultimoX = mouse.x
                ultimoY = mouse.y
            }
        }

        onReleased: function(mouse) {
            arrastrandoCamara = false
        }

        onWheel: function(wheel) {
            const factor = wheel.angleDelta.y > 0 ? 1.15 : (1.0 / 1.15)
            tablero.zoomAlPunto(factor, wheel.x, wheel.y)
        }

        onDoubleClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                tablero.centrarTodo()
            }
        }
    }

    // El Mundo: contenedor escalado y desplazado
    Item {
        id: mundo
        x: tablero.mundoX
        y: tablero.mundoY
        scale: tablero.mundoZoom
        transformOrigin: Item.TopLeft

        Repeater {
            model: modeloElementos
            delegate: ElementoTablero {
                index: model.index
                model: model
            }
        }
    }

    // Barra de herramientas flotante
    BarraTablero {
        id: barraFlotante
        anchors.top: parent.top
        anchors.topMargin: tema.margen
        anchors.horizontalCenter: parent.horizontalCenter
        z: 9999
    }

    // Indicador sutil de Modo Fantasma (clic transparente activo)
    Rectangle {
        id: avisoFantasma
        visible: tablero.modoFantasma
        anchors.bottom: parent.bottom
        anchors.bottomMargin: tema.margen
        anchors.horizontalCenter: parent.horizontalCenter
        height: Math.round(tema.fuente * 2.2)
        width: textoFantasma.implicitWidth + tema.margen * 2
        color: tema.panel
        border.color: tema.marcador
        border.width: 1
        radius: tema.radio
        z: 10000

        Text {
            id: textoFantasma
            anchors.centerIn: parent
            text: qsTr("👻 Modo Fantasma activo — Clics pasan a través. Pulsa Ctrl+T para desactivar.")
            color: tema.marcador
            font.pixelSize: Math.round(tema.fuente * 0.85)
            font.bold: true
        }
    }

    // --------------------------------------------------- Atajos de teclado
    Shortcut {
        sequence: "Ctrl+P"
        onActivated: tablero.autoEmpaquetar()
    }

    Shortcut {
        sequence: "Ctrl+F"
        onActivated: tablero.centrarTodo()
    }

    Shortcut {
        sequence: "Ctrl+T"
        onActivated: tablero.conmutarFantasma()
    }

    Shortcut {
        sequence: "Ctrl+S"
        onActivated: tablero.guardarTablero()
    }

    Shortcut {
        sequence: "Ctrl+O"
        onActivated: tablero.abrirTablero()
    }

    Shortcut {
        sequence: "Ctrl+E"
        onActivated: tablero.exportarPng()
    }

    Shortcut {
        sequence: "Delete"
        enabled: tablero.indiceSeleccionado >= 0
        onActivated: {
            modeloElementos.remove(tablero.indiceSeleccionado)
            tablero.indiceSeleccionado = -1
        }
    }

    Shortcut {
        sequence: "Backspace"
        enabled: tablero.indiceSeleccionado >= 0
        onActivated: {
            modeloElementos.remove(tablero.indiceSeleccionado)
            tablero.indiceSeleccionado = -1
        }
    }

    Shortcut {
        sequence: "R"
        enabled: tablero.indiceSeleccionado >= 0
        onActivated: {
            const it = modeloElementos.get(tablero.indiceSeleccionado)
            it.giro = (it.giro + 90) % 360
        }
    }

    Shortcut {
        sequence: "Shift+R"
        enabled: tablero.indiceSeleccionado >= 0
        onActivated: {
            const it = modeloElementos.get(tablero.indiceSeleccionado)
            it.giro = (it.giro + 270) % 360
        }
    }

    Shortcut {
        sequence: "H"
        enabled: tablero.indiceSeleccionado >= 0
        onActivated: {
            const it = modeloElementos.get(tablero.indiceSeleccionado)
            it.espejoH = !it.espejoH
        }
    }

    Shortcut {
        sequence: "Escape"
        onActivated: {
            if (tablero.modoFantasma) {
                tablero.modoFantasma = false
            } else if (tablero.indiceSeleccionado >= 0) {
                tablero.indiceSeleccionado = -1
            } else {
                tablero.close()
            }
        }
    }
}
