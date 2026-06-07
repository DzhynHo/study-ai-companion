import 'dart:convert';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import '../../domain/entities/subject.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/flashcard.dart';
import '../../domain/entities/quiz_question.dart';
import '../../domain/repositories/study_repository.dart';
import '../datasources/groq_client.dart';
import '../datasources/local_data_source.dart';
import '../datasources/text_extraction_service.dart';

class StudyRepositoryImpl implements StudyRepository {
  final GroqClient groqClient;
  final HiveLocalDataSource localDataSource;

  StudyRepositoryImpl({
    required this.groqClient,
    required this.localDataSource,
  });

  static const _uuid = Uuid();
  static const _maxTextChars = 24000;
  final _textExtractionService = TextExtractionService();

  String _truncate(String text) {
    if (text.length <= _maxTextChars) return text;
    return '${text.substring(0, _maxTextChars)}\n\n[Tekst skrócony ze względu na limit API]';
  }

  // ── Subject management ────────────────────────────────────────────────────

  @override
  Future<List<Subject>> getSubjects() => localDataSource.getSubjects();

  @override
  Future<void> createSubject(Subject subject) => localDataSource.saveSubject(subject);

  @override
  Future<void> updateSubject(Subject subject) => localDataSource.updateSubject(subject);

  @override
  Future<void> deleteSubject(String subjectId) => localDataSource.deleteSubject(subjectId);

  // ── Material extraction ───────────────────────────────────────────────────

