import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/di/injection_container.dart';
import '../../core/router/app_router.dart';
import '../../domain/entities/draft_entity.dart';
import '../../ads/ad_manager.dart';
import '../viewmodels/draft_list_viewmodel.dart';
import '../widgets/draft_list_item.dart';

class DraftListScreen extends StatelessWidget {
  const DraftListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<DraftListViewModel>()..loadDrafts(),
      child: const _DraftListScreenContent(),
    );
  }
}

class _DraftListScreenContent extends StatelessWidget {
  const _DraftListScreenContent();

  void _navigateToEdit(BuildContext context, {DraftEntity? draft}) async {
    final result = await context.push<bool>(AppRoutes.edit, extra: draft);
    if (result == true && context.mounted) {
      context.read<DraftListViewModel>().loadDrafts();
    }
  }

  void _navigateToSettings(BuildContext context) {
    context.push(AppRoutes.settings);
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
                horizontal: AppDimens.paddingMedium,
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
                  Text(
                    'X Draft Pad',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _navigateToSettings(context),
                    icon: Icon(
                      Icons.settings,
                      color: textSecondary,
                      size: AppDimens.iconMedium,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Consumer<DraftListViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (viewModel.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.note_add,
                            size: 64,
                            color: textSecondary,
                          ),
                          const SizedBox(height: AppDimens.paddingMedium),
                          Text(
                            '下書きがありません',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: AppDimens.paddingSmall),
                          Text(
                            '+ボタンで新規作成',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: viewModel.loadDrafts,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(
                        bottom: AppDimens.paddingXLarge + AppDimens.fabSize,
                      ),
                      itemCount: viewModel.drafts.length,
                      itemBuilder: (context, index) {
                        final draft = viewModel.drafts[index];
                        return DraftListItem(
                          draft: draft,
                          onTap: () => _navigateToEdit(context, draft: draft),
                          onDelete: () => viewModel.deleteDraft(draft.id!),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            // Ad Banner
            AdManager.buildBannerAdWidget(),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: AppDimens.adBannerHeight),
        child: FloatingActionButton(
          onPressed: () => _navigateToEdit(context),
          backgroundColor: AppColors.accent,
          elevation: 0,
          highlightElevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
