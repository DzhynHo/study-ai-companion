import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../bloc/study_bloc.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
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

  void _sendMessage(BuildContext context) {
    if (_controller.text.trim().isEmpty) return;
    context.read<StudyBloc>().add(AskQuestionEvent(_controller.text.trim()));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StudyBloc, StudyState>(
      listener: (context, state) {
        if (state.chatMessages.isNotEmpty) _scrollToBottom();
      },
      builder: (context, state) {
        final subjectName = state.activeSubject?.name ?? 'Przedmiot';

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.read<StudyBloc>().add(
                const BackToSubjectsEvent(),
              ),
            ),
            title: Text('💬 $subjectName'),
            actions: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                tooltip: 'Wgraj PDF',
                onPressed: () => context.read<StudyBloc>().add(
                  const UploadPdfEvent(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.image),
                tooltip: 'Wgraj zdjęcie',
                onPressed: () => context.read<StudyBloc>().add(
                  const UploadImageEvent(),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (state.activeSubject?.extractedText == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Najpierw wgraj materiał!')),
                    );
                    return;
                  }
                  switch (value) {
                    case 'flashcards':
                      context.read<StudyBloc>().add(
                        const GenerateFlashcardsEvent(),
                      );
                      break;
                    case 'quiz':
                      context.read<StudyBloc>().add(
                        const GenerateQuizEvent(),
                      );
                      break;
                    case 'exam':
                      context.read<StudyBloc>().add(
                        const StartExamModeEvent(),
                      );
                      break;
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'flashcards',
                    child: ListTile(
                      leading: Icon(Icons.style),
                      title: Text('📇 Fiszki'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'quiz',
                    child: ListTile(
                      leading: Icon(Icons.quiz),
                      title: Text('❓ Quiz'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'exam',
                    child: ListTile(
                      leading: Icon(Icons.record_voice_over),
                      title: Text('🎓 Tryb odpytywania'),
                    ),
                  ),
                ],
              ),
            ],
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
                child: state.chatMessages.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.upload_file_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Wgraj PDF lub zdjęcie notatek',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('PDF'),
                            onPressed: () => context.read<StudyBloc>().add(
                              const UploadPdfEvent(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.image),
                            label: const Text('Zdjęcie'),
                            onPressed: () => context.read<StudyBloc>().add(
                              const UploadImageEvent(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  // +1 dla bąbelka streamingu jeśli aktywny
                  itemCount: state.chatMessages.length +
                      (state.streamingContent != null ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Ostatni element = bąbelek streamingu
                    if (index == state.chatMessages.length &&
                        state.streamingContent != null) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.8,
                          ),
                          child: state.streamingContent!.isEmpty
                              ? const SizedBox(
                                  width: 40,
                                  child: LinearProgressIndicator(),
                                )
                              : MarkdownBody(
                                  data: state.streamingContent!,
                                  selectable: false,
                                ),
                        ),
                      );
                    }

                    final message = state.chatMessages[index];
                    final isUser = message.role.toString().contains('user');

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Colors.indigo.shade100
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),
                        child: MarkdownBody(
                          data: message.content,
                          selectable: false,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled: !state.isLoadingChat,
                        decoration: InputDecoration(
                          hintText: 'Zadaj pytanie do materiału...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: Colors.indigo,
                      onPressed: state.isLoadingChat ? null : () => _sendMessage(context),
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
