/// Konfiguracja aplikacji - API keys i ustawienia
class AppConfig {
  /// Klucz API dla Groq AI
  /// Pobierz klucz z https://console.groq.com/keys
  /// Klucz powinien zaczynać się od: gsk_...
  static const String groqApiKey = 'gsk_TWOJ_KLUCZ_TUTAJ';

  /// Włącz mock mode (bez API key) do testowania
  static const bool useMockAI = false;

  /// Model Groq do użycia (mixtral-8x7b-32768 jest szybki i darmowy)
  static const String groqModel = 'llama-3.3-70b-versatile';

  /// Model Groq z obsługą obrazów (vision)
  static const String groqVisionModel = 'meta-llama/llama-4-scout-17b-16e-instruct';

  /// Tytuł aplikacji
  static const String appTitle = 'EduChat';

  /// Maksymalny rozmiar wejścia dla PDF (50MB)
  static const int maxPdfSizeBytes = 50 * 1024 * 1024;

  /// Maksymalny rozmiar obrazu (10MB)
  static const int maxImageSizeBytes = 10 * 1024 * 1024;

  /// Timeout dla API requests (30s)
  static const Duration apiTimeout = Duration(seconds: 30);

  /// Debug mode - włącz mock responses
  static const bool enableDebugMode = false;
}

/// Wiadomości i teksty UI
class AppStrings {
  // Główne
  static const String appTitle = 'EduChat';

  // Przedmioty
  static const String newSubject = 'Nowy przedmiot';
  static const String noSubjects = 'Brak przedmiotów';
  static const String noSubjectsHint = 'Kliknij przycisk poniżej aby dodać pierwszy przedmiot';

  // Czat
  static const String uploadPdf = 'Wgraj PDF';
  static const String uploadImage = 'Wgraj zdjęcie notatek';
  static const String pdfLoaded = '✅ PDF wczytany! O co chcesz zapytać?';
  static const String imageLoaded = '✅ Zdjęcie przetworzone! O co chcesz zapytać?';
  static const String askQuestion = 'Zadaj pytanie do materiału...';
  static const String noMaterial = 'Najpierw wgraj materiał!';

  // Fiszki
  static const String generateFlashcards = '📇 Fiszki';
  static const String touchToReveal = 'Dotknij kartę aby zobaczyć odpowiedź';

  // Quiz
  static const String generateQuiz = '❓ Quiz';

  // Tryb egzaminu
  static const String examMode = '🎓 Tryb odpytywania';
  static const String aiQuestion = 'AI przygotowuje pytanie...';

  // Errory
  static const String errorPdf = 'Błąd PDF: ';
  static const String errorImage = 'Błąd zdjęcia: ';
  static const String errorAi = 'Błąd AI: ';
  static const String errorFlashcards = 'Błąd fiszek: ';
  static const String errorQuiz = 'Błąd quizu: ';
  static const String errorSubject = 'Błąd przedmiotu: ';
}