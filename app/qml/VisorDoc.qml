import QtQuick
import "textos.js" as Textos

Item {
    id: visorDoc
    property string idElemento: ""
    property url original
    property string ext: ""
    property real escala: 1.0

    readonly property string nombreDoc: nucleo.ficha.nombre ? nucleo.ficha.nombre : (original ? String(original).split("/").pop() : "")
    readonly property int bytesDoc: nucleo.ficha.bytes ? nucleo.ficha.bytes : 0

    // Barra superior de herramientas y datos del documento
    Rectangle {
        id: barraHerramientas
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: tema.margen * 2 + tema.hueco
        color: tema.panel
        border.color: tema.borde
        border.width: 1
        z: 2

        Row {
            anchors.left: parent.left
            anchors.leftMargin: tema.margen
            anchors.verticalCenter: parent.verticalCenter
            spacing: tema.hueco

            // Chip con la extensión
            Rectangle {
                width: rotuloExt.width + tema.hueco * 1.5
                height: rotuloExt.height + tema.hueco * 0.5
                radius: tema.radio * 0.5
                color: tema.marcador
                border.color: tema.borde
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: rotuloExt
                    anchors.centerIn: parent
                    text: (visorDoc.ext.length > 0 ? visorDoc.ext : "DOC").toUpperCase()
                    color: tema.texto
                    font.bold: true
                    font.pixelSize: tema.fuente * 0.85
                }
            }

            // Nombre y peso del documento
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    text: visorDoc.nombreDoc
                    color: tema.texto
                    font.bold: true
                    font.pixelSize: tema.fuente * 0.95
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                Text {
                    visible: visorDoc.bytesDoc > 0
                    text: Textos.peso(visorDoc.bytesDoc)
                    color: tema.textoTenue
                    font.pixelSize: tema.fuente * 0.8
                }
            }
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: tema.margen
            anchors.verticalCenter: parent.verticalCenter
            spacing: tema.hueco

            // Botón principal de abrir en aplicación nativa (Word / PowerPoint / Excel / etc.)
            Boton {
                anchors.verticalCenter: parent.verticalCenter
                texto: qsTr("abrir en programa predeterminado")
                onPulsado: nucleo.abrirFuera(visorDoc.idElemento)
            }
        }
    }

    // Contenedor de la vista previa de la tarjeta o miniatura generada
    Item {
        anchors.top: barraHerramientas.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        clip: true

        Image {
            id: vistaPrevia
            anchors.centerIn: parent
            width: Math.min(parent.width - tema.margen * 4, parent.height - tema.margen * 4)
            height: width
            source: visorDoc.idElemento.length > 0 ? "image://grim/previa/" + visorDoc.idElemento : ""
            asynchronous: true
            cache: true
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
        }
    }
}
