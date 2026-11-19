# 🧪 Lista Rzeczy do Przetestowania (QA Checklist)

Lista kontrolna funkcjonalności do ręcznego przetestowania w wolnej chwili przez Ciebie.

---

## 1. 🌐 Rozszerzenie Przeglądarki (Browser Extension)

### 📌 Krok 0: Załadowanie w przeglądarce
- [ ] Otwórz `chrome://extensions` lub `brave://extensions` lub `edge://extensions`.
- [ ] Włącz **Tryb programisty (Developer mode)**.
- [ ] Kliknij **Załaduj rozpakowane (Load unpacked)** i wskaż folder `navegador` (`C:\Users\skyle\Desktop\grimorio-temp\navegador`).
- [ ] Sprawdź czy rozszerzenie ma zielony status i identyfikator `nhmdhkmjpnpclpiopkajinahdcmacfko`.
- [ ] Sprawdź czy po kliknięciu w ikonkę w pasku rozszerzeń pojawia się napis **"Conectado a «Grimorio»"** (aplikacja Grimorio musi być uruchomiona).

### 🔍 Test 1: Image Sniffer (Kolektor grafik)
- [ ] Wejdź na stronę bogatą w grafiki (np. ArtStation, Pinterest, Unsplash, blog z wieloma obrazami).
- [ ] Otwórz popup rozszerzenia i kliknij **"Sniff Images"** (lub kliknij prawym przyciskiem myszy na stronę → *"Escanear imágenes de esta página"*).
- [ ] Upewnij się, że otworzyło się okno z siatką miniatur wszystkich grafik ze strony.
- [ ] Przetestuj suwak **Min W / Min H** (czy odsiewa małe ikonki).
- [ ] Przetestuj filtry formatów (np. kliknij **WEBP**, **PNG**, **JPG**).
- [ ] Wyszukaj fragment URL/alt w polu szukajki.
- [ ] Wybierz folder docelowy z listy.
- [ ] Kliknij **"Save Selected"** i upewnij się, że wybrane grafiki natychmiast pojawiają się w otwartym oknie Grimorio!

### 📸 Test 2: Full-Page Screenshot (Zrzut całej długiej strony)
- [ ] Wejdź na długą, przewijaną stronę (np. długi artykuł Wikipedii lub serwis informacyjny).
- [ ] W popupie kliknij **"Full Page"**.
- [ ] Sprawdź, czy strona płynnie przewinęła się w dół, a w prawym dolnym rogu pojawił się dymek informujący o zapisaniu.
- [ ] Otwórz Grimorio i sprawdź, czy zrzut został zapisany jako jeden wysoki, bezstratny plik PNG.

### 📷 Test 3: Screen Area Screenshot (Zrzut widocznego obszaru)
- [ ] W popupie rozszerzenia kliknij **"Screen Area"**.
- [ ] Sprawdź, czy uchwycona została dokładnie widoczna część ekranu.

### 🧲 Test 4: Universal Drag & Drop (Pływająca strefa zrzutu)
- [ ] Na dowolnej stronie chwyć myszką dowolne zdjęcie i zacznij je przeciągać.
- [ ] Sprawdź, czy u dołu ekranu płynnie wysuwa się ciemny pasek *"Drop here to save to Grimorio"*.
- [ ] Najedź przeciąganym obrazem na ten pasek (powinien podświetlić się na zielono: *"Release to save"*).
- [ ] Upuść obrazek — sprawdź, czy pojawił się dymek sukcesu i plik trafił do Grimorio.

### 🔖 Test 5: Zapisywanie zakładek (Save Page)
- [ ] Kliknij prawym przyciskiem myszy na pustym tle strony → *"Guardar página en Grimorio"* (lub *"Save Page"* w popupie).
- [ ] Sprawdź, czy strona została zapisana z miniaturą strony i adresem URL jako źródłem.

---

## 2. 🔤 Zarządzanie Fontami (Font Management)

### 📌 Krok 0: Przygotowanie pliku fontu
- [ ] Przygotuj dowolny plik fontu (np. `.ttf`, `.otf` lub `.woff` pobrany np. z Google Fonts).
- [ ] Przeciągnij plik fontu do okna aplikacji Grimorio.

### 🔍 Test 1: Wykrywanie i miniatura w siatce
- [ ] Sprawdź, czy kafelek pliku w siatce ma odpowiednią odznakę (np. `TTF` / `OTF`).
- [ ] Zaznacz font pojedynczym kliknięciem:
  - Sprawdź, czy w prawym panelu (Inspektor) pojawił się przycisk **"activar en Windows"** z ikonką fontu.

