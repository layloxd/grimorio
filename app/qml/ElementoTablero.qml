// Un elemento dentro del lienzo infinito de referencias (modo PureRef).
//
// Puede moverse, redimensionarse mediante asas de escala, rotarse y voltearse.
// Todo el estilo proviene de `tema` para respetar `sin_colores_a_mano`.
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
    property real arrastreInicioX: 0
    property real arrastreInicioY: 0

    // Contenedor visual de la imagen
    Item {
        id: contenedor
        anchors.fill: parent

        // Fondo sutil para que no quede invisible mientras carga o si es documento
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
                    // Fallback en cascada si la fuente directa falló (p. ej. vídeo, RAW o documento)
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

        // Icono y rótulo de archivo en caso de que no tenga imagen visual
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
                modeloElementos.setProperty(elemento.index, "posX", elemento.posX + dx)
                modeloElementos.setProperty(elemento.index, "posY", elemento.posY + dy)
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
                inicioEscala = elemento.escala
            }

            onPositionChanged: function(mouse) {
                if (pressed) {
                    const dx = (mouse.x - inicioX) / tablero.mundoZoom
                    const nuevoAncho = (elemento.ancho * inicioEscala) + dx
                    const factor = Math.max(0.1, Math.min(10.0, nuevoAncho / elemento.ancho))
                    modeloElementos.setProperty(elemento.index, "escala", factor)
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
                modeloElementos.setProperty(elemento.index, "giro", (elemento.giro + 90) % 360)
            }
        }
    }
}
