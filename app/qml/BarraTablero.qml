// Barra de control flotante para el lienzo infinito (PureRef).
//
// Puede replegarse en una píldora discreta o desplegar todas las herramientas.
// Cuando la ventana no tiene bordes, permite arrastrar la ventana desde ella.
import QtQuick

Item {
    id: barra
    property bool plegada: false
    height: Math.round(tema.fuente * 2.8)
    width: filaControles.implicitWidth + tema.margen * 2

    Rectangle {
        id: fondoBarra
        anchors.fill: parent
        color: tema.panel
        opacity: 0.94
        radius: tema.radio
        border.color: tema.borde
        border.width: 1

        // Arrastrar la ventana si no tiene bordes
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onPressed: function(mouse) {
                if (tablero.sinBordes) {
                    tablero.startSystemMove()
                }
            }
        }
    }

    Row {
        id: filaControles
        anchors.centerIn: parent
        spacing: Math.round(tema.hueco * 0.4)

        // Botón replegar / desplegar
        BotonIcono {
            icono: barra.plegada ? "abajo" : "derecha"
            pista: barra.plegada ? qsTr("desplegar controles") : qsTr("plegar barra")
            onPulsado: barra.plegada = !barra.plegada
        }

        // Título / Estado
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Tablero (%1)").arg(tablero.totalElementos)
            font.pixelSize: Math.round(tema.fuente * 0.85)
            font.bold: true
            color: tema.texto
        }

        Item {
            width: tema.hueco
            height: 1
            visible: !barra.plegada
        }

        // Controles expandidos
        Row {
            spacing: Math.round(tema.hueco * 0.4)
            visible: !barra.plegada

            // Auto-Pack
            BotonIcono {
                icono: "autoPack"
                pista: qsTr("organizar en mosaico compacto (Ctrl+P)")
                onPulsado: tablero.autoEmpaquetar()
            }

            // Encajar todo en vista
            BotonIcono {
                icono: "encajar"
                pista: qsTr("encajar todos los elementos (Ctrl+F)")
                onPulsado: tablero.centrarTodo()
            }

            // Siempre encima
            BotonIcono {
                icono: "iman"
                activo: tablero.siempreEncima
                pista: tablero.siempreEncima ? qsTr("desactivar siempre visible") : qsTr("fijar siempre encima")
                onPulsado: tablero.siempreEncima = !tablero.siempreEncima
            }

            // Sin bordes
            BotonIcono {
                icono: "pantalla"
                activo: tablero.sinBordes
                pista: tablero.sinBordes ? qsTr("mostrar bordes de ventana") : qsTr("modo sin bordes (PureRef)")
                onPulsado: tablero.sinBordes = !tablero.sinBordes
            }

            // Modo Fantasma (Click-through)
            BotonIcono {
                icono: "fantasma"
                activo: tablero.modoFantasma
                pista: qsTr("modo fantasma / clic transparente (Ctrl+T)")
                onPulsado: tablero.conmutarFantasma()
            }

            // Guardar tablero
            BotonIcono {
                icono: "copiar"
                pista: qsTr("guardar tablero (Ctrl+S)")
                onPulsado: tablero.guardarTablero()
            }

            // Cargar tablero
            BotonIcono {
                icono: "carpeta"
                pista: qsTr("abrir tablero guardado (Ctrl+O)")
                onPulsado: tablero.abrirTablero()
            }

            // Exportar imagen
            BotonIcono {
                icono: "exportar"
                pista: qsTr("exportar lienzo como PNG (Ctrl+E)")
                onPulsado: tablero.exportarPng()
            }

            // Vaciar tablero
            BotonIcono {
                icono: "papelera"
                pista: qsTr("vaciar el lienzo")
                onPulsado: tablero.vaciar()
            }

            // Cerrar
            BotonIcono {
                icono: "cerrar"
                pista: qsTr("cerrar tablero (Esc)")
                onPulsado: tablero.close()
            }
        }
    }
}
