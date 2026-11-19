# Roadmap & TODO — Własna alternatywa dla Eagle.cool

Ten dokument definiuje plan rozwoju i priorytety dla naszej wersji **Grimorio** dostosowanej jako prywatna, bezkompromisowa alternatywa dla **Eagle.cool**.

---

## 🚀 Priorytet: Do zrobienia w pierwszej kolejności (Core Features)

### 1. Rozszerzenie do przeglądarki (Browser Extension) — ✅ ZROBIONE
* **Batch Image Collector / Sniffer:**
  * Przycisk otwierający siatkę wszystkich zasobów graficznych z bieżącej karty.
  * Filtrowanie według minimalnej rozdzielczości (ukrywanie drobnych ikonek/avatarek), formatu (PNG, JPG, SVG, WebP).
  * Wybór zaznaczonych elementów lub "Zaznacz wszystko" i bezpośredni zapis do wskazanego folderu w aplikacji.
* **Zrzuty ekranu:**
  * Zrzut całej przewijanej strony (Full-Page Scrolling Screenshot) scalany do jednego pliku.
  * Zrzut zaznaczonego obszaru strony.
* **Przeciągnij i upuść (Drag & Drop):**
  * Możliwość przeciągania obrazu bezpośrednio z przeglądarki do okna aplikacji.
* **Zapisywanie zakładek (Web Bookmarks):**
  * Zapisywanie linku z wygenerowaną miniaturą i zapisanym adresem URL.

---

### 2. Zarządzanie Fontami (Font Management) — ✅ ZROBIONE
* **Obsługa formatów:** TTF, OTF, WOFF, WOFF2, TTC.
* **Aktywacja / Dezaktywacja w systemie w locie:**
  * Rejestracja czcionki w Windows (`AddFontResourceEx` / GDI/DirectWrite) bez instalowania jej na stałe w `C:\Windows\Fonts`.
  * Dostępność aktywnego fontu od razu w Photoshopie, Illustratorze, Figmie itp.
* **Interaktywny podgląd fontu:**
  * Wpisywanie własnego tekstu podglądu (pangramy).
  * Skalowanie rozmiaru tekstu w czasie rzeczywistym.
  * Przegląd pełnej tablicy glifów i znaków specjalnych.

---

### 3. Rozszerzenie obsługi formatów mediów — ✅ ZROBIONE
* **Dokumenty biurowe i tekstowe:**
  * Podgląd dokumentów Office (DOCX, PPTX, XLSX, EPUB, ODT) oraz czytnik plików Markdown / Text / JSON / Log z podglądem sformatowanym, powiększaniem, statystykami i kopiowaniem.
* **Formaty projektowe i graficzne:**
  * Podgląd plików `.fig` (Figma export), Adobe XD (`.xd`), Sketch (`.sketch`), Affinity Suite (`.afdesign`, `.afphoto`).
* **Formaty 3D i mapy środowiskowe:**
  * Bezpośrednia obsługa i dekodowanie w Rust plików HDR / EXR (mapy HDRI) z miniaturami, paletami Oklab i zoomem pikselowym.

---

## ⏳ Potencjalne funkcje na przyszłość (Backlog)

* **Adnotacje przestrzenne i znaczniki czasu:**
  * Pinezki i komentarze na wybranym fragmencie obrazu (Pin notes z koordynatami x, y).
  * Znaczniki z notatkami na osi czasu wideo/audio (klikalny timestamp przenoszący odtwarzacz).
* **Zaawansowana paleta kolorów i próbnik:**
  * Ekstrakcja 5–8 dominujących kolorów z wartościami HEX w panelu inspektora.
  * Klikalne chipy kolorów do kopiowania HEX i suwak tolerancji koloru.
* **Porównywarka grafik (Side-by-side / Split slider):**
  * Zaznaczenie 2–4 grafik i jednoczesny podgląd ze zsynchronizowanym zoomem i przesuwaniem.
  * Tryb suwaka kurtynowego ("przed/po").
* **Masowe przetwarzanie i konwersja (Batch Operations):**
  * Masowa transkodacja formatów (np. WebP/HEIC/AVIF → PNG/JPG).
  * Masowa bezstratna/stratna kompresja grafik.
  * Usuwanie metadanych EXIF przed eksportem.
* **OCR (Wyszukiwanie tekstu w grafikach):**
  * Lokalny silnik OCR indeksujący tekst ze zrzutów ekranu do wyszukiwarki.
* **Lokalny REST API / Wtyczki:**
  * Serwer HTTP w aplikacji (`localhost`) do bezpośredniej integracji ze skryptami zewnętrznymi, wtyczkami do Figmy czy Blendera.

---

## ❌ Odrzucone z projektu (Niepotrzebne)

* **Inteligentne Foldery (Smart Folders):** Standardowe foldery i wyszukiwarka w zupełności wystarczają.
* **Metadane AI (Prompt extraction):** Parsowanie parametrów Stable Diffusion / Midjourney / ComfyUI pomijamy.
* **Ochrona hasłem / Szyfrowanie folderów (Vault):** Aplikacja na własny użytek na zabezpieczonym komputerze, brak potrzeby blokowania folderów kodem PIN.
