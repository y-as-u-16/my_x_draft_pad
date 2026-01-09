import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/di/injection_container.dart';
import '../../core/utils/neumorphic_decorations.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../widgets/neumorphic_button.dart';
import '../widgets/neumorphic_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<SettingsViewModel>()..loadSettings(),
      child: const _SettingsScreenContent(),
    );
  }
}

class _SettingsScreenContent extends StatefulWidget {
  const _SettingsScreenContent();

  @override
  State<_SettingsScreenContent> createState() => _SettingsScreenContentState();
}

class _SettingsScreenContentState extends State<_SettingsScreenContent> {
  final TextEditingController _maxLengthController = TextEditingController();

  @override
  void dispose() {
    _maxLengthController.dispose();
    super.dispose();
  }

  void _showMaxLengthDialog(BuildContext context, SettingsViewModel viewModel) {
    _maxLengthController.text = viewModel.maxLength.toString();
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
                viewModel.saveMaxLength(value);
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

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
                    onPressed: () => context.pop(),
                    padding: const EdgeInsets.all(AppDimens.paddingSmall),
                    borderRadius: AppDimens.radiusSmall,
                    child: Icon(
                      Icons.arrow_back,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingMedium),
                  Text(
                    '設定',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Settings List
            Expanded(
              child: Consumer<SettingsViewModel>(
                builder: (context, viewModel, child) {
                  return ListView(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppDimens.paddingSmall),
                    children: [
                      // Max Length Setting
                      NeumorphicCard(
                        onTap: () => _showMaxLengthDialog(context, viewModel),
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
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: AppDimens.paddingXSmall),
                                  Text(
                                    'Xの投稿上限に合わせて設定',
                                    style: TextStyle(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${viewModel.maxLength}',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: AppDimens.paddingSmall),
                            Icon(
                              Icons.chevron_right,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                      // Theme Toggle
                      Consumer<ThemeViewModel>(
                        builder: (context, themeViewModel, child) {
                          return NeumorphicCard(
                            child: Row(
                              children: [
                                Icon(
                                  themeViewModel.isDarkMode
                                      ? Icons.dark_mode
                                      : Icons.light_mode,
                                  color: AppColors.accent,
                                ),
                                const SizedBox(width: AppDimens.paddingMedium),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ダークモード',
                                        style: TextStyle(
                                          color: isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(
                                          height: AppDimens.paddingXSmall),
                                      Text(
                                        '画面の表示テーマを切り替え',
                                        style: TextStyle(
                                          color: isDark
                                              ? AppColors.textSecondaryDark
                                              : AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: themeViewModel.isDarkMode,
                                  onChanged: themeViewModel.setThemeMode,
                                  activeTrackColor:
                                      AppColors.accent.withValues(alpha: 0.5),
                                  activeThumbColor: AppColors.accent,
                                ),
                              ],
                            ),
                          );
                        },
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
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: AppDimens.paddingXSmall),
                                  Text(
                                    'バージョン 1.0.0',
                                    style: TextStyle(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}