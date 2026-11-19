// Visor interactivo de tipografÃ­as (fuentes TTF, OTF, WOFF).
// Permite probar la letra con texto propio, cascada de tamaÃ±os, tabla de
// glifos y activarla/desactivarla en el sistema operativo en caliente.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "textos.js" as Textos

Item {
    id: visorFuente
    property string idElemento: ""
    property url original
    readonly property string rutaLocal: {
        const s = String(original)
        if (s.startsWith("file:///")) return s.slice(8)
        if (s.startsWith("file://")) return s.slice(7)
        return s
    }

    property bool activa: rutaLocal.length > 0 ? nucleo.estaFuenteActiva(rutaLocal) : false
    property int modo: 0 // 0: Pangrama/Texto, 1: Cascada, 2: Glifos
    property real tamanoLetra: Math.round(tema.fuente * 3.5)

    FontLoader {
        id: cargador
        source: original
    }

    Connections {
        target: nucleo
        function onFuenteEstadoCambio(r, est) {
            if (r === visorFuente.rutaLocal || r === String(visorFuente.original))
                visorFuente.activa = est
        }
    }

    onIdElementoChanged: {
        if (rutaLocal.length > 0)
            activa = nucleo.estaFuenteActiva(rutaLocal)
    }

    // ----------------------------------------------------- Barra de mandos
    Rectangle {
        id: barra
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: tema.margen
        }
        height: Math.round(tema.fuente * 2.8)
        radius: tema.radio
        color: tema.panel
        border.color: tema.borde
        border.width: 1
        z: 10

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: tema.margen
            anchors.rightMargin: tema.margen
            spacing: tema.hueco

            // Nombre de la tipografÃ­a
            RowLayout {
                spacing: tema.hueco * 0.5
                Rectangle {
                    width: Math.round(tema.fuente * 1.6)
                    height: Math.round(tema.fuente * 1.6)
                    radius: tema.radio * 0.6
                    color: tema.marcador
                    Text {
                        anchors.centerIn: parent
                        text: "F"
                        color: tema.texto
                        font.pixelSize: tema.fuente * 0.9
                        font.weight: Font.Bold
                    }
                }
                Text {
                    text: cargador.name.length > 0 ? cargador.name : qsTr("Cargando tipografÃ­aâ€¦")
                    color: tema.texto
                    font.pixelSize: tema.fuente * 1.05
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    Layout.maximumWidth: Math.round(tema.fuente * 16)
                }
            }

            Item { Layout.fillWidth: true }

            // Selector de modo (Pangrama / Cascada / Glifos)
            RowLayout {
                spacing: 2
                Repeater {
                    model: [
                        { idx: 0, rotulo: qsTr("Texto") },
                        { idx: 1, rotulo: qsTr("Cascada") },
                        { idx: 2, rotulo: qsTr("Glifos") }
                    ]
                    Rectangle {
                        required property var modelData
                        width: Math.round(tema.fuente * 4.5)
                        height: Math.round(tema.fuente * 1.8)
                        radius: tema.radio * 0.5
                        color: visorFuente.modo === modelData.idx ? tema.seleccion : "transparent"
                        border.color: visorFuente.modo === modelData.idx ? tema.seleccion : tema.borde
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: modelData.rotulo
                            color: visorFuente.modo === modelData.idx ? tema.fondo : tema.texto
                            font.pixelSize: tema.fuente * 0.85
                            font.weight: visorFuente.modo === modelData.idx ? Font.Bold : Font.Normal
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: visorFuente.modo = modelData.idx
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // Control de tamaÃ±o de letra (solo en modo texto y glifos)
            RowLayout {
                spacing: tema.hueco * 0.5
                visible: visorFuente.modo !== 1
                Text {
                    text: Math.round(visorFuente.tamanoLetra) + " px"
                    color: tema.textoTenue
                    font.pixelSize: tema.fuente * 0.85
                    Layout.minimumWidth: Math.round(tema.fuente * 3.5)
                }
                Slider {
                    id: deslizadorTamano
                    from: Math.round(tema.fuente * 1.2)
                    to: Math.round(tema.fuente * 8.0)
                    value: visorFuente.tamanoLetra
                    onMoved: visorFuente.tamanoLetra = value
                    Layout.preferredWidth: Math.round(tema.fuente * 7)
                }
            }

            // BotÃ³n de activaciÃ³n en Windows
            Rectangle {
                id: btnActivar
                height: Math.round(tema.fuente * 2.0)
                width: Math.round(tema.fuente * 9.5)
                radius: tema.radio * 0.6
                color: visorFuente.activa ? tema.seleccion : tema.marcador
                border.color: visorFuente.activa ? tema.seleccion : tema.borde
                border.width: 1

                RowLayout {
                    anchors.centerIn: parent
                    spacing: tema.hueco * 0.4
                    Text {
                        text: visorFuente.activa ? "âœ“" : "+"
                        color: visorFuente.activa ? tema.fondo : tema.texto
                        font.pixelSize: tema.fuente * 0.95
                        font.weight: Font.Bold
                    }
                    Text {
                        text: visorFuente.activa ? qsTr("Activa en sistema") : qsTr("Activar en Windows")
                        color: visorFuente.activa ? tema.fondo : tema.texto
                        font.pixelSize: tema.fuente * 0.85
                        font.weight: Font.DemiBold
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (visorFuente.rutaLocal.length > 0)
                            nucleo.conmutarFuente(visorFuente.rutaLocal)
                    }
                }
            }
        }
    }

    // ---------------------------------------------------- Contenido central
    Item {
        anchors {
            top: barra.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: tema.margen
        }

        // 1. Modo Pangrama / Texto interactivo
        Flickable {
            id: vistaTexto
            anchors.fill: parent
            visible: visorFuente.modo === 0
            contentWidth: width
            contentHeight: Math.max(height, areaTexto.implicitHeight + tema.margen * 4)
            clip: true

            TextArea {
                id: areaTexto
                width: parent.width - tema.margen * 2
                x: tema.margen
                y: tema.margen
                wrapMode: TextArea.Wrap
                text: "ZaÅ¼Ã³Å‚Ä‡ gÄ™Å›lÄ… jaÅºÅ„\nThe quick brown fox jumps over the lazy dog\n0123456789 Â· !@#$%^&*()_+"
                color: tema.texto
                selectionColor: tema.seleccion
                selectedTextColor: tema.fondo
                font.family: cargador.name
                font.pixelSize: visorFuente.tamanoLetra
                background: null
            }
        }

        // 2. Modo Cascada de tamaÃ±os
        Flickable {
            id: vistaCascada
            anchors.fill: parent
            visible: visorFuente.modo === 1
            contentWidth: width
            contentHeight: columnaCascada.implicitHeight + tema.margen * 4
            clip: true

            Column {
                id: columnaCascada
                width: parent.width - tema.margen * 2
                x: tema.margen
                y: tema.margen
                spacing: tema.hueco * 1.5

                Repeater {
                    model: [16, 22, 28, 38, 52, 70, 96]
                    Column {
                        required property int modelData
                        width: parent.width
                        spacing: 4

                        Text {
                            text: modelData + " px"
                            color: tema.textoTenue
                            font.pixelSize: tema.fuente * 0.75
                        }
                        Text {
                            width: parent.width
                            text: "ZaÅ¼Ã³Å‚Ä‡ gÄ™Å›lÄ… jaÅºÅ„ Â· The quick brown fox jumps over the lazy dog 1234567890"
                            color: tema.texto
                            font.family: cargador.name
                            font.pixelSize: modelData
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }

        // 3. Modo Glifos
        Flickable {
            id: vistaGlifos
            anchors.fill: parent
            visible: visorFuente.modo === 2
            contentWidth: width
            contentHeight: rejillaGlifos.implicitHeight + tema.margen * 4
            clip: true

            Grid {
                id: rejillaGlifos
                width: parent.width - tema.margen * 2
                x: tema.margen
                y: tema.margen
                columns: Math.max(6, Math.floor(width / Math.round(tema.fuente * 4.5)))
                spacing: tema.hueco * 0.6

                Repeater {
                    model: [
                        "A","B","C","D","E","F","G","H","I","J","K","L","M",
                        "N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
                        "a","b","c","d","e","f","g","h","i","j","k","l","m",
                        "n","o","p","q","r","s","t","u","v","w","x","y","z",
                        "Ä„","Ä†","Ä˜","Å","Åƒ","Ã“","Åš","Å¹","Å»",
                        "Ä…","Ä‡","Ä™","Å‚","Å„","Ã³","Å›","Åº","Å¼",
                        "0","1","2","3","4","5","6","7","8","9",
                        "!","@","#","$","%","^","&","*","(",")","-","+","=",
                        "[","]","{","}","\\","|",";",":","'","\"",",",".","<",">","/","?"
                    ]

                    Rectangle {
                        required property string modelData
                        width: Math.round(tema.fuente * 4.0)
                        height: Math.round(tema.fuente * 4.5)
                        radius: tema.radio * 0.5
                        color: tema.panel
                        border.color: tema.borde
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -Math.round(tema.fuente * 0.4)
                            text: modelData
                            color: tema.texto
                            font.family: cargador.name
                            font.pixelSize: Math.round(tema.fuente * 2.2)
                        }

                        Text {
                            anchors {
                                bottom: parent.bottom
                                horizontalCenter: parent.horizontalCenter
                                bottomMargin: Math.round(tema.fuente * 0.3)
                            }
                            text: "U+" + modelData.charCodeAt(0).toString(16).toUpperCase()
                            color: tema.textoTenue
                            font.pixelSize: tema.fuente * 0.65
                        }
                    }
                }
            }
        }
    }
}
