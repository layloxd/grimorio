// Comparador de duplicados y similares lado a lado (Side-by-Side Comparison).
//
// Permite comparar dos imágenes con zoom y pan sincronizados, ver diferencias
// de resolución y peso, y decidir con un solo clic:
// - Quedarse con la de la izquierda y mandar la otra a la papelera;
// - Quedarse con la de la derecha;
// - Apilarlas como versiones de la misma imagen (conservando ambas bajo un solo elemento).
import QtQuick
import "textos.js" as Textos

Item {
    id: comparador

    property bool abierto: false
    property string idA: ""
    property string idB: ""
    property var pares: []
    property int parIndice: 0
    property bool sincronizado: true

    visible: abierto
    anchors.fill: parent
    z: 60

    readonly property int totalPares: pares.length
    readonly property int indiceA: modelo.indiceDe(idA)
    readonly property int indiceB: modelo.indiceDe(idB)

    readonly property string nombreA: indiceA >= 0 ? modelo.nombreDe(indiceA) : ""
    readonly property string nombreB: indiceB >= 0 ? modelo.nombreDe(indiceB) : ""
    readonly property int anchoA: indiceA >= 0 ? modelo.anchoDe(indiceA) : 0
    readonly property int altoA: indiceA >= 0 ? modelo.altoDe(indiceA) : 0
    readonly property int anchoB: indiceB >= 0 ? modelo.anchoDe(indiceB) : 0
    readonly property int altoB: indiceB >= 0 ? modelo.altoDe(indiceB) : 0
    readonly property real pesoA: indiceA >= 0 ? modelo.pesoDe(indiceA) : 0
    readonly property real pesoB: indiceB >= 0 ? modelo.pesoDe(indiceB) : 0
    readonly property string extA: indiceA >= 0 ? modelo.extDe(indiceA) : ""
    readonly property string extB: indiceB >= 0 ? modelo.extDe(indiceB) : ""
    readonly property string previaA: indiceA >= 0 ? modelo.previaDe(indiceA) : ""
    readonly property string previaB: indiceB >= 0 ? modelo.previaDe(indiceB) : ""

    property real zoomComun: 1.0
    property real despXComun: 0
    property real despYComun: 0

    function abrirConPares(listaPares) {
        pares = listaPares
        parIndice = 0
        if (pares.length > 0) {
            cargarPar(0)
            abierto = true
            comparador.forceActiveFocus()
        }
    }

    function abrirConDos(primero, segundo) {
        pares = [[primero, segundo]]
        parIndice = 0
        cargarPar(0)
        abierto = true
        comparador.forceActiveFocus()
    }

    function cargarPar(idx) {
        if (idx < 0 || idx >= pares.length) return
        parIndice = idx
        idA = pares[idx][0]
        idB = pares[idx][1]
        resetearVista()
    }

    function resetearVista() {
        zoomComun = 1.0
        despXComun = 0
        despYComun = 0
    }

    function invertirLados() {
        const aux = idA
        idA = idB
        idB = aux
    }

    function anteriorPar() {
        if (parIndice > 0) cargarPar(parIndice - 1)
    }

    function siguientePar() {
        if (parIndice + 1 < pares.length) cargarPar(parIndice + 1)
        else if (pares.length <= 1) cerrar()
    }

    function quedarseConA() {
        if (idB.length > 0) {
            nucleo.papelera([idB], true)
            avanzarTrasAccion()
        }
    }

    function quedarseConB() {
        if (idA.length > 0) {
            nucleo.papelera([idA], true)
            avanzarTrasAccion()
        }
    }

    function apilarAmbas() {
        if (idA.length > 0 && idB.length > 0) {
            const principal = pesoA >= pesoB ? idA : idB
            const secundaria = principal === idA ? idB : idA
            nucleo.apilar(principal, [secundaria])
            avanzarTrasAccion()
        }
    }

    function avanzarTrasAccion() {
        let nuevosPares = []
        for (let i = 0; i < pares.length; i++) {
            if (i !== parIndice) nuevosPares.push(pares[i])
        }
        pares = nuevosPares
        if (pares.length === 0) {
            cerrar()
        } else {
            if (parIndice >= pares.length) parIndice = pares.length - 1
            cargarPar(parIndice)
        }
    }

    function cerrar() {
        abierto = false
        idA = ""
        idB = ""
        pares = []
    }

    // Fondo opaco que absorbe eventos del ratón
    Rectangle {
        anchors.fill: parent
        color: tema.fondo
    }
    MouseArea { anchors.fill: parent }

    // Barra superior
    Rectangle {
        id: barraSuperior
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: Math.round(tema.fuente * 2.8)
        color: tema.panel
        border.color: tema.borde
        border.width: 1

        Row {
            anchors.left: parent.left
            anchors.leftMargin: tema.margen
            anchors.verticalCenter: parent.verticalCenter
            spacing: tema.hueco

            Icono {
                anchors.verticalCenter: parent.verticalCenter
                nombre: "comparar"
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Comparador de Duplicados")
                color: tema.texto
                font.pixelSize: tema.fuente * 1.1
                font.weight: Font.DemiBold
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: Math.round(tema.fuente * 1.4)
                color: tema.borde
            }

            Boton {
                anchors.verticalCenter: parent.verticalCenter
                altura: Math.round(tema.fuente * 2)
                texto: "◀"
                activo: comparador.parIndice > 0
                visible: comparador.totalPares > 1
                onPulsado: comparador.anteriorPar()
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: comparador.totalPares > 1
                      ? qsTr("Par %1 de %2").arg(comparador.parIndice + 1).arg(comparador.totalPares)
                      : qsTr("Comparación 1:1")
                color: tema.textoTenue
                font.pixelSize: tema.fuente * 0.95
            }

            Boton {
                anchors.verticalCenter: parent.verticalCenter
                altura: Math.round(tema.fuente * 2)
                texto: "▶"
                activo: comparador.parIndice + 1 < comparador.totalPares
                visible: comparador.totalPares > 1
                onPulsado: comparador.siguientePar()
            }
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: tema.margen
            anchors.verticalCenter: parent.verticalCenter
            spacing: tema.hueco * 0.6

            Boton {
                anchors.verticalCenter: parent.verticalCenter
                altura: Math.round(tema.fuente * 2)
                texto: qsTr("invertir lados")
                discreto: true
                onPulsado: comparador.invertirLados()
            }

            Boton {
                anchors.verticalCenter: parent.verticalCenter
                altura: Math.round(tema.fuente * 2)
                texto: comparador.sincronizado ? qsTr("zoom sincronizado: SÍ") : qsTr("zoom sincronizado: NO")
                activo: comparador.sincronizado
                discreto: !comparador.sincronizado
                onPulsado: comparador.sincronizado = !comparador.sincronizado
            }

            Boton {
                anchors.verticalCenter: parent.verticalCenter
                altura: Math.round(tema.fuente * 2)
                texto: qsTr("cerrar (Esc)")
                onPulsado: comparador.cerrar()
            }
        }
    }

    // Área principal de comparación (dos columnas)
    Item {
        id: areaComparacion
        anchors.top: barraSuperior.bottom
        anchors.bottom: barraInferior.top
        anchors.left: parent.left
        anchors.right: parent.right

        // Columna Izquierda (Elemento A)
        Item {
            id: colA
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width / 2

            Rectangle {
                id: cabeceraA
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: Math.round(tema.fuente * 3.4)
                color: tema.panel
                border.color: tema.borde
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    spacing: 2
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: comparador.nombreA.length > 0 ? comparador.nombreA : "—"
                        color: tema.texto
                        font.pixelSize: tema.fuente
                        font.weight: Font.DemiBold
                        elide: Text.ElideMiddle
                        maximumLineCount: 1
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: (comparador.anchoA > 0 ? (comparador.anchoA + " × " + comparador.altoA + " px · ") : "")
                              + Textos.peso(comparador.pesoA) + " · " + comparador.extA.toUpperCase()
                        color: tema.textoTenue
                        font.pixelSize: tema.fuente * 0.85
                    }
                }
            }

            Item {
                id: visorA
                anchors.top: cabeceraA.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                clip: true

                Image {
                    id: imagenA
                    anchors.centerIn: parent
                    source: comparador.previaA.length > 0 ? "image://grim/previa/" + comparador.previaA : ""
                    fillMode: Image.PreserveAspectFit
                    width: parent.width * 0.9 * (comparador.sincronizado ? comparador.zoomComun : 1.0)
                    height: parent.height * 0.9 * (comparador.sincronizado ? comparador.zoomComun : 1.0)
                    x: (parent.width - width) / 2 + (comparador.sincronizado ? comparador.despXComun : 0)
                    y: (parent.height - height) / 2 + (comparador.sincronizado ? comparador.despYComun : 0)
                    smooth: true
                    mipmap: true
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    property real inicioX: 0
                    property real inicioY: 0
                    property bool arrastrando: false

                    onPressed: function (mouse) {
                        inicioX = mouse.x
                        inicioY = mouse.y
                        arrastrando = true
                    }
                    onPositionChanged: function (mouse) {
                        if (arrastrando) {
                            const dx = mouse.x - inicioX
                            const dy = mouse.y - inicioY
                            inicioX = mouse.x
                            inicioY = mouse.y
                            comparador.despXComun += dx
                            comparador.despYComun += dy
                        }
                    }
                    onReleased: arrastrando = false
                    onWheel: function (wheel) {
                        const factor = wheel.angleDelta.y > 0 ? 1.15 : 0.87
                        comparador.zoomComun = Math.max(0.5, Math.min(8.0, comparador.zoomComun * factor))
                    }
                    onDoubleClicked: comparador.resetearVista()
                }
            }
        }

        // Línea divisoria central con resumen comparativo
        Rectangle {
            id: divisorCentral
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 1
            color: tema.borde
            z: 10
        }

        // Insignia de comparación en el centro
        Rectangle {
            anchors.centerIn: parent
            z: 20
            width: Math.min(260, parent.width * 0.25)
            height: columnaResumen.height + tema.hueco * 1.5
            radius: tema.radio
            color: tema.panel
            border.color: tema.borde
            border.width: 1

            Column {
                id: columnaResumen
                anchors.centerIn: parent
                width: parent.width - tema.hueco * 1.5
                spacing: tema.hueco * 0.4

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: {
                        if (comparador.anchoA === comparador.anchoB && comparador.altoA === comparador.altoB && comparador.pesoA === comparador.pesoB) {
                            return qsTr("¡Copias Idénticas!")
                        } else {
                            return qsTr("Variantes Similares")
                        }
                    }
                    color: tema.texto
                    font.pixelSize: tema.fuente * 0.95
                    font.weight: Font.DemiBold
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: {
                        const resA = comparador.anchoA * comparador.altoA
                        const resB = comparador.anchoB * comparador.altoB
                        if (resA > resB) return qsTr("A tiene mayor resolución")
                        if (resB > resA) return qsTr("B tiene mayor resolución")
                        return qsTr("Misma resolución")
                    }
                    color: tema.textoTenue
                    font.pixelSize: tema.fuente * 0.8
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: {
                        if (comparador.pesoA > comparador.pesoB && comparador.pesoA > 0) {
                            const pct = Math.round((1 - comparador.pesoB / comparador.pesoA) * 100)
                            return qsTr("B es %1 % más ligero").arg(pct)
                        } else if (comparador.pesoB > comparador.pesoA && comparador.pesoB > 0) {
                            const pct = Math.round((1 - comparador.pesoA / comparador.pesoB) * 100)
                            return qsTr("A es %1 % más ligero").arg(pct)
                        }
                        return qsTr("Mismo peso")
                    }
                    color: tema.textoTenue
                    font.pixelSize: tema.fuente * 0.8
                }
            }
        }

        // Columna Derecha (Elemento B)
        Item {
            id: colB
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width / 2

            Rectangle {
                id: cabeceraB
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: Math.round(tema.fuente * 3.4)
                color: tema.panel
                border.color: tema.borde
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    spacing: 2
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: comparador.nombreB.length > 0 ? comparador.nombreB : "—"
                        color: tema.texto
                        font.pixelSize: tema.fuente
                        font.weight: Font.DemiBold
                        elide: Text.ElideMiddle
                        maximumLineCount: 1
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: (comparador.anchoB > 0 ? (comparador.anchoB + " × " + comparador.altoB + " px · ") : "")
                              + Textos.peso(comparador.pesoB) + " · " + comparador.extB.toUpperCase()
                        color: tema.textoTenue
                        font.pixelSize: tema.fuente * 0.85
                    }
                }
            }

            Item {
                id: visorB
                anchors.top: cabeceraB.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                clip: true

                Image {
                    id: imagenB
                    anchors.centerIn: parent
                    source: comparador.previaB.length > 0 ? "image://grim/previa/" + comparador.previaB : ""
                    fillMode: Image.PreserveAspectFit
                    width: parent.width * 0.9 * (comparador.sincronizado ? comparador.zoomComun : 1.0)
                    height: parent.height * 0.9 * (comparador.sincronizado ? comparador.zoomComun : 1.0)
                    x: (parent.width - width) / 2 + (comparador.sincronizado ? comparador.despXComun : 0)
                    y: (parent.height - height) / 2 + (comparador.sincronizado ? comparador.despYComun : 0)
                    smooth: true
                    mipmap: true
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    property real inicioX: 0
                    property real inicioY: 0
                    property bool arrastrando: false

                    onPressed: function (mouse) {
                        inicioX = mouse.x
                        inicioY = mouse.y
                        arrastrando = true
                    }
                    onPositionChanged: function (mouse) {
                        if (arrastrando) {
                            const dx = mouse.x - inicioX
                            const dy = mouse.y - inicioY
                            inicioX = mouse.x
                            inicioY = mouse.y
                            comparador.despXComun += dx
                            comparador.despYComun += dy
                        }
                    }
                    onReleased: arrastrando = false
                    onWheel: function (wheel) {
                        const factor = wheel.angleDelta.y > 0 ? 1.15 : 0.87
                        comparador.zoomComun = Math.max(0.5, Math.min(8.0, comparador.zoomComun * factor))
                    }
                    onDoubleClicked: comparador.resetearVista()
                }
            }
        }
    }

    // Barra de acciones inferior
    Rectangle {
        id: barraInferior
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: Math.round(tema.fuente * 4.2)
        color: tema.panel
        border.color: tema.borde
        border.width: 1

        Row {
            anchors.centerIn: parent
            spacing: tema.hueco * 1.5

            Boton {
                anchors.verticalCenter: parent.verticalCenter
                altura: Math.round(tema.fuente * 2.4)
                texto: qsTr("quedarse con A (borrar B)")
                activo: true
                onPulsado: comparador.quedarseConA()
            }

            Boton {
                anchors.verticalCenter: parent.verticalCenter
                altura: Math.round(tema.fuente * 2.4)
                texto: qsTr("apilar como versiones")
                onPulsado: comparador.apilarAmbas()
            }

            Boton {
                anchors.verticalCenter: parent.verticalCenter
                altura: Math.round(tema.fuente * 2.4)
                texto: qsTr("quedarse con B (borrar A)")
                activo: true
                onPulsado: comparador.quedarseConB()
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: Math.round(tema.fuente * 1.6)
                color: tema.borde
            }

            Boton {
                anchors.verticalCenter: parent.verticalCenter
                altura: Math.round(tema.fuente * 2.4)
                texto: qsTr("saltar (siguiente)")
                discreto: true
                onPulsado: comparador.siguientePar()
            }
        }
    }

    // Atajos de teclado para flujo de deduplicación ultrarrápido
    Shortcut {
        sequence: "Esc"
        enabled: comparador.abierto
        onActivated: comparador.cerrar()
    }
    Shortcut {
        sequence: "1"
        enabled: comparador.abierto
        onActivated: comparador.quedarseConA()
    }
    Shortcut {
        sequence: "2"
        enabled: comparador.abierto
        onActivated: comparador.quedarseConB()
    }
    Shortcut {
        sequence: "S"
        enabled: comparador.abierto
        onActivated: comparador.apilarAmbas()
    }
    Shortcut {
        sequence: "Right"
        enabled: comparador.abierto
        onActivated: comparador.siguientePar()
    }
    Shortcut {
        sequence: "Left"
        enabled: comparador.abierto
        onActivated: comparador.anteriorPar()
    }
}
