// Documento offscreen para coser tiras de capturas de pantalla completa.
"use strict";

chrome.runtime.onMessage.addListener((m, _de, responder) => {
  if (m.tipo !== "ensamblarCapturas") return false;

  (async () => {
    try {
      const { ancho, alto, tiras } = m;
      const lienzo = document.getElementById("lienzo");
      lienzo.width = ancho;
      lienzo.height = alto;
      const ctx = lienzo.getContext("2d");

      for (const tira of tiras) {
        const img = new Image();
        await new Promise((resolver, rechazar) => {
          img.onload = resolver;
          img.onerror = rechazar;
          img.src = tira.datos;
        });

        // Dibujar tira en su posiciÃ³n Y correspondiente
        // tira.altoRecorte puede indicar si la Ãºltima tira es parcial
        if (tira.altoRecorte && tira.altoRecorte < img.height) {
          const diferencia = img.height - tira.altoRecorte;
          ctx.drawImage(
            img,
            0, diferencia, img.width, tira.altoRecorte,
            0, tira.y, ancho, tira.altoRecorte
          );
        } else {
          ctx.drawImage(img, 0, tira.y, ancho, img.height);
        }
      }

      // Convertir a base64 limpio (sin el prefijo data:image/png;base64,)
      const dataUrl = lienzo.toDataURL("image/png");
      const base64Limpio = dataUrl.replace(/^data:image\/png;base64,/, "");

      responder({ ok: true, datos: base64Limpio, tipo: "image/png" });
    } catch (e) {
      responder({ ok: false, error: String((e && e.message) || e) });
    }
  })();

  return true;
});
