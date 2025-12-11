import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/utils/neumorphic_decorations.dart';
import '../../data/db/draft_dao.dart';
import '../../data/models/draft.dart';
import '../../ads/ad_manager.dart';
import '../widgets/draft_list_item.dart';
import '../widgets/neumorphic_button.dart';
import 'draft_edit_screen.dart';
import 'settings_screen.dart';

class DraftListScreen extends StatefulWidget {
  const DraftListScreen({super.key});

  @override
  State<DraftListScreen> createState() => _DraftListScreenState();
}

class _DraftListScreenState extends State<DraftListScreen> {
  final DraftDao _draftDao = DraftDaoImpl();
  List<Draft> _drafts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    setState(() => _isLoading = true);
    try {
      final drafts = await _draftDao.getAllDrafts();
      setState(() {
        _drafts = drafts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteDraft(int id) async {
    await _draftDao.deleteDraft(id);
    await _loadDrafts();
  }

  void _navigateToEdit({Draft? draft}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DraftEditScreen(draft: draft),
      ),
    );
    if (result == true) {
      await _loadDrafts();
    }
  }

  void _navigateToSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
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
                horizontal: AppDimens.paddingMedium,
                vertical: AppDimens.paddingSmall,
              ),
              decoration: NeumorphicDecorations.raised(
                isDark: isDark,
                borderRadius: AppDimens.radiusMedium,
              ),
              child: Row(
                children: [
                  Text(
                    'X Draft Pad',
                    style: TextStyle(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  NeumorphicButton(
                    onPressed: _navigateToSettings,
                    padding: const EdgeInsets.all(AppDimens.paddingSmall),
                    borderRadius: AppDimens.radiusSmall,
                    child: Icon(
                      Icons.settings,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _drafts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.note_add,
                                size: 64,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                              const SizedBox(height: AppDimens.paddingMedium),
                              Text(
                                '下書きがありません',
                                style: TextStyle(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: AppDimens.paddingSmall),
                              Text(
                                '+ボタンで新規作成',
                                style: TextStyle(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadDrafts,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(
                              bottom: AppDimens.paddingXLarge + AppDimens.fabSize,
                            ),
                            itemCount: _drafts.length,
                            itemBuilder: (context, index) {
                              final draft = _drafts[index];
                              return DraftListItem(
                                draft: draft,
                                onTap: () => _navigateToEdit(draft: draft),
                                onDelete: () => _deleteDraft(draft.id!),
                              );
                            },
                          ),
                        ),
            ),
            // Ad Banner
            AdManager.buildBannerAdWidget(),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: NeumorphicDecorations.raised(
          isDark: isDark,
          borderRadius: AppDimens.radiusCircle,
        ),
        child: FloatingActionButton(
          onPressed: () => _navigateToEdit(),
          backgroundColor: AppColors.accent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}