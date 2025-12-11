import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/db_constants.dart';
import '../../core/utils/neumorphic_decorations.dart';
import '../../data/db/draft_dao.dart';
import '../../data/models/draft.dart';
import '../../ads/ad_manager.dart';
import '../widgets/neumorphic_button.dart';
import '../widgets/neumorphic_text_field_shell.dart';
import '../widgets/character_counter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DraftEditScreen extends StatefulWidget {
  final Draft? draft;

  const DraftEditScreen({super.key, this.draft});

  @override
  State<DraftEditScreen> createState() => _DraftEditScreenState();
}

class _DraftEditScreenState extends State<DraftEditScreen> {
  final DraftDao _draftDao = DraftDaoImpl();
  final TextEditingController _controller = TextEditingController();
  int _maxLength = DbConstants.defaultMaxLength;
  int _currentLength = 0;
  bool _hasChanges = false;
  int? _draftId;

  @override
  void initState() {
    super.initState();
    _draftId = widget.draft?.id;
    _controller.text = widget.draft?.content ?? '';
    _currentLength = _controller.text.characters.length;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _maxLength = prefs.getInt(DbConstants.settingMaxLength) ?? DbConstants.defaultMaxLength;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    setState(() {
      _currentLength = value.characters.length;
      _hasChanges = true;
    });
  }

  Future<void> _saveDraft() async {
    final content = _controller.text;
    final now = DateTime.now();

    if (_draftId != null) {
      final draft = Draft(
        id: _draftId,
        content: content,
        createdAt: widget.draft!.createdAt,
        updatedAt: now,
      );
      await _draftDao.updateDraft(draft);
    } else {
      final draft = Draft(
        content: content,
        createdAt: now,
        updatedAt: now,
      );
      _draftId = await _draftDao.insertDraft(draft);
    }

    setState(() => _hasChanges = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('保存しました'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _shareToX(BuildContext context, Rect sharePositionOrigin) async {
    final content = _controller.text;
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('テキストを入力してください')),
      );
      return;
    }

    if (_hasChanges) {
      await _saveDraft();
    }

    await Share.share(
      content,
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  Future<bool> _onWillPop() async {
    if (_hasChanges) {
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
                await _saveDraft();
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
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop(true);
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
                        final shouldPop = await _onWillPop();
                        if (shouldPop && context.mounted) {
                          Navigator.of(context).pop(true);
                        }
                      },
                      padding: const EdgeInsets.all(AppDimens.paddingSmall),
                      borderRadius: AppDimens.radiusSmall,
                      child: Icon(
                        Icons.arrow_back,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _draftId != null ? '編集' : '新規作成',
                      style: TextStyle(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    NeumorphicButton(
                      onPressed: _saveDraft,
                      padding: const EdgeInsets.all(AppDimens.paddingSmall),
                      borderRadius: AppDimens.radiusSmall,
                      child: Icon(
                        Icons.save,
                        color: _hasChanges ? AppColors.accent : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              // Text Field
              Expanded(
                child: NeumorphicTextFieldShell(
                  margin: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium),
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    expands: true,
                    autofocus: widget.draft == null,
                    onChanged: _onTextChanged,
                    textAlignVertical: TextAlignVertical.top,
                    style: TextStyle(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText: 'ここに下書きを入力...',
                      hintStyle: TextStyle(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
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
                      currentLength: _currentLength,
                      maxLength: _maxLength,
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
                        onPressed: _saveDraft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.save,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                            const SizedBox(width: AppDimens.paddingSmall),
                            Text(
                              '保存',
                              style: TextStyle(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
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
                              final box = buttonContext.findRenderObject() as RenderBox;
                              final position = box.localToGlobal(Offset.zero);
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
  }
}