### 🖥️ Test 2: Dedykowany podgląd (Visor)
- [ ] Naciśnij `Enter` (lub kliknij dwukrotnie), aby otworzyć font w pełnoekranowym podglądzie:
  - [ ] **Tryb "Texto":** Wpisz własny tekst (np. *"Zażółć gęślą jaźń 123"*), zmień suwakiem rozmiar czcionki (px) i upewnij się, że tekst renderuje się płynnie w wektorowej jakości.
  - [ ] **Tryb "Cascada":** Przełącz widok na kaskadę i zobacz podgląd tekstu w zróżnicowanych wielkościach (od 16px do 96px).
  - [ ] **Tryb "Glifos":** Przełącz na glify i sprawdź siatkę znaków alfabetu, cyfr i symboli z kodami Unicode `U+XXXX`.

### ⚡ Test 3: Aktywacja czcionki w locie w Windows (Eagle-killer)
- [ ] W podglądzie fontu lub w Inspektorze kliknij **"Activar en Windows"**.
- [ ] Przycisk powinien podświetlić się na aktywny (**"Activa en sistema"** z zielonym akcentem).
- [ ] Otwórz dowolny zewnętrzny program (np. Notatnik / MS Word / Photoshop / Illustrator / Figma).
- [ ] Rozwiń listę czcionek w tym programie — powinieneś zobaczyć nowo aktywowaną czcionkę i móc nią pisać!
- [ ] Wróć do Grimorio i kliknij przycisk ponownie, aby ją dezaktywować. Czcionka zostaje bezpiecznie usunięta z sesji Windows bez restartowania systemu i bez instalowania śmieci w `C:\Windows\Fonts`.

---

## 3. 📦 Rozszerzona Obsługa Formatów Mediów (Media Formats Expansion)

### 📄 Test 1: Pliki Markdown i Tekstowe (.md, .txt, .json, .log)
- [ ] Przygotuj lub przeciągnij plik `.md` (Markdown), `.txt` lub `.json` do Grimorio.
- [ ] Sprawdź, czy w siatce pojawiła się wygenerowana karta dokumentu z odpowiednią kolorową odznaką (`MD` fioletowa, `TXT` grafitowa, `JSON` złota) i tytułem dokumentu.
- [ ] Otwórz plik klawiszem `Enter` lub dwuklikiem:
  - [ ] **Dla plików `.md`:** Sprawdź czy tekst wyświetla się w trybie sformatowanym (nagłówki `#`, pogrubienia `**`, listy, linki).
  - [ ] Kliknij przycisk **"ver código fuente"** / **"ver renderizado"**, aby przełączać między podglądem sformatowanym a surowym kodem.
  - [ ] Sprawdź przyciski powiększania/pomniejszania tekstu (**`+`** / **`-`**).
  - [ ] Sprawdź licznik linii i znaków na górnym pasku.
  - [ ] Kliknij ikonę kopiowania — zawartość tekstu powinna trafić do schowka z powiadomieniem.
  - [ ] Kliknij **"abrir en el editor"** — plik powinien otworzyć się w domyślnym edytorze systemowym (np. VS Code, Notepad).

### 📊 Test 2: Dokumenty Biurowe i E-booki (.docx, .pptx, .xlsx, .epub, .odt)
- [ ] Przeciągnij plik `.docx` (Word), `.pptx` (PowerPoint), `.xlsx` (Excel) lub `.epub` (książka/komiks):
  - [ ] Jeśli plik posiada wbudowaną miniaturę (standard MS Office / LibreOffice / okładka EPUB), upewnij się, że miniatura została natychmiast wyodrębniona.
  - [ ] Jeśli plik nie ma miniatury, sprawdź czy wygenerowała się estetyczna karta z odznaką formatu (`DOCX` niebieska, `PPTX` pomarańczowa, `XLSX` zielona, `EPUB` bursztynowa) i tytułem.
- [ ] Otwórz plik w podglądzie (`Visor`):
  - [ ] Sprawdź wycentrowany podgląd okładki/strony/karty w wysokiej rozdzielczości.
  - [ ] Sprawdź pasek informacyjny z nazwą i wagą pliku.
  - [ ] Kliknij **"abrir en programa predeterminado"** — dokument powinien natychmiast otworzyć się w powiązanym programie (Word, PowerPoint, Excel, czytnik ebooków).

### 🎨 Test 3: Formaty Projektowe (.fig, .xd, .sketch, .afdesign)
- [ ] Zaimportuj plik exportu z Figmy (`.fig`), Adobe XD (`.xd`) lub Sketch (`.sketch`).
- [ ] Sprawdź, czy Grimorio wyciąga wbudowany podgląd z pliku ZIP i prezentuje go w siatce oraz w pełnym powiększeniu.

### 🌅 Test 4: Mapy Środowiskowe HDRI / EXR (.hdr, .exr)
- [ ] Zaimportuj grafikę HDR lub plik OpenEXR (`.hdr`, `.exr` np. darmowa mapa HDRI z Poly Haven).
- [ ] Sprawdź czy plik ładuje się natychmiast bez żadnych błędów, generując miniaturę, obliczając paletę Oklab i pozwalając na pełnoekranowy zoom pikselowy w `VisorImagen`.
