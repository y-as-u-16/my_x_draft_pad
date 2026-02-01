import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/di/injection_container.dart';
import '../../domain/entities/draft_entity.dart';
import '../../domain/usecases/draft_usecases.dart';
import '../../domain/usecases/settings_usecases.dart';
import '../../ads/ad_manager.dart';
import '../viewmodels/draft_edit_viewmodel.dart';
import '../widgets/pill_button.dart';
import '../widgets/circular_char_counter.dart';

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
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

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
                          onPressed: () async {
                            final shouldPop = await _onWillPop(context);
                            if (shouldPop && context.mounted) {
                              context.pop(true);
                            }
                          },
                          icon: Icon(
                            Icons.close,
                            color: textPrimary,
                            size: AppDimens.iconMedium,
                          ),
                        ),
                        const Spacer(),
                        PillButton(
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
                          child: const Text(
                            '保存',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Text Field
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
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
                          color: textPrimary,
                          fontSize: 16,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: 'ここに下書きを入力...',
                          hintStyle: TextStyle(color: textSecondary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.only(
                            top: AppDimens.paddingMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Bottom Toolbar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.paddingMedium,
                      vertical: AppDimens.paddingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      border: Border(
                        top: BorderSide(
                          color: borderColor,
                          width: AppDimens.borderWidth,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Builder(
                          builder: (buttonContext) {
                            return PillButton(
                              style: PillButtonStyle.outline,
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
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.share,
                                    size: 16,
                                    color: textPrimary,
                                  ),
                                  const SizedBox(width: AppDimens.paddingXSmall),
                                  Text(
                                    'Xで投稿',
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const Spacer(),
                        CircularCharCounter(
                          currentLength: viewModel.currentLength,
                          maxLength: viewModel.maxLength,
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
