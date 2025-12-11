import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/db_constants.dart';
import '../../core/utils/neumorphic_decorations.dart';
import '../widgets/neumorphic_button.dart';
import '../widgets/neumorphic_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _maxLength = DbConstants.defaultMaxLength;
  bool _isDarkMode = false;
  final TextEditingController _maxLengthController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _maxLength = prefs.getInt(DbConstants.settingMaxLength) ?? DbConstants.defaultMaxLength;
      _isDarkMode = prefs.getBool(DbConstants.settingThemeMode) ?? false;
      _maxLengthController.text = _maxLength.toString();
    });
  }

  Future<void> _saveMaxLength(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(DbConstants.settingMaxLength, value);
    setState(() => _maxLength = value);
  }

  Future<void> _saveThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(DbConstants.settingThemeMode, isDark);
    setState(() => _isDarkMode = isDark);
  }

  void _showMaxLengthDialog() {
    _maxLengthController.text = _maxLength.toString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('上限文字数'),
        content: TextField(
          controller: _maxLengthController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: '例: 280',
            suffixText: '文字',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(_maxLengthController.text);
              if (value != null && value > 0) {
                _saveMaxLength(value);
                Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _maxLengthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Container(
              margin: const EdgeInsets.all(AppDimens.paddingMedium),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingSmall,
                vertical: AppDimens.paddingSmall,
              ),
              decoration: NeumorphicDecorations.raised(
                isDark: isDark,
                borderRadius: AppDimens.radiusMedium,
              ),
              child: Row(
                children: [
                  NeumorphicButton(
                    onPressed: () => Navigator.pop(context),
                    padding: const EdgeInsets.all(AppDimens.paddingSmall),
                    borderRadius: AppDimens.radiusSmall,
                    child: Icon(
                      Icons.arrow_back,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingMedium),
                  Text(
                    '設定',
                    style: TextStyle(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Settings List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingSmall),
                children: [
                  // Max Length Setting
                  NeumorphicCard(
                    onTap: _showMaxLengthDialog,
                    child: Row(
                      children: [
                        Icon(
                          Icons.text_fields,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: AppDimens.paddingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '上限文字数',
                                style: TextStyle(
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: AppDimens.paddingXSmall),
                              Text(
                                'Xの投稿上限に合わせて設定',
                                style: TextStyle(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '$_maxLength',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: AppDimens.paddingSmall),
                        Icon(
                          Icons.chevron_right,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  // Theme Toggle
                  NeumorphicCard(
                    child: Row(
                      children: [
                        Icon(
                          _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: AppDimens.paddingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ダークモード',
                                style: TextStyle(
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: AppDimens.paddingXSmall),
                              Text(
                                '画面の表示テーマを切り替え',
                                style: TextStyle(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isDarkMode,
                          onChanged: _saveThemeMode,
                          activeTrackColor: AppColors.accent.withValues(alpha: 0.5),
                          activeThumbColor: AppColors.accent,
                        ),
                      ],
                    ),
                  ),
                  // App Info
                  NeumorphicCard(
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: AppDimens.paddingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'X Draft Pad',
                                style: TextStyle(
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: AppDimens.paddingXSmall),
                              Text(
                                'バージョン 1.0.0',
                                style: TextStyle(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}