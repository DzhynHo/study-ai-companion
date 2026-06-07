import 'package:equatable/equatable.dart';

enum MessageRole { user, ai }

class Message extends Equatable {
  final String id;
  final String subjectId;
  final MessageRole role;
  final String content;
  final DateTime timestamp;

  const Message({
    required this.id,
    required this.subjectId,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, subjectId, role, content, timestamp];

  Map<String, dynamic> toJson() => {
        'id': id,
        'subjectId': subjectId,
        'role': role.toString(),
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'] as String,
        subjectId: json['subjectId'] as String,
        role: (json['role'] as String).contains('user') ? MessageRole.user : MessageRole.ai,
        content: json['content'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
