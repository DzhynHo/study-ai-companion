import 'package:equatable/equatable.dart';

class Flashcard extends Equatable {
  final String id;
  final String subjectId;
  final String question;
  final String answer;
  final bool isMarked;
  final DateTime createdAt;

  const Flashcard({
    required this.id,
    required this.subjectId,
    required this.question,
    required this.answer,
    this.isMarked = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, subjectId, question, answer, isMarked, createdAt];

  Flashcard copyWith({
    String? id,
    String? subjectId,
    String? question,
    String? answer,
    bool? isMarked,
    DateTime? createdAt,
  }) {
    return Flashcard(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      isMarked: isMarked ?? this.isMarked,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subjectId': subjectId,
        'question': question,
        'answer': answer,
        'isMarked': isMarked,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
        id: json['id'] as String,
        subjectId: json['subjectId'] as String,
        question: json['question'] as String,
        answer: json['answer'] as String,
        isMarked: json['isMarked'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
