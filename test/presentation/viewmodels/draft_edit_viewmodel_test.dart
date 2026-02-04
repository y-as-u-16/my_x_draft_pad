import 'package:flutter_test/flutter_test.dart';
import 'package:my_x_draft_pad/domain/entities/draft_entity.dart';
import 'package:my_x_draft_pad/domain/entities/settings_entity.dart';
import 'package:my_x_draft_pad/domain/usecases/draft_usecases.dart';
import 'package:my_x_draft_pad/domain/usecases/settings_usecases.dart';
import 'package:my_x_draft_pad/presentation/viewmodels/draft_edit_viewmodel.dart';

import '../../mocks/mock_draft_repository.dart';
import '../../mocks/mock_settings_repository.dart';

void main() {
  late MockDraftRepository mockDraftRepository;
  late MockSettingsRepository mockSettingsRepository;
  late CreateDraftUseCase createDraftUseCase;
  late UpdateDraftUseCase updateDraftUseCase;
  late GetSettingsUseCase getSettingsUseCase;
  late DraftEditViewModel viewModel;
  final testDate = DateTime(2024, 1, 15, 10, 30);

  setUp(() {
    mockDraftRepository = MockDraftRepository();
    mockSettingsRepository = MockSettingsRepository();
    createDraftUseCase = CreateDraftUseCase(mockDraftRepository);
    updateDraftUseCase = UpdateDraftUseCase(mockDraftRepository);
    getSettingsUseCase = GetSettingsUseCase(mockSettingsRepository);
  });

  tearDown(() {
    mockDraftRepository.reset();
    mockSettingsRepository.reset();
    viewModel.dispose();
  });

  DraftEditViewModel createViewModel({DraftEntity? initialDraft}) {
    viewModel = DraftEditViewModel(
      createDraftUseCase: createDraftUseCase,
      updateDraftUseCase: updateDraftUseCase,
      getSettingsUseCase: getSettingsUseCase,
      initialDraft: initialDraft,
    );
    return viewModel;
  }

  group('DraftEditViewModel', () {
    group('初期状態（新規作成モード）', () {
      test('初期状態ではcontentは空文字', () {
        createViewModel();

        expect(viewModel.content, '');
      });

      test('初期状態ではmaxLengthはデフォルトの280', () {
        createViewModel();

        expect(viewModel.maxLength, 280);
      });

      test('初期状態ではhasChangesはfalse', () {
        createViewModel();

        expect(viewModel.hasChanges, false);
      });

      test('初期状態ではisSavingはfalse', () {
        createViewModel();

        expect(viewModel.isSaving, false);
      });

      test('初期状態ではerrorMessageはnull', () {
        createViewModel();

        expect(viewModel.errorMessage, isNull);
      });

      test('初期状態ではcurrentLengthは0', () {
        createViewModel();

        expect(viewModel.currentLength, 0);
      });

      test('初期状態ではisEditingはfalse（新規作成モード）', () {
        createViewModel();

        expect(viewModel.isEditing, false);
      });

      test('初期状態ではdraftはnull', () {
        createViewModel();

        expect(viewModel.draft, isNull);
      });
    });

    group('初期状態（編集モード）', () {
      late DraftEntity existingDraft;

      setUp(() {
        existingDraft = DraftEntity(
          id: 1,
          content: 'Existing content',
          createdAt: testDate,
          updatedAt: testDate,
        );
      });

      test('既存の下書きで初期化するとcontentが設定される', () {
        createViewModel(initialDraft: existingDraft);

        expect(viewModel.content, 'Existing content');
      });

      test('既存の下書きで初期化するとisEditingがtrue', () {
        createViewModel(initialDraft: existingDraft);

        expect(viewModel.isEditing, true);
      });

      test('既存の下書きで初期化するとdraftが設定される', () {
        createViewModel(initialDraft: existingDraft);

        expect(viewModel.draft, isNotNull);
        expect(viewModel.draft!.id, 1);
      });

      test('既存の下書きで初期化してもhasChangesはfalse', () {
        createViewModel(initialDraft: existingDraft);

        expect(viewModel.hasChanges, false);
      });

      test('既存の下書きでcurrentLengthが正しく計算される', () {
        createViewModel(initialDraft: existingDraft);

        expect(viewModel.currentLength, 'Existing content'.length);
      });
    });

    group('loadSettings', () {
      test('設定を読み込むとmaxLengthが更新される', () async {
        mockSettingsRepository.setSettings(const SettingsEntity(
          maxLength: 500,
          isDarkMode: false,
        ));
        createViewModel();

        await viewModel.loadSettings();

        expect(viewModel.maxLength, 500);
      });

      test('異なるmaxLengthを読み込める', () async {
        mockSettingsRepository.setSettings(const SettingsEntity(
          maxLength: 140,
          isDarkMode: true,
        ));
        createViewModel();

        await viewModel.loadSettings();

        expect(viewModel.maxLength, 140);
      });

      test('設定読み込みエラー時はerrorMessageが設定される', () async {
        mockSettingsRepository.shouldThrowError = true;
        mockSettingsRepository.errorMessage = 'Settings error';
        createViewModel();

        await viewModel.loadSettings();

        expect(viewModel.errorMessage, contains('Settings error'));
      });
    });

    group('updateContent', () {
      test('contentを更新できる', () {
        createViewModel();

        viewModel.updateContent('New content');

        expect(viewModel.content, 'New content');
      });

      test('updateContent後にhasChangesがtrueになる', () {
        createViewModel();

        viewModel.updateContent('Any text');

        expect(viewModel.hasChanges, true);
      });

      test('currentLengthが更新される', () {
        createViewModel();

        viewModel.updateContent('Hello');

        expect(viewModel.currentLength, 5);
      });

      test('空文字に更新できる', () {
        createViewModel();
        viewModel.updateContent('Some text');

        viewModel.updateContent('');

        expect(viewModel.content, '');
        expect(viewModel.currentLength, 0);
      });

      test('日本語のcurrentLengthが正しく計算される', () {
        createViewModel();

        viewModel.updateContent('こんにちは');

        expect(viewModel.currentLength, 5);
      });

      test('絵文字のcurrentLengthが正しく計算される（runesを使用）', () {
        createViewModel();

        viewModel.updateContent('👋🌍🎉');

        // runesを使用しているので絵文字は正しくカウントされる
        expect(viewModel.currentLength, 3);
      });

      test('絵文字と日本語の混合も正しくカウントされる', () {
        createViewModel();

        viewModel.updateContent('Hello👋世界🌍');

        // Hello(5) + 👋(1) + 世界(2) + 🌍(1) = 9
        expect(viewModel.currentLength, 9);
      });

      test('複数回更新してもhasChangesがtrueのまま', () {
        createViewModel();

        viewModel.updateContent('First');
        viewModel.updateContent('Second');
        viewModel.updateContent('Third');

        expect(viewModel.hasChanges, true);
      });

      test('notifyListenersが呼ばれる', () {
        createViewModel();
        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        viewModel.updateContent('Test');

        expect(notified, true);
      });
    });

    group('saveDraft（新規作成）', () {
      test('新規下書きを保存できる', () async {
        createViewModel();
        viewModel.updateContent('New draft content');

        final result = await viewModel.saveDraft();

        expect(result, true);
      });

      test('保存後にdraftが設定される', () async {
        createViewModel();
        viewModel.updateContent('New draft content');

        await viewModel.saveDraft();

        expect(viewModel.draft, isNotNull);
        expect(viewModel.draft!.id, isNotNull);
      });

      test('保存後にhasChangesがfalseになる', () async {
        createViewModel();
        viewModel.updateContent('New draft content');
        expect(viewModel.hasChanges, true);

        await viewModel.saveDraft();

        expect(viewModel.hasChanges, false);
      });

      test('保存中はisSavingがtrueになる', () async {
        createViewModel();
        viewModel.updateContent('Test');

        var savingStateObserved = false;
        viewModel.addListener(() {
          if (viewModel.isSaving) {
            savingStateObserved = true;
          }
        });

        await viewModel.saveDraft();

        expect(savingStateObserved, true);
      });

      test('保存完了後にisSavingがfalseになる', () async {
        createViewModel();
        viewModel.updateContent('Test');

        await viewModel.saveDraft();

        expect(viewModel.isSaving, false);
      });

      test('空のcontentでも保存できる', () async {
        createViewModel();
        viewModel.updateContent('');

        final result = await viewModel.saveDraft();

        expect(result, true);
      });
    });

    group('saveDraft（更新）', () {
      late DraftEntity existingDraft;

      setUp(() {
        existingDraft = DraftEntity(
          id: 1,
          content: 'Original content',
          createdAt: testDate,
          updatedAt: testDate,
        );
        mockDraftRepository.setDrafts([existingDraft]);
      });

      test('既存の下書きを更新できる', () async {
        createViewModel(initialDraft: existingDraft);
        viewModel.updateContent('Updated content');

        final result = await viewModel.saveDraft();

        expect(result, true);
      });

      test('更新後にdraftのcontentが更新される', () async {
        createViewModel(initialDraft: existingDraft);
        viewModel.updateContent('Updated content');

        await viewModel.saveDraft();

        expect(viewModel.draft!.content, 'Updated content');
      });

      test('更新後にhasChangesがfalseになる', () async {
        createViewModel(initialDraft: existingDraft);
        viewModel.updateContent('Updated content');

        await viewModel.saveDraft();

        expect(viewModel.hasChanges, false);
      });
    });

    group('saveDraft（エラー処理）', () {
      test('エラーが発生した場合はfalseを返す', () async {
        mockDraftRepository.shouldThrowError = true;
        createViewModel();
        viewModel.updateContent('Test');

        final result = await viewModel.saveDraft();

        expect(result, false);
      });

      test('エラーが発生した場合はerrorMessageが設定される', () async {
        mockDraftRepository.shouldThrowError = true;
        mockDraftRepository.errorMessage = 'Save failed';
        createViewModel();
        viewModel.updateContent('Test');

        await viewModel.saveDraft();

        expect(viewModel.errorMessage, contains('Save failed'));
      });

      test('エラーが発生してもisSavingはfalseになる', () async {
        mockDraftRepository.shouldThrowError = true;
        createViewModel();
        viewModel.updateContent('Test');

        await viewModel.saveDraft();

        expect(viewModel.isSaving, false);
      });
    });

    group('clearError', () {
      test('errorMessageをクリアできる', () async {
        mockDraftRepository.shouldThrowError = true;
        createViewModel();
        viewModel.updateContent('Test');
        await viewModel.saveDraft();
        expect(viewModel.errorMessage, isNotNull);

        viewModel.clearError();

        expect(viewModel.errorMessage, isNull);
      });

      test('clearError時にnotifyListenersが呼ばれる', () async {
        mockDraftRepository.shouldThrowError = true;
        createViewModel();
        viewModel.updateContent('Test');
        await viewModel.saveDraft();

        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        viewModel.clearError();

        expect(notified, true);
      });
    });

    group('典型的なユースケース', () {
      test('新規下書きを作成して保存する', () async {
        createViewModel();

        // 設定を読み込む
        await viewModel.loadSettings();
        expect(viewModel.maxLength, 280);

        // 下書きを入力
        viewModel.updateContent('This is my new tweet draft!');
        expect(viewModel.hasChanges, true);
        expect(viewModel.currentLength, 27);

        // 保存
        final result = await viewModel.saveDraft();
        expect(result, true);
        expect(viewModel.hasChanges, false);
        expect(viewModel.draft, isNotNull);
      });

      test('既存の下書きを編集して保存する', () async {
        final existingDraft = DraftEntity(
          id: 1,
          content: 'Original tweet',
          createdAt: testDate,
          updatedAt: testDate,
        );
        mockDraftRepository.setDrafts([existingDraft]);

        createViewModel(initialDraft: existingDraft);

        // 編集モードであることを確認
        expect(viewModel.isEditing, true);
        expect(viewModel.content, 'Original tweet');

        // 内容を変更
        viewModel.updateContent('Modified tweet content');
        expect(viewModel.hasChanges, true);

        // 保存
        final result = await viewModel.saveDraft();
        expect(result, true);
        expect(viewModel.draft!.content, 'Modified tweet content');
      });

      test('文字数制限を意識しながら入力する', () async {
        mockSettingsRepository.setSettings(const SettingsEntity(
          maxLength: 10,
          isDarkMode: false,
        ));

        createViewModel();
        await viewModel.loadSettings();

        // 文字数制限を確認
        expect(viewModel.maxLength, 10);

        // 制限内の入力
        viewModel.updateContent('Hello');
        expect(viewModel.currentLength, 5);
        expect(viewModel.currentLength <= viewModel.maxLength, true);

        // 制限を超える入力（UIでの制限は別レイヤー、ViewModelは文字数を報告するだけ）
        viewModel.updateContent('Hello World!');
        expect(viewModel.currentLength, 12);
        expect(viewModel.currentLength > viewModel.maxLength, true);
      });

      test('下書き入力中にエラーが発生しても入力内容は保持される', () async {
        createViewModel();
        viewModel.updateContent('Important draft content');

        mockDraftRepository.shouldThrowError = true;
        await viewModel.saveDraft();

        // エラーが発生
        expect(viewModel.errorMessage, isNotNull);
        // しかし入力内容は保持されている
        expect(viewModel.content, 'Important draft content');
        // 変更フラグも保持
        expect(viewModel.hasChanges, true);
      });
    });

    group('リスナー通知', () {
      test('updateContentでリスナーが通知される', () {
        createViewModel();
        var notifyCount = 0;
        viewModel.addListener(() {
          notifyCount++;
        });

        viewModel.updateContent('Test');

        expect(notifyCount, 1);
      });

      test('loadSettingsでリスナーが通知される', () async {
        createViewModel();
        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        await viewModel.loadSettings();

        expect(notified, true);
      });

      test('saveDraftで複数回リスナーが通知される', () async {
        createViewModel();
        viewModel.updateContent('Test');

        var notifyCount = 0;
        viewModel.addListener(() {
          notifyCount++;
        });

        await viewModel.saveDraft();

        // 保存開始時と完了時で最低2回
        expect(notifyCount, greaterThanOrEqualTo(2));
      });
    });
  });
}
