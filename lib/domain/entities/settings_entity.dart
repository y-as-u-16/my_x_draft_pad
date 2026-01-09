class SettingsEntity {
  final int maxLength;
  final bool isDarkMode;

  const SettingsEntity({
    required this.maxLength,
    required this.isDarkMode,
  });

  SettingsEntity copyWith({
    int? maxLength,
    bool? isDarkMode,
  }) {
    return SettingsEntity(
      maxLength: maxLength ?? this.maxLength,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsEntity &&
          runtimeType == other.runtimeType &&
          maxLength == other.maxLength &&
          isDarkMode == other.isDarkMode;

  @override
  int get hashCode => maxLength.hashCode ^ isDarkMode.hashCode;
}