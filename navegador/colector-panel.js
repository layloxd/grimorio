// Panel del colector de imÃ¡genes (Image Sniffer).
// Permite previsualizar, filtrar y guardar mÃºltiples imÃ¡genes en lote.
"use strict";

let todasImagenes = [];
let seleccionadas = new Set();
let filtroTipo = "all";
let filtroMinW = 100;
let filtroMinH = 100;
let filtroBusqueda = "";

// Elementos DOM
const totalCount = document.getElementById("totalCount");
const minWidth = document.getElementById("minWidth");
const minWidthVal = document.getElementById("minWidthVal");
const minHeight = document.getElementById("minHeight");
const minHeightVal = document.getElementById("minHeightVal");
const searchInput = document.getElementById("searchInput");
const folderSelect = document.getElementById("folderSelect");
const btnSelectAll = document.getElementById("btnSelectAll");
const btnDeselectAll = document.getElementById("btnDeselectAll");
const btnSave = document.getElementById("btnSave");
const imageGrid = document.getElementById("imageGrid");
const emptyState = document.getElementById("emptyState");
const selectionSummary = document.getElementById("selectionSummary");
const statusMessage = document.getElementById("statusMessage");
const typeChips = document.querySelectorAll(".chip");

// Formatear bytes
function formatoBytes(b) {
  if (!b || b <= 0) return "";
  if (b < 1024) return b + " B";
  if (b < 1024 * 1024) return Math.round(b / 1024) + " KB";
  return (b / (1024 * 1024)).toFixed(1) + " MB";
}

// Actualizar contadores y botÃ³n de guardado
function actualizarResumen() {
  const visibles = obtenerVisibles();
  const selEnVisibles = visibles.filter(img => seleccionadas.has(img.url)).length;
  totalCount.textContent = `${visibles.length} / ${todasImagenes.length}`;
  selectionSummary.textContent = `${seleccionadas.size} selected`;
  btnSave.disabled = seleccionadas.size === 0;
  btnSave.textContent = `Save Selected (${seleccionadas.size})`;
}

// Filtrado de imÃ¡genes
function cumpleFiltros(img) {
  if (filtroTipo !== "all" && img.type !== filtroTipo) return false;
  // Si tiene dimensiones detectadas, aplicar filtros
  if (img.width > 0 && img.width < filtroMinW) return false;
  if (img.height > 0 && img.height < filtroMinH) return false;
  if (filtroBusqueda) {
    const texto = (img.url + " " + (img.alt || "")).toLowerCase();
    if (!texto.includes(filtroBusqueda)) return false;
  }
  return true;
}

function obtenerVisibles() {
  return todasImagenes.filter(cumpleFiltros);
}

// Renderizar cuadrÃ­cula
function renderizar() {
  imageGrid.innerHTML = "";
  const visibles = obtenerVisibles();

  if (visibles.length === 0) {
    emptyState.hidden = false;
    actualizarResumen();
    return;
  }
  emptyState.hidden = true;

  const fragmento = document.createDocumentFragment();

  visibles.forEach(img => {
    const card = document.createElement("div");
    card.className = "card" + (seleccionadas.has(img.url) ? " selected" : "");
    card.title = img.url;

    // Miniatura
    const thumbContainer = document.createElement("div");
    thumbContainer.className = "thumbnail-container";

    const imageEl = document.createElement("img");
    imageEl.loading = "lazy";
    imageEl.src = img.url;
    imageEl.alt = img.alt || "";

    // Actualizar dimensiones reales si antes no estaban disponibles
    imageEl.addEventListener("load", () => {
      if (!img.width || !img.height) {
        img.width = imageEl.naturalWidth;
        img.height = imageEl.naturalHeight;
        dimSpan.textContent = `${img.width}Ã—${img.height}`;
      }
    });

    const checkbox = document.createElement("div");
    checkbox.className = "checkbox-overlay";
    checkbox.textContent = "âœ“";

    thumbContainer.append(imageEl, checkbox);

    // Metadatos inferiores
    const meta = document.createElement("div");
    meta.className = "card-meta";

    const dimSpan = document.createElement("span");
    dimSpan.textContent = img.width && img.height ? `${img.width}Ã—${img.height}` : "Ã—";

    const typeBadge = document.createElement("span");
    typeBadge.className = "badge";
    typeBadge.textContent = img.type || "IMG";

    meta.append(dimSpan, typeBadge);

    if (img.size > 0) {
      const sizeSpan = document.createElement("span");
      sizeSpan.textContent = formatoBytes(img.size);
      meta.append(sizeSpan);
    }

    card.append(thumbContainer, meta);

    // Evento de selecciÃ³n al hacer clic
    card.addEventListener("click", () => {
      if (seleccionadas.has(img.url)) {
        seleccionadas.delete(img.url);
        card.classList.remove("selected");
      } else {
        seleccionadas.add(img.url);
        card.classList.add("selected");
      }
      actualizarResumen();
    });

    fragmento.appendChild(card);
  });

  imageGrid.appendChild(fragmento);
  actualizarResumen();
}

