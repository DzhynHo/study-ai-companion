import 'package:equatable/equatable.dart';

class Subject extends Equatable {
  final String id;
  final String name;
  final String? extractedText;
  final DateTime createdAt;

  const Subject({
    required this.id,
    required this.name,
    this.extractedText,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, extractedText, createdAt];

  Subject copyWith({
    String? id,
    String? name,
    String? extractedText,
    DateTime? createdAt,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      extractedText: extractedText ?? this.extractedText,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
