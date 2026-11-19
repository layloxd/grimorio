// Zona flotante para arrastrar y soltar imÃ¡genes directamente a Grimorio.
// Se muestra automÃ¡ticamente en la parte inferior cuando el usuario arrastra algo en la pÃ¡gina.
"use strict";

(() => {
  let anfitrion = null;
  let sombra = null;
  let barra = null;
  let texto = null;
  let contadorOcultar = null;

  function montar() {
    if (anfitrion && anfitrion.isConnected) return;

    anfitrion = document.createElement("div");
    anfitrion.dataset.grimorioArrastre = "";
    anfitrion.style.cssText = "position:fixed;bottom:0;left:0;width:100%;height:0;z-index:2147483647;pointer-events:none;";
    sombra = anfitrion.attachShadow({ mode: "open" });

    sombra.innerHTML = `
      <style>
        .dropzone {
          position: fixed;
          bottom: 24px;
          left: 50%;
          transform: translateX(-50%) translateY(120px);
          opacity: 0;
          pointer-events: auto;
          background: rgba(22, 22, 26, 0.94);
          border: 2px dashed #4b4b5a;
          border-radius: 14px;
          padding: 12px 28px;
          display: flex;
          align-items: center;
          gap: 12px;
          font: 600 13px system-ui, sans-serif;
          color: #efece6;
          box-shadow: 0 10px 35px rgba(0,0,0,0.6);
          backdrop-filter: blur(12px);
          transition: transform 0.25s cubic-bezier(0.16, 1, 0.3, 1), opacity 0.25s ease, border-color 0.15s ease, background 0.15s ease;
        }
        .dropzone.visible {
          transform: translateX(-50%) translateY(0);
          opacity: 1;
        }
        .dropzone.hover {
          border-color: #4caf7d;
          background: rgba(30, 45, 36, 0.96);
          transform: translateX(-50%) translateY(-4px) scale(1.03);
          box-shadow: 0 14px 40px rgba(76, 175, 125, 0.25);
        }
        .icono {
          width: 22px;
          height: 22px;
          flex-shrink: 0;
        }
        .texto {
          white-space: nowrap;
        }
      </style>
      <div class="dropzone" id="dropzone">
        <svg class="icono" viewBox="0 0 24 24" fill="none" stroke="#4caf7d" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
          <polyline points="7 10 12 15 17 10"></polyline>
          <line x1="12" y1="15" x2="12" y2="3"></line>
        </svg>
        <span class="texto" id="texto">${textoGrimorio("arrastrarSoltar")}</span>
      </div>
    `;

    document.documentElement.appendChild(anfitrion);
    barra = sombra.getElementById("dropzone");
    texto = sombra.getElementById("texto");

    barra.addEventListener("dragover", (e) => {
      e.preventDefault();
      e.stopPropagation();
      e.dataTransfer.dropEffect = "copy";
      barra.classList.add("hover");
      texto.textContent = textoGrimorio("arrastrarSoltar2");
    });

    barra.addEventListener("dragleave", (e) => {
      e.preventDefault();
      e.stopPropagation();
      barra.classList.remove("hover");
      texto.textContent = textoGrimorio("arrastrarSoltar");
    });

    barra.addEventListener("drop", async (e) => {
      e.preventDefault();
      e.stopPropagation();
      barra.classList.remove("hover");
      esconder();

      const dt = e.dataTransfer;
      const urls = [];

      // 1. Extraer URL de imagen o vÃ­nculo
      const uriList = dt.getData("text/uri-list");
      if (uriList) {
        for (const u of uriList.split("\n")) {
          const limpio = u.trim();
          if (limpio && !limpio.startsWith("#") && /^https?:/.test(limpio)) {
            urls.push(limpio);
          }
        }
      }

      // 2. Extraer HTML arrastrado (suele contener la <img src="...">)
      if (urls.length === 0) {
        const html = dt.getData("text/html");
        if (html) {
          const parser = new DOMParser();
          const doc = parser.parseFromString(html, "text/html");
          for (const img of doc.querySelectorAll("img")) {
            if (img.src && /^https?:/.test(img.src)) urls.push(img.src);
          }
        }
      }

      // 3. Texto plano con URL
      if (urls.length === 0) {
        const plain = dt.getData("text/plain");
        if (plain && /^https?:/.test(plain.trim())) {
          urls.push(plain.trim());
        }
      }

      if (urls.length === 0) {
        avisoGrimorio({
          estado: "error",
          titulo: textoGrimorio("avisoNadaQueGuardar"),
        });
        return;
      }

      avisoGrimorio({
        estado: "en curso",
        titulo: textoGrimorio("avisoGuardando"),
      });

      const lista = urls.map(url => ({
        url,
        origen: location.href,
        nombre: document.title || "Dropped Item"
      }));

      const r = await chrome.runtime.sendMessage({ tipo: "guardar", lista });
      avisoGrimorio(avisoDeResultado(r, lista.length));
    });
  }

  function mostrar() {
    montar();
    barra.classList.add("visible");
    clearTimeout(contadorOcultar);
  }

  function esconder() {
    if (barra) {
      barra.classList.remove("visible");
      barra.classList.remove("hover");
      if (texto) texto.textContent = textoGrimorio("arrastrarSoltar");
    }
  }

  // Detectar inicio de arrastre en cualquier parte de la ventana
  window.addEventListener("dragenter", (e) => {
    // Si contiene archivos o texto/enlaces
    if (e.dataTransfer && e.dataTransfer.types && e.dataTransfer.types.length > 0) {
      mostrar();
    }
  }, { passive: true });

  window.addEventListener("dragover", () => {
    clearTimeout(contadorOcultar);
    contadorOcultar = setTimeout(esconder, 2500);
  }, { passive: true });

  window.addEventListener("dragleave", (e) => {
    // Si sale de la ventana del navegador
    if (e.clientX <= 0 || e.clientY <= 0 || e.clientX >= window.innerWidth || e.clientY >= window.innerHeight) {
      esconder();
    }
  }, { passive: true });

  window.addEventListener("drop", () => {
    setTimeout(esconder, 100);
  }, { passive: true });

  window.addEventListener("dragend", () => {
    esconder();
  }, { passive: true });
})();
