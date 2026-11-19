// Un elemento dentro del lienzo infinito de referencias (modo PureRef).
//
// Puede moverse, redimensionarse mediante asas de escala, rotarse y voltearse.
// Todo el estilo proviene de `tema` para respetar `sin_colores_a_mano`.
import QtQuick

Item {
    id: elemento
    required property int index
    required property var model

    x: model.posX
    y: model.posY
    width: Math.max(32, model.ancho * model.escala)
    height: Math.max(32, model.alto * model.escala)
    rotation: model.giro
    z: model.orden

    readonly property bool seleccionado: tablero.indiceSeleccionado === index
    property real arrastreInicioX: 0
    property real arrastreInicioY: 0

    // Contenedor visual de la imagen
    Item {
        id: contenedor
        anchors.fill: parent

        Image {
            id: imagen
            anchors.fill: parent
            source: model.fuente
            fillMode: Image.PreserveAspectFit
            mirror: model.espejoH
            asynchronous: true
            smooth: true
            mipmap: true

            onStatusChanged: {
                if (status === Image.Ready && (model.ancho <= 0 || model.alto <= 0)) {
                    let w = implicitWidth > 0 ? implicitWidth : 400
                    let h = implicitHeight > 0 ? implicitHeight : 300
                    // Limitar tamaño por defecto si es una imagen gigante
                    if (w > 800 || h > 800) {
                        const factor = Math.min(800 / w, 800 / h)
                        w = Math.round(w * factor)
                        h = Math.round(h * factor)
                    }
                    model.ancho = w
                    model.alto = h
                }
            }
        }

        // Borde y realce de selección
        Rectangle {
            anchors.fill: parent
            visible: elemento.seleccionado
            color: "transparent"
            border.color: tema.seleccion
            border.width: Math.max(1, Math.round(2 / tablero.mundoZoom))
        }
    }

    // Área para mover el elemento y seleccionarlo
    MouseArea {
        id: zonaMover
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPressed: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                tablero.seleccionar(elemento.index)
                elemento.arrastreInicioX = mouse.x
                elemento.arrastreInicioY = mouse.y
            } else if (mouse.button === Qt.RightButton) {
                tablero.seleccionar(elemento.index)
            }
        }

        onPositionChanged: function(mouse) {
            if (pressed && (mouse.buttons & Qt.LeftButton)) {
                const dx = (mouse.x - elemento.arrastreInicioX) / tablero.mundoZoom
                const dy = (mouse.y - elemento.arrastreInicioY) / tablero.mundoZoom
                model.posX += dx
                model.posY += dy
            }
        }

        onDoubleClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                tablero.enfocarElemento(elemento.index)
            }
        }
    }

    // Asa de escala en la esquina inferior derecha
    Rectangle {
        id: asaEscala
        visible: elemento.seleccionado
        width: Math.max(8, Math.round(14 / tablero.mundoZoom))
        height: width
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: -width / 2
        anchors.bottomMargin: -height / 2
        color: tema.seleccion
        border.color: tema.panel
        border.width: Math.max(1, Math.round(1 / tablero.mundoZoom))
        radius: width / 2
        z: 10

        MouseArea {
            id: zonaEscala
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeFDiagCursor
            preventStealing: true

            property real inicioX: 0
            property real inicioEscala: 1

            onPressed: function(mouse) {
                inicioX = mouse.x
                inicioEscala = model.escala
            }

            onPositionChanged: function(mouse) {
                if (pressed) {
                    const dx = (mouse.x - inicioX) / tablero.mundoZoom
                    const nuevoAncho = (model.ancho * inicioEscala) + dx
                    const factor = Math.max(0.1, Math.min(10.0, nuevoAncho / model.ancho))
                    model.escala = factor
                }
            }
        }
    }

    // Asa de rotación arriba en el centro
    Rectangle {
        id: asaGiro
        visible: elemento.seleccionado
        width: Math.max(8, Math.round(14 / tablero.mundoZoom))
        height: width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: -width * 1.5
        color: tema.marcador
        border.color: tema.panel
        border.width: Math.max(1, Math.round(1 / tablero.mundoZoom))
        radius: width / 2
        z: 10

        // Línea conectora
        Rectangle {
            width: Math.max(1, Math.round(1 / tablero.mundoZoom))
            height: asaGiro.width * 1.5
            color: tema.marcador
            anchors.top: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
        }

        MouseArea {
            id: zonaGiro
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            preventStealing: true

            onClicked: {
                model.giro = (model.giro + 90) % 360
            }
        }
    }
}
