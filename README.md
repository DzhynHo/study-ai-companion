# Study AI Companion

Aplikacja Flutter do nauki z pomocą AI, która pozwala studentowi wrzucać materiały dydaktyczne i „rozmawiać" z ich treścią.

---

## Zrzuty ekranu



| | | |
|---|---|---|
| ![](screenshots/splash.png) | ![](screenshots/subjects.png) | ![](screenshots/chat.png) |
| `splash.png` | `subjects.png` | `chat.png` |
| ![](screenshots/flashcards.png) | ![](screenshots/quiz.png) | ![](screenshots/exam_mode.png) |
| `flashcards.png` | `quiz.png` | `exam_mode.png` |

---

## Opis

**Study AI Companion** to aplikacja mobilna/webowa stworzona w Flutterze, która pomaga w nauce na podstawie własnych materiałów — PDF-ów, zdjęć notatek i plików z zajęć.

Aplikacja wykorzystuje modele AI do zadawania pytań o treść materiałów, generowania fiszek, tworzenia quizów i prowadzenia trybu odpytywania.

---

## Funkcje

| Funkcja | Opis |
|---|---|
| **Upload PDF** | Wgraj skrypt lub podręcznik — tekst wyodrębniany lokalnie (Syncfusion) |
| **Upload zdjęcia notatek** | Zrób zdjęcie ręcznych notatek — AI odczyta tekst (OCR przez Groq Vision) |
| **Chat z AI** | Zadawaj pytania do swoich materiałów — AI odpowiada wyłącznie na ich podstawie |
| **Streaming odpowiedzi** | Tekst pojawia się słowo po słowie w czasie rzeczywistym (SSE) |
| **Generowanie fiszek** | AI tworzy 8–10 par pytanie/odpowiedź z animacją obrotu karty |
| **Generowanie quizów** | 5–6 pytań wielokrotnego wyboru (A/B/C/D) z oceną wyników |
| **Tryb odpytywania** | AI wciela się w egzaminatora — zadaje pytania i ocenia odpowiedzi studenta |
| **Historia rozmów** | Każdy przedmiot ma własną historię czatu zapisaną lokalnie |
| **Tryb offline** | Dane przechowywane lokalnie w Hive (bez potrzeby konta/chmury) |

---

## Stack technologiczny

| Warstwa | Technologia |
|---|---|
| Framework | Flutter 3.x / Dart 3.x |
| Zarządzanie stanem | `flutter_bloc` 8.x |
| AI — czat i generowanie | Groq API (model `llama-3.3-70b-versatile`) |
| AI — OCR zdjęć | Groq Vision (`llama-4-scout-17b-16e-instruct`) |
| Parsowanie PDF | `syncfusion_flutter_pdf` (lokalnie, bez uploadu) |
| Baza danych | Hive (lokalny NoSQL) |
| Streaming | SSE (Server-Sent Events) przez `dio` |
| UI | Material Design 3 |

---

## Architektura

Projekt oparty na **Clean Architecture** z podziałem na trzy warstwy:

```
presentation/          # UI — strony, BLoC (flutter_bloc)
├── bloc/
│   └── study_bloc.dart
└── pages/
    ├── splash_page.dart
    ├── subjects_page.dart
    ├── chat_page.dart
    ├── flashcards_page.dart
    ├── quiz_page.dart
    └── exam_mode_page.dart

domain/               # Logika biznesowa — encje, interfejsy
├── entities/          # Subject, Message, Flashcard, QuizQuestion
└── repositories/      # Abstrakcyjny interfejs StudyRepository

data/                 # Implementacje — API, baza danych
├── datasources/
│   ├── groq_client.dart
│   ├── anthropic_client.dart
│   ├── local_data_source.dart
│   └── text_extraction_service.dart
└── repositories/
    └── study_repository_impl.dart
```

**Przepływ danych:**
```
Strona → zdarzenie BLoC → Repository → Groq API / Hive → nowy Stan → UI
```

---

## Jak działa RAG (uproszczony)

Aplikacja nie używa wektorowej bazy danych. Przy każdym pytaniu do API wysyłany jest pełny tekst materiałów (do 24 000 znaków) wraz z pytaniem studenta:

```
MATERIAŁY:
[wyodrębniony tekst z PDF/zdjęcia]

PYTANIE:
[pytanie studenta]
```

AI odpowiada wyłącznie na podstawie dostarczonych materiałów — jeśli odpowiedź nie jest w tekście, informuje o tym.

---

## Instalacja

```bash
git clone <url-repo>
cd first_app
flutter pub get
flutter run
```

Otwórz `lib/core/config.dart` i wstaw klucz API:

```dart
static const String groqApiKey = 'gsk_TWÓJ_KLUCZ_TUTAJ';
```

Klucz uzyskasz bezpłatnie na [console.groq.com](https://console.groq.com).

---

## Roadmap

- Synchronizacja danych w chmurze.
- Tagowanie materiałów.
- Wyszukiwanie pełnotekstowe po wszystkich notatkach.
- Tryb powtórek z spaced repetition.
- Eksport fiszek do Anki.
- Wsparcie dla wielu języków.

---

## Autorzy

Yana Trotsenko  
Valeriia Khylchenko

---

*Zbudowane z Flutter + Groq AI*