  @override
  Future<String?> extractPdfText(List<int> pdfBytes) async {
    try {
      final text = await _textExtractionService.extractTextFromPdf(
        Uint8List.fromList(pdfBytes),
      );
      return _textExtractionService.cleanText(text);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> extractImageText(List<int> imageBytes) async {
    try {
      final text = await groqClient.extractTextFromImage(
        Uint8List.fromList(imageBytes),
      );
      return text.trim().isEmpty ? null : text;
    } catch (e) {
      return null;
    }
  }

  // ── Chat — streaming ──────────────────────────────────────────────────────

  @override
  Stream<String> streamQuestion(String extractedText, String question) {
    const systemPrompt =
        'Jesteś pomocnym asystentem edukacyjnym. '
        'Odpowiadaj WYŁĄCZNIE w oparciu o dostarczone materiały. '
        'Bądź precyzyjny i konkretny. '
        'Jeśli odpowiedź nie jest w materiałach, powiedz o tym. '
        'Formatuj odpowiedź używając markdown.';

    final userMessage =
        'MATERIAŁY:\n${_truncate(extractedText)}\n\nPYTANIE:\n$question';

    return groqClient.streamMessage(
      userMessage: userMessage,
      systemPrompt: systemPrompt,
    );
  }

  @override
  Future<String> askQuestion(
      String subjectId, String extractedText, String question) async {
    const systemPrompt =
        'Jesteś pomocnym asystentem edukacyjnym. '
        'Odpowiadaj WYŁĄCZNIE w oparciu o dostarczone materiały. '
        'Bądź precyzyjny i konkretny. '
        'Jeśli odpowiedź nie jest w materiałach, powiedz o tym. '
        'Formatuj odpowiedź używając markdown.';

    final userMessage =
        'MATERIAŁY:\n${_truncate(extractedText)}\n\nPYTANIE:\n$question';

    final response = await groqClient.sendMessage(
      userMessage: userMessage,
      systemPrompt: systemPrompt,
    );

    final userMsg = Message(
      id: _uuid.v4(),
      subjectId: subjectId,
      role: MessageRole.user,
      content: question,
      timestamp: DateTime.now(),
    );
    final aiMsg = Message(
      id: _uuid.v4(),
      subjectId: subjectId,
      role: MessageRole.ai,
      content: response,
      timestamp: DateTime.now(),
    );
    await localDataSource.saveMessage(userMsg);
    await localDataSource.saveMessage(aiMsg);

    return response;
  }

  // ── Exam mode ─────────────────────────────────────────────────────────────

  @override
  Future<String> askExamQuestion({
    required String subjectId,
    required String extractedText,
    required List<Map<String, String>> history,
    required String userAnswer,
  }) async {
    const systemPrompt =
        'Jesteś surowym egzaminatorem. Odpytujesz studenta z dostarczonych materiałów.\n'
        'Zasady:\n'
        '1. Zadajesz JEDNO konkretne pytanie naraz.\n'
        '2. Gdy student odpowie, KRÓTKO oceń odpowiedź (Poprawnie / Częściowo / Błędnie) i wyjaśnij ewentualne błędy.\n'
        '3. Następnie zadaj kolejne pytanie z INNEGO tematu niż poprzednie.\n'
        '4. Pytaj o różne aspekty materiałów — definicje, przykłady, zastosowania.\n'
        'NIE pomagaj, tylko pytaj i oceniaj. Bądź zwięzły.';

    final userMessage = userAnswer.isEmpty
        ? 'MATERIAŁY:\n${_truncate(extractedText)}\n\nZadaj pierwsze pytanie egzaminacyjne.'
        : userAnswer;

    final response = await groqClient.sendMessage(
      userMessage: userMessage,
      systemPrompt: systemPrompt,
      history: history.isEmpty ? null : history,
    );

    if (userAnswer.isNotEmpty) {
      final userMsg = Message(
        id: _uuid.v4(),
        subjectId: subjectId,
        role: MessageRole.user,
        content: userAnswer,
        timestamp: DateTime.now(),
      );
      await localDataSource.saveMessage(userMsg);
    }

    final aiMsg = Message(
      id: _uuid.v4(),
      subjectId: subjectId,
      role: MessageRole.ai,
      content: response,
      timestamp: DateTime.now(),
    );
    await localDataSource.saveMessage(aiMsg);

    return response;
  }

  // ── Flashcards ────────────────────────────────────────────────────────────

  @override
  Future<List<Flashcard>> generateFlashcards(
      String subjectId, String extractedText) async {
    const systemPrompt =
        'Jesteś ekspertem w tworzeniu fiszek edukacyjnych. '
        'WAŻNE: Zwróć WYŁĄCZNIE czysty JSON bez backticks ani markdown:\n'
        '[{"question":"pytanie","answer":"odpowiedź"},...]';

    final userMessage =
        'MATERIAŁY:\n${_truncate(extractedText)}\n\nWygeneruj 8-10 fiszek. Zwróć wyłącznie JSON array.';

    final response = await groqClient.extractJsonStructure(
      userMessage: userMessage,
      systemPrompt: systemPrompt,
    );

    final jsonData = jsonDecode(response) as List;
    final flashcards = jsonData
        .map((item) => Flashcard(
              id: _uuid.v4(),
              subjectId: subjectId,
              question: item['question'] as String,
              answer: item['answer'] as String,
              createdAt: DateTime.now(),
            ))
        .toList();

    await localDataSource.saveFlashcards(flashcards);
    return flashcards;
  }

  @override
  Future<List<Flashcard>> getFlashcards(String subjectId) =>
      localDataSource.getFlashcards(subjectId);

  @override
  Future<void> saveFlashcards(List<Flashcard> flashcards) =>
      localDataSource.saveFlashcards(flashcards);

  // ── Quiz ──────────────────────────────────────────────────────────────────

  @override
  Future<List<QuizQuestion>> generateQuiz(
      String subjectId, String extractedText) async {
    const systemPrompt =
        'Jesteś twórcą quizów edukacyjnych. '
        'WAŻNE: Zwróć WYŁĄCZNIE czysty JSON bez backticks ani markdown:\n'
        '[{"question":"pytanie","options":["A","B","C","D"],"correctIndex":0},...]';

    final userMessage =
        'MATERIAŁY:\n${_truncate(extractedText)}\n\nWygeneruj 5-6 pytań testowych. Zwróć wyłącznie JSON array.';

    final response = await groqClient.extractJsonStructure(
      userMessage: userMessage,
      systemPrompt: systemPrompt,
    );

    final jsonData = jsonDecode(response) as List;
    final questions = jsonData
        .map((item) => QuizQuestion(
              id: _uuid.v4(),
              subjectId: subjectId,
              question: item['question'] as String,
              options: List<String>.from(item['options'] as List),
              correctIndex: item['correctIndex'] as int,
              createdAt: DateTime.now(),
            ))
        .toList();

    await localDataSource.saveQuiz(questions);
    return questions;
  }

  @override
  Future<List<QuizQuestion>> getQuiz(String subjectId) =>
      localDataSource.getQuiz(subjectId);

  // ── Messages ──────────────────────────────────────────────────────────────

  @override
  Future<List<Message>> getMessages(String subjectId) =>
      localDataSource.getMessages(subjectId);

  @override
  Future<void> saveMessage(Message message) =>
      localDataSource.saveMessage(message);
}
