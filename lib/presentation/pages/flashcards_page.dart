import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/study_bloc.dart';

class FlashcardsPage extends StatefulWidget {
  const FlashcardsPage({super.key});

  @override
  State<FlashcardsPage> createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends State<FlashcardsPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleAnswer() {
    setState(() => _showAnswer = !_showAnswer);
    if (_showAnswer) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudyBloc, StudyState>(
      builder: (context, state) {
        if (state.isLoadingChat) {
          return Scaffold(
            appBar: AppBar(title: const Text('📇 Fiszki')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state.flashcards.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('📇 Fiszki')),
            body: const Center(
              child: Text('Brak fiszek. Wygeneruj je z materiałów.'),
            ),
          );
        }

        final card = state.flashcards[state.currentFlashcardIndex];
        final total = state.flashcards.length;
        final current = state.currentFlashcardIndex + 1;

        return Scaffold(
          appBar: AppBar(
            title: Text('📇 Fiszki $current / $total'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.read<StudyBloc>().add(
                const ExitModeEvent(),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                LinearProgressIndicator(value: current / total),
                const SizedBox(height: 32),
                Expanded(
                  child: GestureDetector(
                    onTap: _toggleAnswer,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: FlashcardWidget(
                        key: ValueKey(_showAnswer),
                        text: _showAnswer ? card.answer : card.question,
                        label: _showAnswer ? 'ODPOWIEDŹ' : 'PYTANIE',
                        isAnswer: _showAnswer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (!_showAnswer)
                  const Text(
                    'Dotknij kartę aby zobaczyć odpowiedź',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  const SizedBox.shrink(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Poprzednia'),
                      onPressed: current > 1
                          ? () => context.read<StudyBloc>().add(
                        const PreviousFlashcardEvent(),
                      )
                          : null,
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Następna'),
                      onPressed: current < total
                          ? () => context.read<StudyBloc>().add(
                        const NextFlashcardEvent(),
                      )
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FlashcardWidget extends StatelessWidget {
  final String text;
  final String label;
  final bool isAnswer;

  const FlashcardWidget({
    Key? key,
    required this.text,
    required this.label,
    required this.isAnswer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isAnswer
                ? [Colors.green.shade50, Colors.green.shade100]
                : [Colors.indigo.shade50, Colors.indigo.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isAnswer ? Icons.lightbulb : Icons.help_outline,
                  size: 48,
                  color: isAnswer ? Colors.green.shade600 : Colors.indigo.shade600,
                ),
                const SizedBox(height: 16),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: isAnswer
                        ? Colors.green.shade600
                        : Colors.indigo.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  text,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
