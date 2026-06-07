import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/subject.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/flashcard.dart';
import '../../domain/entities/quiz_question.dart';
import '../../domain/repositories/study_repository.dart';

// ============================================================================
// EVENTS
// ============================================================================

abstract class StudyEvent extends Equatable {
  const StudyEvent();
  @override
  List<Object?> get props => [];
}

class CreateSubjectEvent extends StudyEvent {
  final String name;
  const CreateSubjectEvent(this.name);
  @override
  List<Object?> get props => [name];
}

class DeleteSubjectEvent extends StudyEvent {
  final String subjectId;
  const DeleteSubjectEvent(this.subjectId);
  @override
  List<Object?> get props => [subjectId];
}

class SelectSubjectEvent extends StudyEvent {
  final String subjectId;
  const SelectSubjectEvent(this.subjectId);
  @override
  List<Object?> get props => [subjectId];
}

class LoadSubjectsEvent extends StudyEvent {
  const LoadSubjectsEvent();
}

class UploadPdfEvent extends StudyEvent {
  const UploadPdfEvent();
}

class UploadImageEvent extends StudyEvent {
  const UploadImageEvent();
}

class AskQuestionEvent extends StudyEvent {
  final String question;
  const AskQuestionEvent(this.question);
  @override
  List<Object?> get props => [question];
}

class GenerateFlashcardsEvent extends StudyEvent {
  const GenerateFlashcardsEvent();
}

class ToggleFlashcardEvent extends StudyEvent {
  const ToggleFlashcardEvent();
}

class NextFlashcardEvent extends StudyEvent {
  const NextFlashcardEvent();
}

class PreviousFlashcardEvent extends StudyEvent {
  const PreviousFlashcardEvent();
}

class GenerateQuizEvent extends StudyEvent {
  const GenerateQuizEvent();
}

class AnswerQuizEvent extends StudyEvent {
  final int selectedIndex;
  const AnswerQuizEvent(this.selectedIndex);
  @override
  List<Object?> get props => [selectedIndex];
}

class NextQuestionEvent extends StudyEvent {
  const NextQuestionEvent();
}

class StartExamModeEvent extends StudyEvent {
  const StartExamModeEvent();
}

class AnswerExamQuestionEvent extends StudyEvent {
  final String answer;
  const AnswerExamQuestionEvent(this.answer);
  @override
  List<Object?> get props => [answer];
}

class ExitModeEvent extends StudyEvent {
  const ExitModeEvent();
}

class BackToSubjectsEvent extends StudyEvent {
  const BackToSubjectsEvent();
}

// ============================================================================
// STATE
// ============================================================================

enum AppMode { subjects, chat, flashcards, quiz, examMode }

class StudyState extends Equatable {
  final List<Subject> subjects;
  final Subject? activeSubject;
  final bool isLoadingSubjects;

  final List<Message> chatMessages;
  final bool isLoadingChat;
  final String? streamingContent; // текущий стриминг

  final List<Flashcard> flashcards;
  final int currentFlashcardIndex;
  final bool showFlashcardAnswer;

  final List<QuizQuestion> quizQuestions;
  final int currentQuizIndex;
  final int? selectedQuizAnswer;
  final bool quizAnswerRevealed;
  final int quizScore;

  final List<Message> examHistory;
  final bool examModeActive;

  final AppMode appMode;
  final String? error;
  final String? extractedText;

  const StudyState({
    this.subjects = const [],
    this.activeSubject,
    this.isLoadingSubjects = false,
    this.chatMessages = const [],
    this.isLoadingChat = false,
    this.streamingContent,
    this.flashcards = const [],
    this.currentFlashcardIndex = 0,
    this.showFlashcardAnswer = false,
    this.quizQuestions = const [],
    this.currentQuizIndex = 0,
    this.selectedQuizAnswer,
    this.quizAnswerRevealed = false,
    this.quizScore = 0,
    this.examHistory = const [],
    this.examModeActive = false,
    this.appMode = AppMode.subjects,
    this.error,
    this.extractedText,
  });

