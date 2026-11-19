// Un elemento dentro del lienzo infinito de referencias (modo PureRef).
//
// Puede moverse con suavidad, redimensionarse desde cualquiera de sus 4 esquinas
// o 4 bordes (sin parpadeos ni tirones), rotarse y voltearse.
import QtQuick

Item {
    id: elemento
    required property int index
    required property string idElemento
    required property string ruta
    required property string fuente
    required property string nombre
    required property real posX
    required property real posY
    required property real ancho
    required property real alto
    required property real escala
    required property real giro
    required property int orden
    required property bool espejoH

    x: posX
    y: posY
    width: Math.max(32, ancho * escala)
    height: Math.max(32, alto * escala)
    rotation: giro
    z: orden

    readonly property bool seleccionado: tablero.indiceSeleccionado === index

    // ------------------------------------------------ Contenedor de imagen
    Item {
        id: contenedor
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color: tema.panel
            opacity: 0.3
            radius: tema.radio
        }

        Image {
            id: imagen
            anchors.fill: parent
            source: elemento.fuente
            fillMode: Image.PreserveAspectFit
            mirror: elemento.espejoH
            asynchronous: true
            smooth: true
            mipmap: true

            onStatusChanged: {
                if (status === Image.Error) {
                    if (elemento.idElemento && elemento.idElemento.length > 0) {
                        const previaUrl = "image://grim/previa/" + elemento.idElemento
                        const thumbUrl = "image://grim/" + elemento.idElemento
                        if (source !== previaUrl && source !== thumbUrl) {
                            source = previaUrl
                        } else if (source === previaUrl) {
                            source = thumbUrl
                        }
                    } else if (elemento.ruta && elemento.ruta.length > 0) {
                        const archivoUrl = nucleo.imagenDeRuta(elemento.ruta)
                        if (source !== archivoUrl) {
                            source = archivoUrl
                        }
                    }
                }
                if (status === Image.Ready) {
                    let w = implicitWidth > 0 ? implicitWidth : 400
                    let h = implicitHeight > 0 ? implicitHeight : 300
                    if (w > 800 || h > 800) {
                        const factor = Math.min(800 / w, 800 / h)
                        w = Math.round(w * factor)
                        h = Math.round(h * factor)
                    }
                    if (elemento.ancho !== w || elemento.alto !== h) {
                        modeloElementos.setProperty(elemento.index, "ancho", w)
                        modeloElementos.setProperty(elemento.index, "alto", h)
                    }
                }
            }
        }

        // Si falló cargar o es un archivo no gráfico
        Column {
            anchors.centerIn: parent
            spacing: Math.round(tema.hueco * 0.4)
            visible: imagen.status === Image.Error
            width: Math.max(30, parent.width - 20)

            Icono {
                anchors.horizontalCenter: parent.horizontalCenter
                nombre: "documento"
                color: tema.textoTenue
                width: Math.round(tema.fuente * 2.2)
                height: width
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                text: elemento.nombre
                color: tema.textoTenue
                font.pixelSize: Math.round(tema.fuente * 0.75)
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideMiddle
            }
        }

        // Borde de selección
        Rectangle {
            anchors.fill: parent
            visible: elemento.seleccionado
            color: "transparent"
            border.color: tema.seleccion
            border.width: Math.max(1, Math.round(2 / tablero.mundoZoom))
        }
    }

    // ---------------------------------------- Mover el elemento sin tirones
    property real arrastreGlobalX: 0
    property real arrastreGlobalY: 0
    property real arrastreElemOrigX: 0
    property real arrastreElemOrigY: 0

    MouseArea {
        id: zonaMover
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        // Si el usuario mantiene pulsado espacio (modo mano), deja pasar el evento al lienzo
        enabled: !tablero.modoMano

        onPressed: function(mouse) {
            tablero.seleccionar(elemento.index)
            if (mouse.button === Qt.LeftButton) {
                const g = mapToItem(null, mouse.x, mouse.y)
                elemento.arrastreGlobalX = g.x
                elemento.arrastreGlobalY = g.y
                elemento.arrastreElemOrigX = elemento.posX
                elemento.arrastreElemOrigY = elemento.posY
            }
        }

        onPositionChanged: function(mouse) {
            if (pressed && (mouse.buttons & Qt.LeftButton)) {
                const g = mapToItem(null, mouse.x, mouse.y)
                const dx = (g.x - elemento.arrastreGlobalX) / tablero.mundoZoom
                const dy = (g.y - elemento.arrastreGlobalY) / tablero.mundoZoom
                modeloElementos.setProperty(elemento.index, "posX", elemento.arrastreElemOrigX + dx)
                modeloElementos.setProperty(elemento.index, "posY", elemento.arrastreElemOrigY + dy)
            }
        }

        onDoubleClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                tablero.enfocarElemento(elemento.index)
            }
        }
    }

    // ------------------------------------ Escala en las 4 esquinas y bordes
    property real escInicioGX: 0
    property real escInicioGY: 0
    property real escInicioPX: 0
    property real escInicioPY: 0
    property real escInicioW: 0
    property real escInicioH: 0
    property real escAspect: 1
    property real escBaseAncho: 1

    function iniciarEscala(ma, mouse) {
        const g = ma.mapToItem(null, mouse.x, mouse.y)
        escInicioGX = g.x
        escInicioGY = g.y
        escInicioPX = elemento.posX
        escInicioPY = elemento.posY
        escInicioW = elemento.ancho * elemento.escala
        escInicioH = elemento.alto * elemento.escala
        escAspect = (escInicioH > 0) ? (escInicioW / escInicioH) : 1.333
        escBaseAncho = Math.max(1, elemento.ancho)
    }

    function procesarEscala(modo, ma, mouse) {
        const g = ma.mapToItem(null, mouse.x, mouse.y)
        const dx = (g.x - escInicioGX) / tablero.mundoZoom
        const dy = (g.y - escInicioGY) / tablero.mundoZoom

        let deltaW = 0
        if (modo === "BR") {
            deltaW = Math.abs(dx) > Math.abs(dy) ? dx : (dy * escAspect)
        } else if (modo === "BL") {
            deltaW = Math.abs(dx) > Math.abs(dy) ? -dx : (dy * escAspect)
        } else if (modo === "TR") {
            deltaW = Math.abs(dx) > Math.abs(dy) ? dx : (-dy * escAspect)
        } else if (modo === "TL") {
            deltaW = Math.abs(dx) > Math.abs(dy) ? -dx : (-dy * escAspect)
        } else if (modo === "R") {
            deltaW = dx
        } else if (modo === "L") {
            deltaW = -dx
        } else if (modo === "B") {
            deltaW = dy * escAspect
        } else if (modo === "T") {
            deltaW = -dy * escAspect
        }

        const W_nueva = Math.max(48, escInicioW + deltaW)
        const H_nueva = W_nueva / escAspect
        const nuevaEscala = Math.max(0.05, Math.min(25.0, W_nueva / escBaseAncho))

        if (modo === "BL" || modo === "TL" || modo === "L") {
            modeloElementos.setProperty(elemento.index, "posX", escInicioPX + (escInicioW - W_nueva))
        }
        if (modo === "TR" || modo === "TL" || modo === "T") {
            modeloElementos.setProperty(elemento.index, "posY", escInicioPY + (escInicioH - H_nueva))
        }
        modeloElementos.setProperty(elemento.index, "escala", nuevaEscala)
    }

    readonly property real tamAsa: Math.max(8, Math.round(13 / tablero.mundoZoom))

    // Asa Esquina Inferior Derecha (BR)
    Rectangle {
        visible: elemento.seleccionado && !tablero.modoMano
        width: elemento.tamAsa; height: width; radius: width / 2
        anchors.right: parent.right; anchors.bottom: parent.bottom
        anchors.rightMargin: -width / 2; anchors.bottomMargin: -height / 2
        color: tema.seleccion; border.color: tema.panel
        border.width: Math.max(1, Math.round(1 / tablero.mundoZoom)); z: 20

        MouseArea {
            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.SizeFDiagCursor; preventStealing: true
            onPressed: function(m) { elemento.iniciarEscala(this, m) }
            onPositionChanged: function(m) { if (pressed) elemento.procesarEscala("BR", this, m) }
        }
    }

    // Asa Esquina Inferior Izquierda (BL)
    Rectangle {
        visible: elemento.seleccionado && !tablero.modoMano
        width: elemento.tamAsa; height: width; radius: width / 2
        anchors.left: parent.left; anchors.bottom: parent.bottom
        anchors.leftMargin: -width / 2; anchors.bottomMargin: -height / 2
        color: tema.seleccion; border.color: tema.panel
        border.width: Math.max(1, Math.round(1 / tablero.mundoZoom)); z: 20

        MouseArea {
            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.SizeBDiagCursor; preventStealing: true
            onPressed: function(m) { elemento.iniciarEscala(this, m) }
            onPositionChanged: function(m) { if (pressed) elemento.procesarEscala("BL", this, m) }
        }
    }

    // Asa Esquina Superior Derecha (TR)
    Rectangle {
        visible: elemento.seleccionado && !tablero.modoMano
        width: elemento.tamAsa; height: width; radius: width / 2
        anchors.right: parent.right; anchors.top: parent.top
        anchors.rightMargin: -width / 2; anchors.topMargin: -height / 2
        color: tema.seleccion; border.color: tema.panel
        border.width: Math.max(1, Math.round(1 / tablero.mundoZoom)); z: 20

        MouseArea {
            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.SizeBDiagCursor; preventStealing: true
            onPressed: function(m) { elemento.iniciarEscala(this, m) }
            onPositionChanged: function(m) { if (pressed) elemento.procesarEscala("TR", this, m) }
        }
    }

    // Asa Esquina Superior Izquierda (TL)
    Rectangle {
        visible: elemento.seleccionado && !tablero.modoMano
        width: elemento.tamAsa; height: width; radius: width / 2
        anchors.left: parent.left; anchors.top: parent.top
        anchors.leftMargin: -width / 2; anchors.topMargin: -height / 2
        color: tema.seleccion; border.color: tema.panel
        border.width: Math.max(1, Math.round(1 / tablero.mundoZoom)); z: 20

        MouseArea {
            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.SizeFDiagCursor; preventStealing: true
            onPressed: function(m) { elemento.iniciarEscala(this, m) }
            onPositionChanged: function(m) { if (pressed) elemento.procesarEscala("TL", this, m) }
        }
    }

    // Asa Borde Derecho (R)
    Rectangle {
        visible: elemento.seleccionado && !tablero.modoMano
        width: Math.max(6, Math.round(8 / tablero.mundoZoom)); height: Math.max(16, Math.round(24 / tablero.mundoZoom))
        radius: width / 2
        anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: -width / 2
        color: tema.seleccion; border.color: tema.panel
        border.width: 1; z: 20

        MouseArea {
            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.SizeHorCursor; preventStealing: true
            onPressed: function(m) { elemento.iniciarEscala(this, m) }
            onPositionChanged: function(m) { if (pressed) elemento.procesarEscala("R", this, m) }
        }
    }

    // Asa Borde Izquierdo (L)
    Rectangle {
        visible: elemento.seleccionado && !tablero.modoMano
        width: Math.max(6, Math.round(8 / tablero.mundoZoom)); height: Math.max(16, Math.round(24 / tablero.mundoZoom))
        radius: width / 2
        anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: -width / 2
        color: tema.seleccion; border.color: tema.panel
        border.width: 1; z: 20

        MouseArea {
            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.SizeHorCursor; preventStealing: true
            onPressed: function(m) { elemento.iniciarEscala(this, m) }
            onPositionChanged: function(m) { if (pressed) elemento.procesarEscala("L", this, m) }
        }
    }

    // Asa Borde Inferior (B)
    Rectangle {
        visible: elemento.seleccionado && !tablero.modoMano
        height: Math.max(6, Math.round(8 / tablero.mundoZoom)); width: Math.max(16, Math.round(24 / tablero.mundoZoom))
        radius: height / 2
        anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: -height / 2
        color: tema.seleccion; border.color: tema.panel
        border.width: 1; z: 20

        MouseArea {
            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.SizeVerCursor; preventStealing: true
            onPressed: function(m) { elemento.iniciarEscala(this, m) }
            onPositionChanged: function(m) { if (pressed) elemento.procesarEscala("B", this, m) }
        }
    }

    // Asa Borde Superior (T)
    Rectangle {
        visible: elemento.seleccionado && !tablero.modoMano
        height: Math.max(6, Math.round(8 / tablero.mundoZoom)); width: Math.max(16, Math.round(24 / tablero.mundoZoom))
        radius: height / 2
        anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: -height / 2
        color: tema.seleccion; border.color: tema.panel
        border.width: 1; z: 20

        MouseArea {
            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.SizeVerCursor; preventStealing: true
            onPressed: function(m) { elemento.iniciarEscala(this, m) }
            onPositionChanged: function(m) { if (pressed) elemento.procesarEscala("T", this, m) }
        }
    }

    // ------------------------------------------------ Asa de rotación arriba
    Rectangle {
        id: asaGiro
        visible: elemento.seleccionado && !tablero.modoMano
        width: elemento.tamAsa; height: width; radius: width / 2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: -width * 1.8
        color: tema.marcador
        border.color: tema.panel
        border.width: Math.max(1, Math.round(1 / tablero.mundoZoom))
        z: 20

        Rectangle {
            width: Math.max(1, Math.round(1 / tablero.mundoZoom))
            height: asaGiro.width * 1.8
            color: tema.marcador
            anchors.top: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            preventStealing: true

            onClicked: {
                modeloElementos.setProperty(elemento.index, "giro", (elemento.giro + 90) % 360)
            }
        }
    }
}
