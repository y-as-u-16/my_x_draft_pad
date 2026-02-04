import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/draft_entity.dart';

class DraftListItem extends StatelessWidget {
  final DraftEntity draft;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const DraftListItem({
    super.key,
    required this.draft,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Dismissible(
      key: Key('draft_${draft.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppDimens.paddingLarge),
        color: AppColors.warning,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete?.call(),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('削除確認'),
                content: const Text('この下書きを削除しますか？'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('キャンセル'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      '削除',
                      style: TextStyle(color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ) ??
            false;
      },
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingMedium,
            vertical: AppDimens.paddingMedium,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: borderColor, width: AppDimens.borderWidth),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      draft.preview.isEmpty ? '(空の下書き)' : draft.preview,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimens.paddingXSmall),
                    Text(
                      DateFormatter.formatDateTime(draft.updatedAt),
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: textSecondary,
                size: AppDimens.iconMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
