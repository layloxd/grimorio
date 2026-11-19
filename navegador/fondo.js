// El fondo de la extensiÃ³n: el menÃº del clic derecho, captura, colector y el puente con Grimorio.
"use strict";

importScripts("aviso.js", "captura.js");

const PROGRAMA = "com.grimorio.puerta";
const TOPE_BYTES = 40 * 1024 * 1024;

let colectorUltimasImagenes = [];

// MenÃº contextual
chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.removeAll(() => {
    chrome.contextMenus.create({
      id: "guardar",
      title: textoGrimorio("menuGuardar"),
      contexts: ["image", "video", "link"],
    });
    chrome.contextMenus.create({
      id: "guardarPagina",
      title: textoGrimorio("menuGuardarMarcador"),
      contexts: ["page"],
    });
    chrome.contextMenus.create({
      id: "abrirColectorMenu",
      title: textoGrimorio("menuColector"),
      contexts: ["page"],
    });
  });
});

async function hablar(mensaje) {
  try {
    return await chrome.runtime.sendNativeMessage(PROGRAMA, mensaje);
  } catch (e) {
    const texto = String((e && e.message) || e);
    if (/not found|no se encontr/i.test(texto)) {
      return { ok: false, sinConectar: true, error: textoGrimorio("errorSinConectar") };
    }
    return { ok: false, error: texto };
  }
}

function base64(bytes) {
  let s = "";
  const paso = 0x8000;
  for (let i = 0; i < bytes.length; i += paso) {
    s += String.fromCharCode.apply(null, bytes.subarray(i, i + paso));
  }
  return btoa(s);
}

