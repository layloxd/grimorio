// Rastreador de imágenes de la página: recoge todas las que haya y las manda
// al fondo para que el panel las enseñe. Se inyecta bajo demanda con
// chrome.scripting.executeScript.
"use strict";

(() => {
  const urlPagina = location.href;
  const vistas = new Set();
  const imagenes = [];

  /// La extensión del archivo en la URL, sin la interrogación ni almohadilla.
  function extensionDeUrl(url) {
    try {
      const ruta = new URL(url).pathname;
      const punto = ruta.lastIndexOf(".");
      if (punto < 0) return "";
      const ext = ruta.slice(punto + 1).toLowerCase();
      // Extensiones habituales; lo demás es ruido (hashes, ids).
      return /^(jpe?g|png|gif|webp|avif|svg|bmp|ico|tiff?)$/.test(ext) ? ext : "";
    } catch (_) {
      return "";
    }
  }

  /// Normaliza la extensión a un tipo legible.
  function tipoDeExtension(ext) {
    if (!ext) return "other";
    if (/^jpe?g$/.test(ext)) return "jpg";
    if (ext === "png") return "png";
    if (ext === "gif") return "gif";
    if (ext === "webp") return "webp";
    if (ext === "svg") return "svg";
    if (ext === "avif") return "avif";
    return "other";
  }

  /// Tamaño estimado del recurso según performance.getEntriesByType.
  function tamanoPorUrl(url) {
    try {
      for (const e of performance.getEntriesByType("resource")) {
        if (e.name === url) {
          const peso = e.decodedBodySize || e.encodedBodySize || e.transferSize || 0;
          if (peso > 0) return peso;
        }
      }
    } catch (_) { /* sin acceso al rendimiento */ }
    return 0;
  }

  /// La dirección de mayor anchura de un srcset.
  function mejorDeSrcset(srcset) {
    if (!srcset) return null;
    let mejor = null;
    let ancho = -1;
    for (const trozo of srcset.split(/,\s+(?=\S)/)) {
      const partes = trozo.trim().split(/\s+/);
      const url = partes[0];
      if (!url) continue;
      const d = partes[1] || "1x";
      const n = d.endsWith("w") ? parseFloat(d) : d.endsWith("x") ? parseFloat(d) * 1000 : 0;
      if (n > ancho) {
        ancho = n;
        mejor = url;
      }
    }
    return mejor;
  }

  /// Resuelve una URL relativa contra la página.
  function resolver(url) {
    if (!url) return null;
    try {
      return new URL(url, urlPagina).href;
    } catch (_) {
      return null;
    }
  }

  /// Añade una imagen si no está repetida.
  function anadir(url, ancho, alto, alt) {
    url = resolver(url);
    if (!url || vistas.has(url)) return;
    // Solo http(s); datos en base64 y blobs se descartan.
    if (!/^https?:/.test(url)) return;
    vistas.add(url);
    const ext = extensionDeUrl(url);
    imagenes.push({
      url,
      width: ancho || 0,
      height: alto || 0,
      type: tipoDeExtension(ext),
      size: tamanoPorUrl(url),
      alt: (alt || "").slice(0, 200),
      pageUrl: urlPagina,
    });
  }

  // --- <img> ---
  for (const img of document.querySelectorAll("img")) {
    const srcset = img.getAttribute("srcset");
    const mejor = mejorDeSrcset(srcset);
    const url = mejor || img.currentSrc || img.src;
    anadir(url, img.naturalWidth, img.naturalHeight, img.alt);
    // Si el srcset daba algo distinto, también la src normal.
    if (mejor && img.src && mejor !== img.src) {
      anadir(img.src, img.naturalWidth, img.naturalHeight, img.alt);
    }
  }

  // --- <picture><source> ---
  for (const source of document.querySelectorAll("picture source")) {
    const srcset = source.getAttribute("srcset");
    const mejor = mejorDeSrcset(srcset);
    if (mejor) anadir(mejor, 0, 0, "");
    if (source.src) anadir(source.src, 0, 0, "");
  }

  // --- <video> poster y <source> ---
  for (const video of document.querySelectorAll("video")) {
    if (video.poster) anadir(video.poster, video.videoWidth, video.videoHeight, "");
    for (const source of video.querySelectorAll("source")) {
      // Solo imágenes; los vídeos no nos interesan aquí.
    }
  }

  // --- CSS background-image en elementos visibles ---
  const todos = document.querySelectorAll("*");
  for (const el of todos) {
    // Solo los que tengan tamaño; saltar los invisibles.
    const r = el.getBoundingClientRect();
    if (r.width < 10 || r.height < 10) continue;
    try {
      const bg = getComputedStyle(el).backgroundImage;
      if (!bg || bg === "none") continue;
      // Puede haber varias: background-image: url(...), url(...)
      const coincidencias = bg.matchAll(/url\(["']?([^"')]+)["']?\)/g);
      for (const m of coincidencias) {
        anadir(m[1], Math.round(r.width), Math.round(r.height), "");
      }
    } catch (_) { /* elementos que dan error al leer su estilo */ }
  }

  // Mandar los resultados al fondo.
  chrome.runtime.sendMessage({ tipo: "colectorResultados", imagenes });
})();
