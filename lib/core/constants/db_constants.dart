class DbConstants {
  DbConstants._();

  static const String databaseName = 'x_draft_pad.db';
  static const int databaseVersion = 1;

  // Table names
  static const String tableDrafts = 'drafts';
  static const String tableAppSettings = 'app_settings';

  // Drafts table columns
  static const String columnId = 'id';
  static const String columnContent = 'content';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  // App settings table columns
  static const String columnKey = 'key';
  static const String columnValue = 'value';

  // Settings keys
  static const String settingMaxLength = 'max_length';
  static const String settingThemeMode = 'theme_mode';

  // Default values
  static const int defaultMaxLength = 280;
}
