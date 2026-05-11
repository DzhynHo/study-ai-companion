# Study AI Companion

Aplikacja Flutter do nauki z pomocą AI, która pozwala studentowi wrzucać materiały dydaktyczne i „rozmawiać” z ich treścią.

## Opis

**Study AI Companion** to aplikacja mobilna/webowa stworzona w Flutterze, która pomaga w nauce na podstawie własnych materiałów:
- PDF-ów,
- zdjęć notatek,
- własnych plików źródłowych z zajęć.

Aplikacja wykorzystuje modele AI do:
- zadawania pytań o treść materiałów,
- generowania fiszek,
- tworzenia quizów,
- prowadzenia trybu odpytywania.

## Funkcje

- Upload PDF.
- Upload zdjęć notatek.
- Chat z AI, które zna treść materiałów.
- Uproszczony RAG na bazie załadowanych dokumentów.
- Generowanie fiszek z materiałów.
- Generowanie quizów.
- Historia rozmów per przedmiot.
- Tryb „odpytywania”, w którym AI zadaje pytania studentowi.
- Streamowane odpowiedzi w czasie rzeczywistym.
- Integracja z Anthropic API i OpenAI API.

## Technologie

- Flutter
- Dart
- `flutter_bloc`
- Clean Architecture
- OpenAI API
- Anthropic API
- SSE stream
- `syncfusion_flutter_pdf`
- OCR / parsowanie zdjęć notatek
- Local history storage

`syncfusion_flutter_pdf` nadaje się do pracy z dokumentami PDF w Flutterze i wspiera odczyt oraz edycję plików PDF. [web:2][web:5]

## Jak działa aplikacja

1. Student dodaje PDF albo zdjęcie notatek.
2. Aplikacja parsuje treść i zapisuje ją jako bazę wiedzy dla danego przedmiotu.
3. Użytkownik może rozmawiać z AI o materiałach.
4. AI generuje fiszki, quizy albo tryb odpytywania.
5. Odpowiedzi są streamowane do UI przez SSE, żeby użytkownik widział je na bieżąco. Streaming odpowiedzi AI przez SSE to standardowy sposób przesyłania tokenów z API do frontendu. 

## Integracja z AI

Aplikacja wspiera dwa backendy AI:
- **Anthropic API**
- **OpenAI API**

Warstwa data powinna być zbudowana tak, aby model dostawcy AI można było podmienić bez zmiany logiki domenowej.

## Streamowanie odpowiedzi

Odpowiedzi z modelu są wysyłane do UI w trybie stream, dzięki czemu użytkownik widzi generowanie odpowiedzi na żywo.

## Stan aplikacji

Do zarządzania stanem użyty jest `flutter_bloc`, co pozwala:
- trzymać logikę UI poza widgetami,
- łatwiej testować logikę,
- skalować projekt wraz z kolejnymi feature’ami.  

## Roadmap

- OCR dla zdjęć notatek.
- Synchronizacja danych w chmurze.
- Tagowanie materiałów.
- Wyszukiwanie pełnotekstowe po wszystkich notatkach.
- Tryb powtórek z spaced repetition.
- Eksport fiszek do Anki.
- Wsparcie dla wielu języków.




## Autorzy 

Yana Trotsenko

Valeriia Khylchenko 
