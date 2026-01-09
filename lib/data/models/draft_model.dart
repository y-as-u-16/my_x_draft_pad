import '../../domain/entities/draft_entity.dart';

class DraftModel {
  final int? id;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  DraftModel({
    this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DraftModel.fromMap(Map<String, dynamic> map) {
    return DraftModel(
      id: map['id'] as int?,
      content: map['content'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory DraftModel.fromEntity(DraftEntity entity) {
    return DraftModel(
      id: entity.id,
      content: entity.content,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  DraftEntity toEntity() {
    return DraftEntity(
      id: id,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
