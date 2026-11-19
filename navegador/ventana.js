// La ventanita del botÃ³n de la extensiÃ³n: si Grimorio estÃ¡, y dÃ³nde guardar.
"use strict";

const t = (clave, ...huecos) => chrome.i18n.getMessage(clave, huecos.map(String)) || clave;

document.documentElement.lang = t("idioma");
for (const el of document.querySelectorAll("[data-texto]")) {
  el.textContent = t(el.dataset.texto);
}

function haceCuanto(ms) {
  const s = Math.max(0, (Date.now() - ms) / 1000);
  if (s < 60) return t("haceAhora");
  if (s < 3600) return t("haceMinutos", Math.floor(s / 60));
  if (s < 86400) return t("haceHoras", Math.floor(s / 3600));
  return t("haceDias", Math.floor(s / 86400));
}

async function pintarUltimas() {
  const { ultimas = [] } = await chrome.storage.local.get("ultimas");
  if (ultimas.length === 0) return;
  document.getElementById("ultimas").hidden = false;
  const lista = document.getElementById("lista");
  const MARCA = { guardada: "âœ“", repetida: "â— ", error: "âœ•", "en camino": "â—Œ" };
  const TEXTO = { guardada: t("ultimaGuardada"), repetida: t("ultimaRepetida"), error: t("ultimaError"),
                  "en camino": t("ultimaEnCamino") };
  lista.innerHTML = "";
  for (const u of ultimas) {
    const fila = document.createElement("div");
    fila.className = "ultima " + (u.estado === "en camino" ? "camino" : u.estado);
    fila.title = u.estado === "error" ? u.error : TEXTO[u.estado] || "";
    const marca = document.createElement("span");
    marca.className = "marca";
    marca.textContent = MARCA[u.estado] || "Â·";
    const nombre = document.createElement("span");
    nombre.className = "nombre";
    nombre.textContent = u.nombre || TEXTO[u.estado] || "";
    const cuando = document.createElement("span");
    cuando.className = "cuando";
    cuando.textContent = haceCuanto(u.cuando);
    fila.append(marca, nombre, cuando);
    if (u.id) {
      fila.dataset.id = u.id;
      fila.addEventListener("click", () => {
        chrome.runtime.sendMessage({ tipo: "mostrar", id: u.id });
        window.close();
      });
    }
    lista.append(fila);
  }
}

// Botones de acciÃ³n rÃ¡pida
document.getElementById("btnColector").addEventListener("click", () => {
  chrome.runtime.sendMessage({ tipo: "abrirColector" });
  window.close();
});

document.getElementById("btnCapturaPagina").addEventListener("click", () => {
  chrome.runtime.sendMessage({ tipo: "capturarPagina" });
  window.close();
});

document.getElementById("btnCapturaVisible").addEventListener("click", () => {
  chrome.runtime.sendMessage({ tipo: "capturarVisible" });
  window.close();
});

document.getElementById("btnMarcador").addEventListener("click", () => {
  chrome.runtime.sendMessage({ tipo: "guardarMarcador" });
  window.close();
});

(async () => {
  pintarUltimas();
  const estado = document.getElementById("estado");
  const destino = document.getElementById("destino");
  const select = document.getElementById("carpeta");
  const r = await chrome.runtime.sendMessage({ tipo: "estado" });

  if (!r || !r.hola.ok) {
    estado.classList.add("mal");
    if (r && r.hola.sinConectar) {
      const orden = document.createElement("code");
      orden.textContent = "grim navegador instalar";
      estado.replaceChildren(t("ventanaSinConectar") + " ", orden);
    } else if (r && r.hola.cerrada) {
      estado.textContent = t("ventanaCerrada");
    } else {
      estado.textContent = (r && r.hola.error) || t("ventanaSinRespuesta");
    }
    return;
  }

  estado.textContent = t("ventanaConectado", r.hola.biblioteca);
  destino.hidden = false;
  const sinCarpeta = new Option(t("ventanaSinCarpeta"), "");
  select.add(sinCarpeta);
  for (const c of r.carpetas) {
    select.add(new Option("  ".repeat(c.nivel || 0) + c.nombre, c.id));
  }
  select.value = r.carpetas.some((c) => c.id === r.carpeta) ? r.carpeta : "";
  select.addEventListener("change", () => chrome.storage.local.set({ carpeta: select.value }));
})();
