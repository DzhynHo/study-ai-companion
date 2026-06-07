import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/study_bloc.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudyBloc, StudyState>(
      builder: (context, state) {
        if (state.isLoadingChat) {
          return Scaffold(
            appBar: AppBar(title: const Text('❓ Quiz')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state.quizQuestions.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('❓ Quiz')),
            body: const Center(child: Text('Brak pytań quizowych')),
          );
        }

        final isDone = state.currentQuizIndex >= state.quizQuestions.length - 1 &&
            state.quizAnswerRevealed;

        if (isDone) {
          return _buildResultPage(context, state);
        }

        final question = state.quizQuestions[state.currentQuizIndex];
        final current = state.currentQuizIndex + 1;
        final total = state.quizQuestions.length;

        return Scaffold(
          appBar: AppBar(
            title: Text('❓ Quiz $current / $total'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.read<StudyBloc>().add(
                const ExitModeEvent(),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(value: current / total),
                const SizedBox(height: 24),
                Text(
                  'Pytanie $current',
                  style: TextStyle(
                    color: Colors.indigo.shade400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  question.question,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: question.options.length,
                    itemBuilder: (context, index) {
                      Color? bgColor;
                      if (state.quizAnswerRevealed) {
                        if (index == question.correctIndex) {
                          bgColor = Colors.green.shade100;
                        } else if (index == state.selectedQuizAnswer) {
                          bgColor = Colors.red.shade100;
                        }
                      }

                      return GestureDetector(
                        onTap: state.quizAnswerRevealed
                            ? null
                            : () => context.read<StudyBloc>().add(
                          AnswerQuizEvent(index),
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: bgColor ?? Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: state.quizAnswerRevealed &&
                                  index == question.correctIndex
                                  ? Colors.green
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.indigo.shade100,
                                child: Text(
                                  ['A', 'B', 'C', 'D'][index],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  question.options[index],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              if (state.quizAnswerRevealed &&
                                  index == question.correctIndex)
                                const Icon(Icons.check_circle, color: Colors.green)
                              else if (state.quizAnswerRevealed &&
                                  index == state.selectedQuizAnswer &&
                                  index != question.correctIndex)
                                const Icon(Icons.cancel, color: Colors.red),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                if (state.quizAnswerRevealed)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          context.read<StudyBloc>().add(const NextQuestionEvent()),
                      child: const Text('Następne pytanie'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultPage(BuildContext context, StudyState state) {
    final score = state.quizScore;
    final total = state.quizQuestions.length;
    final percent = ((score / total) * 100).toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wynik quizu'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.read<StudyBloc>().add(
            const ExitModeEvent(),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                int.parse(percent) >= 80 ? '🎉' : int.parse(percent) >= 50 ? '👍' : '📚',
                style: const TextStyle(fontSize: 72),
              ),
              const SizedBox(height: 24),
              Text(
                '$score / $total',
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '$percent% poprawnych odpowiedzi',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.replay),
                label: const Text('Powtórz quiz'),
                onPressed: () =>
                    context.read<StudyBloc>().add(const GenerateQuizEvent()),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.chat),
                label: const Text('Wróć do chatu'),
                onPressed: () =>
                    context.read<StudyBloc>().add(const ExitModeEvent()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
