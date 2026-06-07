import '../entities/subject.dart';
import '../entities/message.dart';
import '../entities/flashcard.dart';
import '../entities/quiz_question.dart';

abstract class StudyRepository {
  // Subject management
  Future<List<Subject>> getSubjects();
  Future<void> createSubject(Subject subject);
  Future<void> updateSubject(Subject subject);
  Future<void> deleteSubject(String subjectId);

  // Material upload
  Future<String?> extractPdfText(List<int> pdfBytes);
  Future<String?> extractImageText(List<int> imageBytes);

  // Chat — streaming
  Stream<String> streamQuestion(String extractedText, String question);
  Future<String> askQuestion(String subjectId, String extractedText, String question);

  // Exam mode
  Future<String> askExamQuestion({
    required String subjectId,
    required String extractedText,
    required List<Map<String, String>> history,
    required String userAnswer,
  });

  // Flashcards
  Future<List<Flashcard>> generateFlashcards(String subjectId, String extractedText);
  Future<List<Flashcard>> getFlashcards(String subjectId);
  Future<void> saveFlashcards(List<Flashcard> flashcards);

  // Quiz
  Future<List<QuizQuestion>> generateQuiz(String subjectId, String extractedText);
  Future<List<QuizQuestion>> getQuiz(String subjectId);

  // Messages
  Future<List<Message>> getMessages(String subjectId);
  Future<void> saveMessage(Message message);
}
