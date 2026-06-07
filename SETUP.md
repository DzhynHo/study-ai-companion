# 📚 AI Study Buddy - Aplikacja do Nauki z AI

Nowoczesna aplikacja Flutter do nauki z pomocą Claude/GPT. Student wrzuca materiały (PDF, zdjęcia notatek) i może z nimi rozmawiać, generować fiszki i quizy.

## ✨ Główne Funkcje

- **📤 Upload Materiałów**: PDF, zdjęcia notatek
- **💬 Chat z AI**: Rozmowa o materiałach z kontekstem (RAG)
- **📇 Generowanie Fiszek**: Automatyczne tworzenie fiszek z materiałów
- **❓ Quizy**: Pytania testowe wielokrotnego wyboru
- **🎓 Tryb Odpytywania**: AI zadaje pytania, student odpowiada
- **📚 Historia Rozmów**: Per przedmiot
- **💾 Offline Storage**: Hive dla lokalnego przechowywania

## 🏗️ Architektura

Projekt używa **Clean Architecture** podzielony na warstwy:

```
lib/
├── core/
│   ├── config.dart          # Konfiguracja i stałe
│   ├── extensions.dart      # Extensions
│   └── ...
├── domain/
│   ├── entities/           # Modele biznesowe
│   ├── repositories/       # Abstrakcje
│   └── usecases/           # (Opcjonalnie)
├── data/
│   ├── datasources/        # API, Local Storage
│   ├── models/             # Modele mapowania
│   └── repositories/       # Implementacja
├── presentation/
│   ├── bloc/               # BLoC + State Management
│   ├── pages/              # Widoki
│   └── widgets/            # Komponenty
└── main.dart               # Entry point
```

## 🔧 Stack Techniczny

- **Framework**: Flutter 3.x
- **State Management**: flutter_bloc
- **AI API**: Anthropic Claude (OpenAI opcjonalnie)
- **Storage**: Hive (local)
- **Network**: Dio
- **File Handling**: file_picker, image_picker

## 📋 Wymagania

- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Android SDK 21+ / iOS 11+

## 🚀 Setup & Instalacja

### 1. Klonowanie i Install Zależności

```bash
cd first_app
flutter pub get
```

### 2. Konfiguracja API Key

Otwórz `lib/core/config.dart` i ustaw swój API key:

```dart
static const String anthropicApiKey = 'sk-ant-v7-YOUR_ACTUAL_KEY';
```

**Zamiast hardcoding**, używaj environment variables:

```bash
export ANTHROPIC_API_KEY='sk-ant-v7-your-key'
```

W `main.dart`:

```dart
final apiKey = String.fromEnvironment('ANTHROPIC_API_KEY');
```

### 3. Uruchomienie

```bash
flutter run
```

## 📱 Użytkownik - Workflow

1. **Utwórz Przedmiot** - np. "Matematyka", "Historia"
2. **Wgraj Materiały** - PDF lub zdjęcie notatek
3. **Czat** - Zadaj pytania do materiałów
4. **Generuj Fiszki** - Klikaj menu > Fiszki
5. **Quiz** - Testuj wiedzę
6. **Tryb Odpytywania** - AI Cię egzaminuje

## 🔑 Klucze API

### Anthropic Claude (Rekomendowane)

```bash
# Get API key: https://console.anthropic.com/
```

### OpenAI (Opcjonalnie - wymaga modyfikacji)

```bash
# Get API key: https://platform.openai.com/
```

## 📦 Publikacja

### Android

```bash
flutter build apk --release
# lub bundle
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## 🐛 Rozwiązywanie Problemów

### "Brak odpowiedzi z API"

- Sprawdź API key w `core/config.dart`
- Sprawdź połączenie internetowe
- Sprawdź limit quota w konsoli Anthropic

### "Hive: Failed to open box"

```bash
flutter clean
flutter pub get
```

### "PDF nie ekstraktuje tekstu"

- Użyj pliku PDF z tekstem (nie skan)
- Maksymalny rozmiar: 50MB

## 📚 Struktura Kodu - Szybki Przewodnik

### Models/Entities (`domain/entities/`)

- `Subject` - Przedmiot
- `Message` - Wiadomość w czacie
- `Flashcard` - Fiszka
- `QuizQuestion` - Pytanie quizu

### BLoC (`presentation/bloc/study_bloc.dart`)

- **Events**: Akcje użytkownika (Upload, Ask, Generate...)
- **States**: Stan aplikacji
- **Handlers**: Logika biznesowa

### Repositories (`data/repositories/`)

- Łączy data sources
- Mapuje modele
- Obsługuje błędy

## 🔐 Bezpieczeństwo

- ⚠️ **NIGDY** nie commit API key do Git!
- Używaj `.gitignore` lub environment variables
- Dla production: używaj secure storage (flutter_secure_storage)

## 🚀 Następne Kroki

### TODO:

- [ ] Voice Input (flutter_tts)
- [ ] Eksport do PDF fiszek
- [ ] Sync do chmury (Firebase)
- [ ] Dark Mode
- [ ] Wielojęzyczność (i18n)
- [ ] Offline Mode
- [ ] Social Features (udostępnianie)

## 📞 Support

Dla problemów:
1. Sprawdź logs: `flutter logs`
2. Uruchom debug: `flutter run -v`
3. Wyczyść cache: `flutter clean`

## 📄 Licencja

MIT License

## 👨‍💻 Autor

Aplikacja stworzona z ❤️ dla studentów

---

**Powodzenia w nauce!** 🎓📚
