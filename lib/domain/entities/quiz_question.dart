import 'package:equatable/equatable.dart';

class QuizQuestion extends Equatable {
  final String id;
  final String subjectId;
  final String question;
  final List<String> options;
  final int correctIndex;
  final DateTime createdAt;

  const QuizQuestion({
    required this.id,
    required this.subjectId,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, subjectId, question, options, correctIndex, createdAt];

  Map<String, dynamic> toJson() => {
        'id': id,
        'subjectId': subjectId,
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
        'createdAt': createdAt.toIso8601String(),
      };

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        id: json['id'] as String,
        subjectId: json['subjectId'] as String,
        question: json['question'] as String,
        options: List<String>.from(json['options'] as List),
        correctIndex: json['correctIndex'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