  StudyState copyWith({
    List<Subject>? subjects,
    Subject? activeSubject,
    bool? isLoadingSubjects,
    List<Message>? chatMessages,
    bool? isLoadingChat,
    String? streamingContent,
    bool clearStreaming = false,
    List<Flashcard>? flashcards,
    int? currentFlashcardIndex,
    bool? showFlashcardAnswer,
    List<QuizQuestion>? quizQuestions,
    int? currentQuizIndex,
    int? selectedQuizAnswer,
    bool? quizAnswerRevealed,
    int? quizScore,
    List<Message>? examHistory,
    bool? examModeActive,
    AppMode? appMode,
    String? error,
    String? extractedText,
  }) {
    return StudyState(
      subjects: subjects ?? this.subjects,
      activeSubject: activeSubject ?? this.activeSubject,
      isLoadingSubjects: isLoadingSubjects ?? this.isLoadingSubjects,
      chatMessages: chatMessages ?? this.chatMessages,
      isLoadingChat: isLoadingChat ?? this.isLoadingChat,
      streamingContent: clearStreaming ? null : (streamingContent ?? this.streamingContent),
      flashcards: flashcards ?? this.flashcards,
      currentFlashcardIndex: currentFlashcardIndex ?? this.currentFlashcardIndex,
      showFlashcardAnswer: showFlashcardAnswer ?? this.showFlashcardAnswer,
      quizQuestions: quizQuestions ?? this.quizQuestions,
      currentQuizIndex: currentQuizIndex ?? this.currentQuizIndex,
      selectedQuizAnswer: selectedQuizAnswer ?? this.selectedQuizAnswer,
      quizAnswerRevealed: quizAnswerRevealed ?? this.quizAnswerRevealed,
      quizScore: quizScore ?? this.quizScore,
      examHistory: examHistory ?? this.examHistory,
      examModeActive: examModeActive ?? this.examModeActive,
      appMode: appMode ?? this.appMode,
      error: error,
      extractedText: extractedText ?? this.extractedText,
    );
  }

  @override
  List<Object?> get props => [
        subjects, activeSubject, isLoadingSubjects,
        chatMessages, isLoadingChat, streamingContent,
        flashcards, currentFlashcardIndex, showFlashcardAnswer,
        quizQuestions, currentQuizIndex, selectedQuizAnswer,
        quizAnswerRevealed, quizScore,
        examHistory, examModeActive,
        appMode, error, extractedText,
      ];
}

// ============================================================================
// BLOC
// ============================================================================

class StudyBloc extends Bloc<StudyEvent, StudyState> {
  final StudyRepository repository;
  static const _uuid = Uuid();

  StudyBloc({required this.repository}) : super(const StudyState()) {
    on<LoadSubjectsEvent>(_onLoadSubjects);
    on<CreateSubjectEvent>(_onCreateSubject);
    on<DeleteSubjectEvent>(_onDeleteSubject);
    on<SelectSubjectEvent>(_onSelectSubject);
    on<UploadPdfEvent>(_onUploadPdf);
    on<UploadImageEvent>(_onUploadImage);
    on<AskQuestionEvent>(_onAskQuestion);
    on<GenerateFlashcardsEvent>(_onGenerateFlashcards);
    on<ToggleFlashcardEvent>(_onToggleFlashcard);
    on<NextFlashcardEvent>(_onNextFlashcard);
    on<PreviousFlashcardEvent>(_onPreviousFlashcard);
    on<GenerateQuizEvent>(_onGenerateQuiz);
    on<AnswerQuizEvent>(_onAnswerQuiz);
    on<NextQuestionEvent>(_onNextQuestion);
    on<StartExamModeEvent>(_onStartExamMode);
    on<AnswerExamQuestionEvent>(_onAnswerExamQuestion);
    on<ExitModeEvent>(_onExitMode);
    on<BackToSubjectsEvent>(_onBackToSubjects);
  }

  // ── Przedmioty ─────────────────────────────────────────────────────────────

  Future<void> _onLoadSubjects(LoadSubjectsEvent event, Emitter<StudyState> emit) async {
    emit(state.copyWith(isLoadingSubjects: true, error: null));
    try {
      final subjects = await repository.getSubjects();
      emit(state.copyWith(subjects: subjects, isLoadingSubjects: false));
    } catch (e) {
      emit(state.copyWith(isLoadingSubjects: false, error: 'Błąd ładowania: $e'));
    }
  }

