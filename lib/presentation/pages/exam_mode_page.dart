import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../bloc/study_bloc.dart';

class ExamModePage extends StatefulWidget {
  const ExamModePage({super.key});

  @override
  State<ExamModePage> createState() => _ExamModePageState();
}

class _ExamModePageState extends State<ExamModePage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendAnswer(BuildContext context) {
    if (_controller.text.trim().isEmpty) return;
    context.read<StudyBloc>().add(
      AnswerExamQuestionEvent(_controller.text.trim()),
    );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StudyBloc, StudyState>(
      listener: (context, state) {
        if (state.examHistory.isNotEmpty) _scrollToBottom();
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('🎓 Tryb odpytywania'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.read<StudyBloc>().add(
                const ExitModeEvent(),
              ),
            ),
          ),
          body: Column(
            children: [
              if (state.error != null)
                Container(
                  color: Colors.red.shade100,
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    state.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Expanded(
                child: state.examHistory.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.school_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Odpowiadaj na pytania AI',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'AI będzie Cię odpytywać z materiałów',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: state.examHistory.length,
                  itemBuilder: (context, index) {
                    final msg = state.examHistory[index];
                    final isUser = msg.role.toString().contains('user');

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser
                            ? Colors.indigo.shade100
                            : Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUser ? '👤 Ty' : '🎓 Egzaminator',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          MarkdownBody(
                            data: msg.content,
                            selectable: true,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (state.isLoadingChat)
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text('AI przygotowuje pytanie...'),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          enabled: !state.isLoadingChat,
                          decoration: InputDecoration(
                            hintText: 'Wpisz odpowiedź...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onSubmitted: (_) => _sendAnswer(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send),
                        color: Colors.indigo,
                        onPressed: () => _sendAnswer(context),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
