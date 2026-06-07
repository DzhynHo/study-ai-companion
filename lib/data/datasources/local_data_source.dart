import 'package:hive/hive.dart';
import '../../domain/entities/subject.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/flashcard.dart';
import '../../domain/entities/quiz_question.dart';

abstract class LocalDataSource {
  Future<List<Subject>> getSubjects();
  Future<void> saveSubject(Subject subject);
  Future<void> updateSubject(Subject subject);
  Future<void> deleteSubject(String subjectId);

  Future<List<Message>> getMessages(String subjectId);
  Future<void> saveMessage(Message message);
  Future<void> saveMessages(List<Message> messages);

  Future<List<Flashcard>> getFlashcards(String subjectId);
  Future<void> saveFlashcards(List<Flashcard> flashcards);

  Future<List<QuizQuestion>> getQuiz(String subjectId);
  Future<void> saveQuiz(List<QuizQuestion> questions);

  Future<void> saveMaterialExtract(String subjectId, String extractedText);
  Future<String?> getMaterialExtract(String subjectId);
}

class HiveLocalDataSource implements LocalDataSource {
  late Box<Map> _subjectsBox;
  late Box<Map> _messagesBox;
  late Box<Map> _flashcardsBox;
  late Box<Map> _quizBox;

  Future<void> init() async {
    try {
      _subjectsBox = await Hive.openBox<Map>('subjects');
      _messagesBox = await Hive.openBox<Map>('messages');
      _flashcardsBox = await Hive.openBox<Map>('flashcards');
      _quizBox = await Hive.openBox<Map>('quiz');
    } catch (e) {
      print('Error opening Hive boxes: $e');
      // Try to close and reopen
      try {
        await Hive.close();
        await Future.delayed(const Duration(milliseconds: 500));
        _subjectsBox = await Hive.openBox<Map>('subjects');
        _messagesBox = await Hive.openBox<Map>('messages');
        _flashcardsBox = await Hive.openBox<Map>('flashcards');
        _quizBox = await Hive.openBox<Map>('quiz');
      } catch (e2) {
        print('Error on retry: $e2');
        rethrow;
      }
    }
  }

  @override
  Future<List<Subject>> getSubjects() async {
    try {
      final subjects = _subjectsBox.values
          .map((m) => Subject(
                id: m['id'] as String,
                name: m['name'] as String,
                extractedText: m['extractedText'] as String?,
                createdAt: DateTime.parse(m['createdAt'] as String),
              ))
          .toList();
      return subjects;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveSubject(Subject subject) async {
    await _subjectsBox.put(subject.id, {
      'id': subject.id,
      'name': subject.name,
      'extractedText': subject.extractedText,
      'createdAt': subject.createdAt.toIso8601String(),
    });
  }

  @override
  Future<void> updateSubject(Subject subject) async {
    await _subjectsBox.put(subject.id, {
      'id': subject.id,
      'name': subject.name,
      'extractedText': subject.extractedText,
      'createdAt': subject.createdAt.toIso8601String(),
    });
  }

  @override
  Future<void> deleteSubject(String subjectId) async {
    await _subjectsBox.delete(subjectId);
    // Usuń wszystkie dane tego przedmiotu
    final msgKeysToDelete = _messagesBox.keys
        .where((key) => _messagesBox.get(key)?['subjectId'] == subjectId)
        .toList();
    for (final key in msgKeysToDelete) {
      await _messagesBox.delete(key);
    }
    
    final fcKeysToDelete = _flashcardsBox.keys
        .where((key) => _flashcardsBox.get(key)?['subjectId'] == subjectId)
        .toList();
    for (final key in fcKeysToDelete) {
      await _flashcardsBox.delete(key);
    }
    
    final qKeysToDelete = _quizBox.keys
        .where((key) => _quizBox.get(key)?['subjectId'] == subjectId)
        .toList();
    for (final key in qKeysToDelete) {
      await _quizBox.delete(key);
    }
  }

  @override
  Future<List<Message>> getMessages(String subjectId) async {
    try {
      final messages = _messagesBox.values
          .where((m) => m['subjectId'] == subjectId)
          .map((m) {
            final roleStr = m['role'] as String;
            final role = roleStr.toLowerCase().contains('user') 
                ? MessageRole.user 
                : MessageRole.ai;
            return Message(
              id: m['id'] as String,
              subjectId: m['subjectId'] as String,
              role: role,
              content: m['content'] as String,
              timestamp: DateTime.parse(m['timestamp'] as String),
            );
          })
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return messages;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveMessage(Message message) async {
    await _messagesBox.put(message.id, message.toJson());
  }

  @override
  Future<void> saveMessages(List<Message> messages) async {
    for (final msg in messages) {
      await _messagesBox.put(msg.id, msg.toJson());
    }
  }

  @override
  Future<List<Flashcard>> getFlashcards(String subjectId) async {
    try {
      final flashcards = _flashcardsBox.values
          .where((f) => f['subjectId'] == subjectId)
          .map((f) => Flashcard(
                id: f['id'] as String,
                subjectId: f['subjectId'] as String,
                question: f['question'] as String,
                answer: f['answer'] as String,
                isMarked: f['isMarked'] as bool? ?? false,
                createdAt: DateTime.parse(f['createdAt'] as String),
              ))
          .toList();
      return flashcards;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveFlashcards(List<Flashcard> flashcards) async {
    for (final card in flashcards) {
      await _flashcardsBox.put(card.id, card.toJson());
    }
  }

  @override
  Future<List<QuizQuestion>> getQuiz(String subjectId) async {
    try {
      final questions = _quizBox.values
          .where((q) => q['subjectId'] == subjectId)
          .map((q) => QuizQuestion(
                id: q['id'] as String,
                subjectId: q['subjectId'] as String,
                question: q['question'] as String,
                options: List<String>.from(q['options'] as List),
                correctIndex: q['correctIndex'] as int,
                createdAt: DateTime.parse(q['createdAt'] as String),
              ))
          .toList();
      return questions;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveQuiz(List<QuizQuestion> questions) async {
    for (final q in questions) {
      await _quizBox.put(q.id, q.toJson());
    }
  }

  @override
  Future<void> saveMaterialExtract(String subjectId, String extractedText) async {
    final subject = _subjectsBox.get(subjectId) as Map?;
    if (subject != null) {
      subject['extractedText'] = extractedText;
      await _subjectsBox.put(subjectId, subject);
    }
  }

  @override
  Future<String?> getMaterialExtract(String subjectId) async {
    final subject = _subjectsBox.get(subjectId) as Map?;
    return subject?['extractedText'] as String?;
  }
}
