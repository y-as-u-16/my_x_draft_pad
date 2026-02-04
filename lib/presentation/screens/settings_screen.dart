import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/di/injection_container.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/theme_viewmodel.dart';

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
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingSmall,
                vertical: AppDimens.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(
                  bottom: BorderSide(
                    color: borderColor,
                    width: AppDimens.borderWidth,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: textPrimary,
                      size: AppDimens.iconMedium,
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingSmall),
                  Text(
                    '設定',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
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
                    padding: EdgeInsets.zero,
                    children: [
                      // Section Header
                      Padding(
                        padding: const EdgeInsets.only(
                          left: AppDimens.paddingMedium,
                          top: AppDimens.paddingMedium,
                          bottom: AppDimens.paddingSmall,
                        ),
                        child: Text(
                          '一般',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Max Length Setting
                      _SettingsItem(
                        icon: Icons.text_fields,
                        title: '上限文字数',
                        subtitle: 'Xの投稿上限に合わせて設定',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${viewModel.maxLength}',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: AppDimens.paddingXSmall),
                            Icon(
                              Icons.chevron_right,
                              color: textSecondary,
                              size: AppDimens.iconMedium,
                            ),
                          ],
                        ),
                        onTap: () => _showMaxLengthDialog(context, viewModel),
                      ),
                      // Theme Toggle
                      Consumer<ThemeViewModel>(
                        builder: (context, themeViewModel, child) {
                          return _SettingsItem(
                            icon: themeViewModel.isDarkMode
                                ? Icons.dark_mode
                                : Icons.light_mode,
                            title: 'ダークモード',
                            subtitle: '画面の表示テーマを切り替え',
                            trailing: Switch(
                              value: themeViewModel.isDarkMode,
                              onChanged: themeViewModel.setThemeMode,
                            ),
                          );
                        },
                      ),
                      // Section Header
                      Padding(
                        padding: const EdgeInsets.only(
                          left: AppDimens.paddingMedium,
                          top: AppDimens.paddingLarge,
                          bottom: AppDimens.paddingSmall,
                        ),
                        child: Text(
                          'このアプリについて',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // App Info
                      _SettingsItem(
                        icon: Icons.info_outline,
                        title: 'X Draft Pad',
                        subtitle: 'バージョン 1.0.0',
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

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingMedium,
          vertical: AppDimens.paddingMedium,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: borderColor,
              width: AppDimens.borderWidth,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent, size: AppDimens.iconMedium),
            const SizedBox(width: AppDimens.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingXSmall),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