  Future<void> _onCreateSubject(CreateSubjectEvent event, Emitter<StudyState> emit) async {
    try {
      final subject = Subject(id: _uuid.v4(), name: event.name, createdAt: DateTime.now());
      await repository.createSubject(subject);
      emit(state.copyWith(subjects: [...state.subjects, subject], error: null));
    } catch (e) {
      emit(state.copyWith(error: 'Błąd tworzenia: $e'));
    }
  }

  Future<void> _onDeleteSubject(DeleteSubjectEvent event, Emitter<StudyState> emit) async {
    try {
      await repository.deleteSubject(event.subjectId);
      final updated = state.subjects.where((s) => s.id != event.subjectId).toList();
      final stillActive = state.activeSubject?.id != event.subjectId;
      emit(state.copyWith(
        subjects: updated,
        activeSubject: stillActive ? state.activeSubject : null,
        appMode: stillActive ? state.appMode : AppMode.subjects,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: 'Błąd usuwania: $e'));
    }
  }

  Future<void> _onSelectSubject(SelectSubjectEvent event, Emitter<StudyState> emit) async {
    try {
      final subject = state.subjects.firstWhere((s) => s.id == event.subjectId);
      final messages = await repository.getMessages(event.subjectId);
      emit(state.copyWith(
        activeSubject: subject,
        chatMessages: messages,
        appMode: AppMode.chat,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: 'Błąd wyboru: $e'));
    }
  }

  // ── Upload ─────────────────────────────────────────────────────────────────

  Future<void> _onUploadPdf(UploadPdfEvent event, Emitter<StudyState> emit) async {
    emit(state.copyWith(isLoadingChat: true, error: null));
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );
      if (result?.files.single.bytes == null) {
        emit(state.copyWith(isLoadingChat: false));
        return;
      }

      final extractedText = await repository.extractPdfText(result!.files.single.bytes!);
      if (extractedText == null) throw Exception('Nie można wyciągnąć tekstu z PDF');

