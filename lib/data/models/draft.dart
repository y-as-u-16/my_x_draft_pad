class Draft {
  final int? id;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  Draft({
    this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  Draft copyWith({
    int? id,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Draft(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Draft.fromMap(Map<String, dynamic> map) {
    return Draft(
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

  String get preview {
    if (content.isEmpty) return '';
    final lines = content.split('\n').first;
    if (lines.length > 30) {
      return '${lines.substring(0, 30)}...';
    }
    return lines.length < content.length ? '$lines...' : lines;
  }
}