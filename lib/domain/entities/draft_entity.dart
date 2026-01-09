class DraftEntity {
  final int? id;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DraftEntity({
    this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  DraftEntity copyWith({
    int? id,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DraftEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get preview {
    if (content.isEmpty) return '';
    final lines = content.split('\n').first;
    if (lines.length > 30) {
      return '${lines.substring(0, 30)}...';
    }
    return lines.length < content.length ? '$lines...' : lines;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DraftEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          content == other.content &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^ content.hashCode ^ createdAt.hashCode ^ updatedAt.hashCode;
}