      if (state.activeSubject != null) {
        final updatedSubject = state.activeSubject!.copyWith(extractedText: extractedText);
        await repository.updateSubject(updatedSubject);

        final welcomeMsg = Message(
          id: _uuid.v4(),
          subjectId: state.activeSubject!.id,
          role: MessageRole.ai,
          content: '✅ PDF wczytany! Możesz teraz pytać o zawartość lub generować fiszki i quizy.',
          timestamp: DateTime.now(),
        );
        await repository.saveMessage(welcomeMsg);

        emit(state.copyWith(
          isLoadingChat: false,
          activeSubject: updatedSubject,
          subjects: state.subjects.map((s) => s.id == updatedSubject.id ? updatedSubject : s).toList(),
          chatMessages: [...state.chatMessages, welcomeMsg],
        ));
      }
    } catch (e) {
      emit(state.copyWith(isLoadingChat: false, error: 'Błąd PDF: $e'));
    }
  }

  Future<void> _onUploadImage(UploadImageEvent event, Emitter<StudyState> emit) async {
    emit(state.copyWith(isLoadingChat: true, error: null));
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null) {
        emit(state.copyWith(isLoadingChat: false));
        return;
      }

      final bytes = await picked.readAsBytes();
      final extractedText = await repository.extractImageText(bytes);
      if (extractedText == null) throw Exception('Nie można wyciągnąć tekstu z obrazu');

      if (state.activeSubject != null) {
        final updatedSubject = state.activeSubject!.copyWith(extractedText: extractedText);
        await repository.updateSubject(updatedSubject);

        final welcomeMsg = Message(
          id: _uuid.v4(),
          subjectId: state.activeSubject!.id,
          role: MessageRole.ai,
          content: '✅ Zdjęcie notatek przetworzone! Możesz teraz pytać o zawartość.',
          timestamp: DateTime.now(),
        );
        await repository.saveMessage(welcomeMsg);

        emit(state.copyWith(
          isLoadingChat: false,
          activeSubject: updatedSubject,
          subjects: state.subjects.map((s) => s.id == updatedSubject.id ? updatedSubject : s).toList(),
          chatMessages: [...state.chatMessages, welcomeMsg],
        ));
      }
    } catch (e) {
      emit(state.copyWith(isLoadingChat: false, error: 'Błąd zdjęcia: $e'));
    }
  }

  // ── Chat ze streamingiem ───────────────────────────────────────────────────

  Future<void> _onAskQuestion(AskQuestionEvent event, Emitter<StudyState> emit) async {
    if (state.activeSubject?.extractedText == null) {
      emit(state.copyWith(error: 'Najpierw wgraj materiał!'));
      return;
    }

    // Dodaj wiadomość użytkownika od razu
    final userMsg = Message(
      id: _uuid.v4(),
      subjectId: state.activeSubject!.id,
      role: MessageRole.user,
      content: event.question,
      timestamp: DateTime.now(),
    );
    await repository.saveMessage(userMsg);
    final messagesWithUser = [...state.chatMessages, userMsg];

    emit(state.copyWith(
      chatMessages: messagesWithUser,
      streamingContent: '',
      isLoadingChat: true,
      error: null,
    ));

    final buffer = StringBuffer();

    try {
      await emit.forEach<String>(
        repository.streamQuestion(
          state.activeSubject!.extractedText!,
          event.question,
        ),
        onData: (chunk) {
          buffer.write(chunk);
          return state.copyWith(
            chatMessages: messagesWithUser,
            streamingContent: buffer.toString(),
            isLoadingChat: true,
          );
        },
        onError: (_, __) => state.copyWith(
          chatMessages: messagesWithUser,
          clearStreaming: true,
          isLoadingChat: false,
          error: 'Błąd streamowania',
        ),
      );

      // Stream zakończony — zapisz wiadomość AI
      final aiMsg = Message(
        id: _uuid.v4(),
        subjectId: state.activeSubject!.id,
        role: MessageRole.ai,
        content: buffer.toString(),
        timestamp: DateTime.now(),
      );
      await repository.saveMessage(aiMsg);

      emit(state.copyWith(
        chatMessages: [...messagesWithUser, aiMsg],
        clearStreaming: true,
        isLoadingChat: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        chatMessages: messagesWithUser,
        clearStreaming: true,
        isLoadingChat: false,
        error: 'Błąd AI: $e',
      ));
    }
  }

  // ── Fiszki ─────────────────────────────────────────────────────────────────

  Future<void> _onGenerateFlashcards(GenerateFlashcardsEvent event, Emitter<StudyState> emit) async {
    if (state.activeSubject?.extractedText == null) {
      emit(state.copyWith(error: 'Najpierw wgraj materiał!'));
      return;
    }
    emit(state.copyWith(isLoadingChat: true, error: null, appMode: AppMode.flashcards));
    try {
      final flashcards = await repository.generateFlashcards(
        state.activeSubject!.id,
        state.activeSubject!.extractedText!,
      );
      emit(state.copyWith(isLoadingChat: false, flashcards: flashcards, currentFlashcardIndex: 0));
    } catch (e) {
      emit(state.copyWith(isLoadingChat: false, appMode: AppMode.chat, error: 'Błąd fiszek: $e'));
    }
  }

  void _onToggleFlashcard(ToggleFlashcardEvent event, Emitter<StudyState> emit) {}

  void _onNextFlashcard(NextFlashcardEvent event, Emitter<StudyState> emit) {
    if (state.currentFlashcardIndex < state.flashcards.length - 1) {
      emit(state.copyWith(currentFlashcardIndex: state.currentFlashcardIndex + 1));
    }
  }

  void _onPreviousFlashcard(PreviousFlashcardEvent event, Emitter<StudyState> emit) {
    if (state.currentFlashcardIndex > 0) {
      emit(state.copyWith(currentFlashcardIndex: state.currentFlashcardIndex - 1));
    }
  }

  // ── Quiz ───────────────────────────────────────────────────────────────────

  Future<void> _onGenerateQuiz(GenerateQuizEvent event, Emitter<StudyState> emit) async {
    if (state.activeSubject?.extractedText == null) {
      emit(state.copyWith(error: 'Najpierw wgraj materiał!'));
      return;
    }
    emit(state.copyWith(isLoadingChat: true, error: null, appMode: AppMode.quiz));
    try {
      final questions = await repository.generateQuiz(
        state.activeSubject!.id,
        state.activeSubject!.extractedText!,
      );
      emit(state.copyWith(
        isLoadingChat: false,
        quizQuestions: questions,
        currentQuizIndex: 0,
        selectedQuizAnswer: null,
        quizAnswerRevealed: false,
        quizScore: 0,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingChat: false, appMode: AppMode.chat, error: 'Błąd quizu: $e'));
    }
  }

  void _onAnswerQuiz(AnswerQuizEvent event, Emitter<StudyState> emit) {
    final question = state.quizQuestions[state.currentQuizIndex];
    final isCorrect = event.selectedIndex == question.correctIndex;
    emit(state.copyWith(
      selectedQuizAnswer: event.selectedIndex,
      quizAnswerRevealed: true,
      quizScore: isCorrect ? state.quizScore + 1 : state.quizScore,
    ));
  }

  void _onNextQuestion(NextQuestionEvent event, Emitter<StudyState> emit) {
    if (state.currentQuizIndex < state.quizQuestions.length - 1) {
      emit(state.copyWith(
        currentQuizIndex: state.currentQuizIndex + 1,
        selectedQuizAnswer: null,
        quizAnswerRevealed: false,
      ));
    }
  }

  // ── Tryb odpytywania ───────────────────────────────────────────────────────

  Future<void> _onStartExamMode(StartExamModeEvent event, Emitter<StudyState> emit) async {
    if (state.activeSubject?.extractedText == null) {
      emit(state.copyWith(error: 'Najpierw wgraj materiał!'));
      return;
    }

    emit(state.copyWith(
      appMode: AppMode.examMode,
      examModeActive: true,
      examHistory: const [],
      isLoadingChat: true,
      error: null,
    ));

    try {
      // AI zadaje pierwsze pytanie
      final firstQuestion = await repository.askExamQuestion(
        subjectId: state.activeSubject!.id,
        extractedText: state.activeSubject!.extractedText!,
        history: const [],
        userAnswer: '',
      );

      final messages = await repository.getMessages(state.activeSubject!.id);
      final examMessages = messages.where((m) =>
        m.timestamp.isAfter(DateTime.now().subtract(const Duration(seconds: 10)))
      ).toList();

      emit(state.copyWith(
        isLoadingChat: false,
        examHistory: examMessages.isEmpty
            ? [Message(
                id: 'exam_start',
                subjectId: state.activeSubject!.id,
                role: MessageRole.ai,
                content: firstQuestion,
                timestamp: DateTime.now(),
              )]
            : examMessages,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingChat: false, error: 'Błąd startu egzaminu: $e'));
    }
  }

  Future<void> _onAnswerExamQuestion(AnswerExamQuestionEvent event, Emitter<StudyState> emit) async {
    if (state.activeSubject?.extractedText == null) return;

    emit(state.copyWith(isLoadingChat: true, error: null));
    try {
      final history = state.examHistory.map((m) => {
        'role': m.role == MessageRole.user ? 'user' : 'assistant',
        'content': m.content,
      }).toList();

      await repository.askExamQuestion(
        subjectId: state.activeSubject!.id,
        extractedText: state.activeSubject!.extractedText!,
        history: history,
        userAnswer: event.answer,
      );

      final messages = await repository.getMessages(state.activeSubject!.id);
      emit(state.copyWith(isLoadingChat: false, examHistory: messages));
    } catch (e) {
      emit(state.copyWith(isLoadingChat: false, error: 'Błąd egzaminu: $e'));
    }
  }

  void _onExitMode(ExitModeEvent event, Emitter<StudyState> emit) {
    emit(state.copyWith(appMode: AppMode.chat, examModeActive: false));
  }

  void _onBackToSubjects(BackToSubjectsEvent event, Emitter<StudyState> emit) {
    emit(StudyState(subjects: state.subjects));
  }
}
