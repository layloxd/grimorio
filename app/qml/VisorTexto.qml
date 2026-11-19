import QtQuick
import "textos.js" as Textos

Item {
    id: visorTexto
    property string idElemento: ""
    property url original
    property string ext: ""
    property string contenido: ""
    property bool verRenderizado: ext === "md" || ext === "markdown"
    property real factorFuente: 1.0

    readonly property bool esMarkdown: ext === "md" || ext === "markdown"
    readonly property int lineasContadas: contenido.length > 0 ? contenido.split("\n").length : 0
    readonly property int caracteresContados: contenido.length

    function cargar() {
        if (original && String(original).length > 0) {
            contenido = nucleo.leerTexto(original)
        } else {
            contenido = ""
        }
    }

    onOriginalChanged: cargar()
    onIdElementoChanged: cargar()

    // Barra superior de herramientas del lector
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
                    text: (visorTexto.ext.length > 0 ? visorTexto.ext : "TXT").toUpperCase()
                    color: tema.texto
                    font.bold: true
                    font.pixelSize: tema.fuente * 0.85
                }
            }

            // Alternar vista renderizada vs texto plano para Markdown
            Boton {
                visible: visorTexto.esMarkdown
                anchors.verticalCenter: parent.verticalCenter
                texto: visorTexto.verRenderizado ? qsTr("ver código fuente") : qsTr("ver renderizado")
                onPulsado: visorTexto.verRenderizado = !visorTexto.verRenderizado
            }

            // Botones de zoom de letra
            BotonIcono {
                anchors.verticalCenter: parent.verticalCenter
                icono: "menos"
                aviso: qsTr("reducir texto")
                onPulsado: visorTexto.factorFuente = Math.max(0.7, visorTexto.factorFuente - 0.1)
            }

            BotonIcono {
                anchors.verticalCenter: parent.verticalCenter
                icono: "mas"
                aviso: qsTr("aumentar texto")
                onPulsado: visorTexto.factorFuente = Math.min(2.5, visorTexto.factorFuente + 0.1)
            }
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: tema.margen
            anchors.verticalCenter: parent.verticalCenter
            spacing: tema.hueco

            // Estadísticas: líneas y caracteres
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("%1 líneas · %2 caracteres").arg(Textos.numero(visorTexto.lineasContadas)).arg(Textos.numero(visorTexto.caracteresContados))
                color: tema.textoTenue
                font.pixelSize: tema.fuente * 0.85
            }

            // Copiar texto
            BotonIcono {
                anchors.verticalCenter: parent.verticalCenter
                icono: "copiar"
                aviso: qsTr("copiar todo el texto")
                onPulsado: {
                    editorTexto.selectAll()
                    editorTexto.copy()
                    editorTexto.deselect()
                    estado.avisar(qsTr("texto copiado al portapapeles"))
                }
            }

            // Abrir fuera en editor del sistema
            Boton {
                anchors.verticalCenter: parent.verticalCenter
                texto: qsTr("abrir en el editor")
                onPulsado: nucleo.abrirFuera(visorTexto.idElemento)
            }
        }
    }

    // Área de lectura desplazable
    Flickable {
        id: scroll
        anchors.top: barraHerramientas.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        contentWidth: anchoHoja.width
        contentHeight: anchoHoja.height + tema.margen * 4
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Item {
            id: anchoHoja
            width: scroll.width
            height: hoja.height + tema.margen * 4

            Rectangle {
                id: hoja
                anchors.horizontalCenter: parent.horizontalCenter
                y: tema.margen * 2
                width: Math.min(parent.width - tema.margen * 4, 920)
                height: Math.max(400, (visorTexto.verRenderizado ? textoRender.implicitHeight : editorTexto.implicitHeight) + tema.margen * 4)
                color: tema.panel
                border.color: tema.borde
                border.width: 1
                radius: tema.radio

                // Vista Markdown enriquecida
                Text {
                    id: textoRender
                    visible: visorTexto.verRenderizado
                    anchors.fill: parent
                    anchors.margins: tema.margen * 2
                    text: visorTexto.contenido
                    textFormat: Text.MarkdownText
                    wrapMode: Text.Wrap
                    color: tema.texto
                    font.pixelSize: tema.fuente * visorTexto.factorFuente
                }

                // Vista monospaciada seleccionable para texto plano, JSON, logs o código
                TextEdit {
                    id: editorTexto
                    visible: !visorTexto.verRenderizado
                    anchors.fill: parent
                    anchors.margins: tema.margen * 2
                    text: visorTexto.contenido
                    readOnly: true
                    selectByMouse: true
                    wrapMode: Text.Wrap
                    color: tema.texto
                    selectionColor: tema.seleccion
                    selectedTextColor: tema.fondo
                    font.family: "Consolas, Courier New, monospace"
                    font.pixelSize: (tema.fuente - 1) * visorTexto.factorFuente
                }
            }
        }
    }
}
