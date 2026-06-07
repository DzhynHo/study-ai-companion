import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/study_bloc.dart';
import 'subjects_page.dart';
import 'chat_page.dart';
import 'flashcards_page.dart';
import 'quiz_page.dart';
import 'exam_mode_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudyBloc, StudyState>(
      builder: (context, state) {
        switch (state.appMode) {
          case AppMode.chat:
            return const ChatPage();
          case AppMode.flashcards:
            return const FlashcardsPage();
          case AppMode.quiz:
            return const QuizPage();
          case AppMode.examMode:
            return const ExamModePage();
          case AppMode.subjects:
          default:
            return const SubjectsPage();
        }
      },
    );
  }
}
