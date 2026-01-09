import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/di/injection_container.dart';
import '../../core/utils/neumorphic_decorations.dart';
import '../../domain/entities/draft_entity.dart';
import '../../domain/usecases/draft_usecases.dart';
import '../../domain/usecases/settings_usecases.dart';
import '../../ads/ad_manager.dart';
import '../viewmodels/draft_edit_viewmodel.dart';
import '../widgets/neumorphic_button.dart';
import '../widgets/neumorphic_text_field_shell.dart';
import '../widgets/character_counter.dart';

class DraftEditScreen extends StatelessWidget {
  final DraftEntity? draft;

  const DraftEditScreen({super.key, this.draft});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DraftEditViewModel(
        createDraftUseCase: sl<CreateDraftUseCase>(),
        updateDraftUseCase: sl<UpdateDraftUseCase>(),
        getSettingsUseCase: sl<GetSettingsUseCase>(),
        initialDraft: draft,
      )..loadSettings(),
      child: const _DraftEditScreenContent(),
    );
  }
}

class _DraftEditScreenContent extends StatefulWidget {
  const _DraftEditScreenContent();

  @override
  State<_DraftEditScreenContent> createState() =>
      _DraftEditScreenContentState();
}

class _DraftEditScreenContentState extends State<_DraftEditScreenContent> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<DraftEditViewModel>();
    _controller = TextEditingController(text: viewModel.content);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _shareToX(BuildContext context, Rect sharePositionOrigin) async {
    final viewModel = context.read<DraftEditViewModel>();
    final content = viewModel.content;

    if (content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('テキストを入力してください')));
      return;
    }

    if (viewModel.hasChanges) {
      await viewModel.saveDraft();
    }

    await Share.share(content, sharePositionOrigin: sharePositionOrigin);
  }

  Future<bool> _onWillPop(BuildContext context) async {
    final viewModel = context.read<DraftEditViewModel>();

    if (viewModel.hasChanges) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('保存確認'),
          content: const Text('変更を保存しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('保存しない'),
            ),
            TextButton(
              onPressed: () async {
                await viewModel.saveDraft();
                if (context.mounted) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      );
      return result ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    return Consumer<DraftEditViewModel>(
      builder: (context, viewModel, child) {
        return PopScope(
          canPop: !viewModel.hasChanges,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final shouldPop = await _onWillPop(context);
            if (shouldPop && context.mounted) {
              context.pop(true);
            }
          },
          child: Scaffold(
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
                          onPressed: () async {
                            final shouldPop = await _onWillPop(context);
                            if (shouldPop && context.mounted) {
                              context.pop(true);
                            }
                          },
                          padding: const EdgeInsets.all(AppDimens.paddingSmall),
                          borderRadius: AppDimens.radiusSmall,
                          child: Icon(
                            Icons.arrow_back,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          viewModel.isEditing ? '編集' : '新規作成',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        NeumorphicButton(
                          onPressed: () async {
                            final success = await viewModel.saveDraft();
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('保存しました'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                          padding: const EdgeInsets.all(AppDimens.paddingSmall),
                          borderRadius: AppDimens.radiusSmall,
                          child: Icon(
                            Icons.save,
                            color: viewModel.hasChanges
                                ? AppColors.accent
                                : (isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Text Field
                  Expanded(
                    child: NeumorphicTextFieldShell(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppDimens.paddingMedium,
                      ),
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        expands: true,
                        autofocus: !viewModel.isEditing,
                        onChanged: viewModel.updateContent,
                        textAlignVertical: TextAlignVertical.top,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                          fontSize: 16,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: 'ここに下書きを入力...',
                          hintStyle: TextStyle(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                  // Character Counter
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.paddingMedium,
                      vertical: AppDimens.paddingSmall,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CharacterCounter(
                          currentLength: viewModel.currentLength,
                          maxLength: viewModel.maxLength,
                        ),
                      ],
                    ),
                  ),
                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.all(AppDimens.paddingMedium),
                    child: Row(
                      children: [
                        Expanded(
                          child: NeumorphicButton(
                            onPressed: () async {
                              final success = await viewModel.saveDraft();
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('保存しました'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.save,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                ),
                                const SizedBox(width: AppDimens.paddingSmall),
                                Text(
                                  '保存',
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimens.paddingMedium),
                        Expanded(
                          child: Builder(
                            builder: (buttonContext) {
                              return NeumorphicButton(
                                onPressed: () {
                                  final box =
                                      buttonContext.findRenderObject()
                                          as RenderBox;
                                  final position = box.localToGlobal(
                                    Offset.zero,
                                  );
                                  final sharePositionOrigin = Rect.fromLTWH(
                                    position.dx,
                                    position.dy,
                                    box.size.width,
                                    box.size.height,
                                  );
                                  _shareToX(buttonContext, sharePositionOrigin);
                                },
                                isAccent: true,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.share, color: Colors.white),
                                    SizedBox(width: AppDimens.paddingSmall),
                                    Text(
                                      'Xで投稿',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Ad Banner
                  AdManager.buildBannerAdWidget(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
