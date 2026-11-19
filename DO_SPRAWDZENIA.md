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

## 2. 🔤 Zarządzanie Fontami (W trakcie realizacji)
- [ ] *[Do uzupełnienia po zakończeniu implementacji fontów]*

---

## 3. 📦 Nowe Formaty Mediów (W planach)
- [ ] *[Do uzupełnienia po dodaniu obsługi formatów biurowych i wektorowych]*
