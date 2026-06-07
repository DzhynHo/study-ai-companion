# Konfiguracja API - Poradnik

## Anthropic Claude API (Rekomendowane ✅)

### 1. Rejestracja i Pobranie Klucza

1. Idź do [console.anthropic.com](https://console.anthropic.com/)
2. Zaloguj się lub stwórz konto
3. Przejdź do **API Keys** w lewym menu
4. Kliknij **"Create Key"**
5. Skopiuj klucz (format: `sk-ant-v7-...`)

### 2. Konfiguracja w Aplikacji

#### Opcja A: Hardcoded (Tylko dla developmentu ⚠️)

Plik: `lib/core/config.dart`

```dart
class AppConfig {
  static const String anthropicApiKey = 'sk-ant-v7-YOUR_KEY_HERE';
  // ...
}
```

#### Opcja B: Environment Variables (Rekomendowane 🔒)

1. Utwórz plik `.env` w root projektu:

```bash
ANTHROPIC_API_KEY=sk-ant-v7-your-actual-key-here
```

2. Zainstaluj pakiet:

```bash
flutter pub add flutter_dotenv
```

3. Aktualizuj `lib/main.dart`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  final apiKey = dotenv.env['ANTHROPIC_API_KEY'] ?? '';
  
  // ... reszta setup
}
```

4. Aktualizuj `pubspec.yaml`:

```yaml
flutter:
  assets:
    - .env
```

5. Dodaj do `.gitignore`:

```
.env
.env.local
```

#### Opcja C: Build Args (Production) 🚀

```bash
flutter run --dart-define=ANTHROPIC_API_KEY=sk-ant-v7-your-key
```

W `lib/main.dart`:

```dart
const apiKey = String.fromEnvironment('ANTHROPIC_API_KEY');
```

### 3. Testy i Weryfikacja

```bash
# Test połączenia z API
flutter run --verbose
```

W logu powinieneś zobaczyć:
```
✓ API connection successful
```

## OpenAI API (Alternatywa)

Jeśli chcesz używać OpenAI zamiast Anthropic:

### 1. Pobranie Klucza

1. Idź do [platform.openai.com](https://platform.openai.com/)
2. **API Keys** → **Create new secret key**
3. Skopiuj klucz (format: `sk-...`)

### 2. Modyfikacja Kodu

Plik: `lib/data/datasources/anthropic_client.dart`

```dart
class AnthropicClient {
  // Zmień na OpenAI client...
  Future<String> sendMessage({
    required String userMessage,
    required String? systemPrompt,
    // ...
  }) async {
    const url = 'https://api.openai.com/v1/chat/completions';
    
    final payload = {
      'model': 'gpt-4-turbo-preview',
      'messages': [
        if (systemPrompt != null) {'role': 'system', 'content': systemPrompt},
        // ...
      ]
    };
    
    // ... implementacja
  }
}
```

## Ceny i Limity

### Anthropic Claude

| Model | Input | Output |
|-------|-------|--------|
| Claude 3.5 Sonnet | $3/1M tokens | $15/1M tokens |

### OpenAI

| Model | Cena |
|-------|------|
| GPT-4 Turbo | $10/1M input, $30/1M output |
| GPT-4 Mini | $0.15/1M input, $0.60/1M output |

## Problemy i Rozwiązania

### "401 Unauthorized"

```
❌ Błąd: API key is invalid
```

**Rozwiązanie:**
- Sprawdź format klucza
- Upewnij się, że nie ma spacji
- Zregeneruj klucz w konsoli

### "429 Too Many Requests"

```
❌ Błąd: Rate limit exceeded
```

**Rozwiązanie:**
- Czekaj między requestami
- Upgrade plan w konsoli
- Sprawdź usage limits

### "500 Internal Server Error"

```
❌ Błąd: API server error
```

**Rozwiązanie:**
- Czekaj kilka minut
- Status strony: [status.anthropic.com](https://status.anthropic.com/)

## Bezpieczeństwo

### ✅ DO TEGO:
- Używaj environment variables
- Dodaj `.env` do `.gitignore`
- Rotuj klucze regularnie
- Monitoruj usage

### ❌ TEGO NIE RÓB:
- Nie commituj API key do Git
- Nie publikuj w social media
- Nie wysyłaj emailem
- Nie hardcoduj w production

## Monitoring i Billing

### Anthropic Console

1. Idź do [console.anthropic.com/monitoring](https://console.anthropic.com/monitoring)
2. Sprawdź **Usage & Cost**
3. Set **spending limits** jeśli chcesz

### OpenAI Dashboard

1. Idź do [platform.openai.com/usage](https://platform.openai.com/usage)
2. Sprawdź **Usage breakdown**

## Wskazówki do Optimalizacji Kosztów

```dart
// ❌ Wysyła cały kontekst za każdym razem (drogo)
final response = await anthropicClient.sendMessage(
  userMessage: question,
  systemPrompt: entireMaterial, // 🔴 DROGO!
);

// ✅ Zwęź materiał (taniej)
final response = await anthropicClient.sendMessage(
  userMessage: question,
  systemPrompt: truncateMaterial(material, maxTokens: 500), // ✅ Lepiej
);
```

---

**Gotowe!** Twoja aplikacja powinna teraz działać z Anthropic API 🎉
