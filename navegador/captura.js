// Captura de pantalla completa y de Ã¡rea visible.
// Desplaza la pÃ¡gina por partes, las captura y las cose usando el documento offscreen.
"use strict";

async function asegurarOffscreen() {
  if (await chrome.offscreen.hasDocument()) return;
  await chrome.offscreen.createDocument({
    url: "captura-offscreen.html",
    reasons: ["BLOBS"],
    justification: "Coser capturas de pantalla completa en un canvas",
  });
}

function esperar(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

/// Captura Ãºnicamente la zona visible de la pestaÃ±a actual.
async function capturarAreaVisible(tab) {
  try {
    const dataUrl = await chrome.tabs.captureVisibleTab(tab.windowId, { format: "png" });
    const datos = dataUrl.replace(/^data:image\/png;base64,/, "");
    const nombre = (tab.title ? `[Screenshot] ${tab.title}` : "Screenshot").slice(0, 80);
    return { ok: true, datos, tipo: "image/png", nombre, origen: tab.url };
  } catch (e) {
    return { ok: false, error: String((e && e.message) || e) };
  }
}

/// Captura la pÃ¡gina entera desplazÃ¡ndola fotograma a fotograma y cosiÃ©ndola.
async function capturarPaginaCompleta(tab) {
  try {
    // 1. Obtener mÃ©tricas de la pÃ¡gina y ocultar barras de scroll
    const [resultadoMetricas] = await chrome.scripting.executeScript({
      target: { tabId: tab.id },
      func: () => {
        // Guardar posiciÃ³n inicial
        const posInicial = { x: window.scrollX, y: window.scrollY };
        const dpr = window.devicePixelRatio || 1;
        const totalW = Math.max(document.documentElement.scrollWidth, document.body.scrollWidth);
        const totalH = Math.max(document.documentElement.scrollHeight, document.body.scrollHeight);
        const vW = window.innerWidth;
        const vH = window.innerHeight;

        // Ocultar barra de scroll temporalmente
        document.documentElement.style.overflow = "hidden";
        document.body.style.overflow = "hidden";

        return { totalW, totalH, vW, vH, dpr, posInicial };
      },
    });

    const { totalW, totalH, vW, vH, dpr, posInicial } = resultadoMetricas.result;

    const anchoLienzo = Math.round(totalW * dpr);
    const altoLienzo = Math.round(totalH * dpr);

    const tiras = [];
    let yActual = 0;

    // 2. Desplazar e ir capturando cada franja
    while (yActual < totalH) {
      await chrome.scripting.executeScript({
        target: { tabId: tab.id },
        func: (y) => window.scrollTo(0, y),
        args: [yActual],
      });

      // Breve pausa para permitir el repintado del DOM
      await esperar(180);

      const dataUrl = await chrome.tabs.captureVisibleTab(tab.windowId, { format: "png" });

      const restante = totalH - yActual;
      const esUltima = restante < vH;
      const altoRecorte = esUltima ? Math.round(restante * dpr) : 0;

      tiras.push({
        datos: dataUrl,
        y: Math.round(yActual * dpr),
        altoRecorte,
      });

      yActual += vH;
    }

    // 3. Restaurar scroll y estilos originales
    await chrome.scripting.executeScript({
      target: { tabId: tab.id },
      func: (pos) => {
        document.documentElement.style.overflow = "";
        document.body.style.overflow = "";
        window.scrollTo(pos.x, pos.y);
      },
      args: [posInicial],
    });

    // 4. Coser tiras usando el documento offscreen
    await asegurarOffscreen();
    const respuestaCoser = await chrome.runtime.sendMessage({
      tipo: "ensamblarCapturas",
      ancho: anchoLienzo,
      alto: altoLienzo,
      tiras,
    });

    if (!respuestaCoser || !respuestaCoser.ok) {
      return { ok: false, error: (respuestaCoser && respuestaCoser.error) || "Error al coser capturas" };
    }

    const nombre = (tab.title ? `[Full-Page] ${tab.title}` : "Full-Page Screenshot").slice(0, 80);
    return {
      ok: true,
      datos: respuestaCoser.datos,
      tipo: "image/png",
      nombre,
      origen: tab.url,
    };
  } catch (e) {
    return { ok: false, error: String((e && e.message) || e) };
  }
}