/// Guarda un elemento. Si ya vienen los datos en base64, los manda directamente.
async function guardarUno({ url, alternativas, origen, nombre, datos, tipo }, carpeta) {
  const pedido = { accion: "traer", origen: origen || "", nombre: nombre || "", carpeta: carpeta || "" };

  // Si ya tenemos los datos binarios en base64 (ej. capturas o Canvas)
  if (datos) {
    return hablar({ ...pedido, datos, tipo: tipo || "image/png" });
  }

  let grande = null;
  for (const u of [url, ...(alternativas || [])]) {
    try {
      const r = await fetch(u, { credentials: "include" });
      const t = (r.headers.get("content-type") || "").split(";")[0].trim().toLowerCase();
      const largo = Number(r.headers.get("content-length") || 0);
      if (!r.ok || !/^(image|video)\//.test(t)) continue;
      if (largo <= TOPE_BYTES) {
        const bytes = new Uint8Array(await r.arrayBuffer());
        if (bytes.length <= TOPE_BYTES) {
          return hablar({ ...pedido, datos: base64(bytes), tipo: t });
        }
      }
      grande = grande || u;
    } catch (_) {}
  }
  const direccion = grande || url;
  if (!/^https?:/.test(direccion)) return { ok: false, error: textoGrimorio("errorSinDireccion") };
  return hablar({ ...pedido, url: direccion });
}

async function carpetaElegida() {
  const { carpeta } = await chrome.storage.local.get("carpeta");
  return carpeta || "";
}

async function guardarLista(lista, carpetaEspecifica) {
  const carpeta = carpetaEspecifica !== undefined ? carpetaEspecifica : await carpetaElegida();
  const resultados = [];
  for (const p of lista) {
    const r = (await guardarUno(p, carpeta)) || { ok: false, error: textoGrimorio("errorSinRespuesta") };
    resultados.push({ ...r, nombre: r.nombre || p.nombre || "" });
  }
  await apuntar(resultados);
  return { ok: resultados.some((r) => r.ok), resultados };
}

async function apuntar(resultados) {
  const { ultimas = [] } = await chrome.storage.local.get("ultimas");
  const nuevas = resultados.map((r) => ({
    estado: r.ok ? r.estado || "guardada" : "error",
    nombre: r.nombre || "",
    error: r.ok ? "" : r.error || "",
    id: r.id || "",
    cuando: Date.now(),
  }));
  await chrome.storage.local.set({ ultimas: [...nuevas.reverse(), ...ultimas].slice(0, 10) });
}

async function avisarEn(tab, aviso) {
  try {
    await chrome.scripting.executeScript({ target: { tabId: tab.id }, files: ["aviso.js"] });
    await chrome.scripting.executeScript({
      target: { tabId: tab.id },
      func: (a) => avisoGrimorio(a),
      args: [aviso],
    });
  } catch (_) {}
}

async function marcar(tabId, bien) {
  await chrome.action.setBadgeBackgroundColor({ color: bien ? "#3b7d5a" : "#a33a3a", tabId });
  await chrome.action.setBadgeText({ text: bien ? "âœ“" : "!", tabId });
  setTimeout(() => chrome.action.setBadgeText({ text: "", tabId }), 3000);
}

const RE_CON_BOTON = /^https:\/\/(www\.(instagram|tiktok)\.com|boards\.4chan(nel)?\.org)\//;

async function alPulsarMenu(info, tab) {
  if (info.menuItemId === "abrirColectorMenu" && tab) {
    return ejecutarColectorEnPestana(tab);
  }

  if (info.menuItemId === "guardarPagina" && tab) {
    return ejecutarGuardarMarcador(tab);
  }

  if (tab && RE_CON_BOTON.test(info.pageUrl || tab.url || "")) {
    try {
      return await chrome.tabs.sendMessage(tab.id, { tipo: "guardarClicDerecho" }, { frameId: info.frameId || 0 });
    } catch (e) {
      return { ok: false, error: String(e.message || e) };
    }
  }

  if (tab) await avisarEn(tab, { estado: "en curso", titulo: textoGrimorio("avisoGuardando") });
  let r;
  if ((info.mediaType === "image" || info.mediaType === "video") && info.srcUrl) {
    r = await guardarLista([{ url: info.srcUrl, origen: info.pageUrl, nombre: tab && tab.title }]);
  } else {
    const url = info.linkUrl || info.pageUrl;
    const uno = await hablar({ accion: "traer", url, origen: url, carpeta: await carpetaElegida() });
    const resultados = [{ ...uno, nombre: uno.nombre || (tab && tab.title) || "" }];
    await apuntar(resultados);
    r = { ok: uno.ok, resultados };
  }
  if (tab) await avisarEn(tab, avisoDeResultado(r, 1));
  return r;
}

chrome.contextMenus.onClicked.addListener(async (info, tab) => {
  const r = await alPulsarMenu(info, tab);
  if (r && tab) await marcar(tab.id, r.ok);
});

// LÃ³gica de acciones complejas
async function ejecutarColectorEnPestana(tab) {
  try {
    await chrome.scripting.executeScript({ target: { tabId: tab.id }, files: ["colector.js"] });
    chrome.windows.create({
      url: "colector-panel.html",
      type: "popup",
      width: 880,
      height: 660,
    });
    return { ok: true };
  } catch (e) {
    return { ok: false, error: String(e.message || e) };
  }
}

async function ejecutarGuardarMarcador(tab) {
  if (tab) await avisarEn(tab, { estado: "en curso", titulo: textoGrimorio("avisoGuardando") });
  const capt = await capturarAreaVisible(tab);
  if (!capt.ok) {
    if (tab) await avisarEn(tab, { estado: "error", titulo: textoGrimorio("avisoNoGuardado"), detalle: capt.error });
    return capt;
  }
  const r = await guardarLista([{
    url: tab.url,
    origen: tab.url,
    nombre: tab.title || "Bookmark",
    datos: capt.datos,
    tipo: "image/png"
  }]);
  if (tab) await avisarEn(tab, avisoDeResultado(r, 1));
  return r;
}

async function ejecutarCapturaCompleta(tab) {
  if (tab) await avisarEn(tab, { estado: "en curso", titulo: textoGrimorio("avisoCapturandoPagina") });
  const capt = await capturarPaginaCompleta(tab);
  if (!capt.ok) {
    if (tab) await avisarEn(tab, { estado: "error", titulo: textoGrimorio("avisoNoGuardado"), detalle: capt.error });
    return capt;
  }
  const r = await guardarLista([capt]);
  if (tab) await avisarEn(tab, avisoDeResultado(r, 1));
  return r;
}

// Oyente de mensajes
chrome.runtime.onMessage.addListener((m, de, responder) => {
  if (m.tipo === "mostrar") {
    hablar({ accion: "mostrar", id: m.id }).then(responder);
    return true;
  }
  if (m.tipo === "guardar") {
    guardarLista(m.lista).then(responder);
    return true;
  }
  if (m.tipo === "guardarLoteConCarpeta") {
    guardarLista(m.lista, m.carpeta).then(responder);
    return true;
  }
  if (m.tipo === "colectorResultados") {
    colectorUltimasImagenes = m.imagenes || [];
    responder({ ok: true });
    return true;
  }
  if (m.tipo === "obtenerResultadosColector") {
    responder({ ok: true, imagenes: colectorUltimasImagenes });
    return true;
  }
  if (m.tipo === "abrirColector") {
    (async () => {
      const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
      if (tab) {
        const r = await ejecutarColectorEnPestana(tab);
        responder(r);
      } else {
        responder({ ok: false, error: "No active tab" });
      }
    })();
    return true;
  }
  if (m.tipo === "capturarPagina") {
    (async () => {
      const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
      if (tab) {
        const r = await ejecutarCapturaCompleta(tab);
        responder(r);
      } else {
        responder({ ok: false, error: "No active tab" });
      }
    })();
    return true;
  }
  if (m.tipo === "capturarVisible") {
    (async () => {
      const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
      if (tab) {
        if (tab) await avisarEn(tab, { estado: "en curso", titulo: textoGrimorio("avisoGuardando") });
        const capt = await capturarAreaVisible(tab);
        const r = capt.ok ? await guardarLista([capt]) : capt;
        if (tab) await avisarEn(tab, avisoDeResultado(r, 1));
        responder(r);
      } else {
        responder({ ok: false, error: "No active tab" });
      }
    })();
    return true;
  }
  if (m.tipo === "guardarMarcador") {
    (async () => {
      const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
      if (tab) {
        const r = await ejecutarGuardarMarcador(tab);
        responder(r);
      } else {
        responder({ ok: false, error: "No active tab" });
      }
    })();
    return true;
  }
  if (m.tipo === "cargadas" && de.tab) {
    chrome.scripting.executeScript({
      target: { tabId: de.tab.id, frameIds: [de.frameId || 0] },
      world: "MAIN",
      func: () => performance.getEntriesByType("resource")
        .filter((e) => e.initiatorType === "img")
        .map((e) => ({ name: e.name, decodedBodySize: e.decodedBodySize, encodedBodySize: e.encodedBodySize })),
    }).then((r) => responder({ entradas: (r && r[0] && r[0].result) || [] }),
            () => responder({ entradas: [] }));
    return true;
  }
  if (m.tipo === "estado") {
    (async () => {
      const hola = await hablar({ accion: "hola" });
      const carpetas = hola.ok ? await hablar({ accion: "carpetas" }) : { carpetas: [] };
      responder({ hola, carpetas: carpetas.carpetas || [], carpeta: await carpetaElegida() });
    })();
    return true;
  }
  return false;
});