// Cargar carpetas de Grimorio
async function cargarCarpetas() {
  try {
    const r = await chrome.runtime.sendMessage({ tipo: "estado" });
    if (r && r.carpetas) {
      folderSelect.innerHTML = '<option value="">(All Library)</option>';
      for (const c of r.carpetas) {
        folderSelect.add(new Option("  ".repeat(c.nivel || 0) + c.nombre, c.id));
      }
      if (r.carpeta) folderSelect.value = r.carpeta;
    }
  } catch (_) {}
}

// Event Listeners para filtros
minWidth.addEventListener("input", (e) => {
  filtroMinW = Number(e.target.value);
  minWidthVal.textContent = filtroMinW;
  renderizar();
});

minHeight.addEventListener("input", (e) => {
  filtroMinH = Number(e.target.value);
  minHeightVal.textContent = filtroMinH;
  renderizar();
});

let searchTimeout = null;
searchInput.addEventListener("input", (e) => {
  clearTimeout(searchTimeout);
  searchTimeout = setTimeout(() => {
    filtroBusqueda = e.target.value.trim().toLowerCase();
    renderizar();
  }, 200);
});

typeChips.forEach(chip => {
  chip.addEventListener("click", () => {
    typeChips.forEach(c => c.classList.remove("active"));
    chip.classList.add("active");
    filtroTipo = chip.dataset.type;
    renderizar();
  });
});

btnSelectAll.addEventListener("click", () => {
  const visibles = obtenerVisibles();
  visibles.forEach(img => seleccionadas.add(img.url));
  renderizar();
});

btnDeselectAll.addEventListener("click", () => {
  seleccionadas.clear();
  renderizar();
});

// Guardar seleccionadas
btnSave.addEventListener("click", async () => {
  if (seleccionadas.size === 0) return;

  const listaAGuardar = todasImagenes
    .filter(img => seleccionadas.has(img.url))
    .map(img => ({
      url: img.url,
      origen: img.pageUrl || "",
      nombre: img.alt || document.title || ""
    }));

  btnSave.disabled = true;
  statusMessage.textContent = `Saving ${listaAGuardar.length} items to Grimorio...`;

  try {
    const carpeta = folderSelect.value;
    const r = await chrome.runtime.sendMessage({
      tipo: "guardarLoteConCarpeta",
      lista: listaAGuardar,
      carpeta
    });

    if (r && r.ok) {
      statusMessage.textContent = `Successfully saved ${listaAGuardar.length} items!`;
      setTimeout(() => window.close(), 1200);
    } else {
      statusMessage.textContent = `Saved with errors: ${(r && r.error) || "Check Grimorio"}`;
      btnSave.disabled = false;
    }
  } catch (err) {
    statusMessage.textContent = `Error: ${err.message}`;
    btnSave.disabled = false;
  }
});

// InicializaciÃ³n
(async () => {
  statusMessage.textContent = "Loading images from active tab...";
  await cargarCarpetas();

  // Pedir resultados al fondo
  const res = await chrome.runtime.sendMessage({ tipo: "obtenerResultadosColector" });
  if (res && res.imagenes) {
    todasImagenes = res.imagenes;
    // Preseleccionar por defecto imÃ¡genes con tamaÃ±o adecuado
    todasImagenes.forEach(img => {
      if (cumpleFiltros(img)) seleccionadas.add(img.url);
    });
    statusMessage.textContent = `Found ${todasImagenes.length} images on page.`;
    renderizar();
  } else {
    statusMessage.textContent = "No images received.";
  }
})();
