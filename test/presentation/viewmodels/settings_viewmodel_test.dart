import 'package:flutter_test/flutter_test.dart';
import 'package:my_x_draft_pad/domain/entities/settings_entity.dart';
import 'package:my_x_draft_pad/domain/usecases/settings_usecases.dart';
import 'package:my_x_draft_pad/presentation/viewmodels/settings_viewmodel.dart';

import '../../mocks/mock_settings_repository.dart';

void main() {
  late MockSettingsRepository mockRepository;
  late GetSettingsUseCase getSettingsUseCase;
  late SaveMaxLengthUseCase saveMaxLengthUseCase;
  late SaveThemeModeUseCase saveThemeModeUseCase;
  late SettingsViewModel viewModel;

  setUp(() {
    mockRepository = MockSettingsRepository();
    getSettingsUseCase = GetSettingsUseCase(mockRepository);
    saveMaxLengthUseCase = SaveMaxLengthUseCase(mockRepository);
    saveThemeModeUseCase = SaveThemeModeUseCase(mockRepository);
    viewModel = SettingsViewModel(
      getSettingsUseCase: getSettingsUseCase,
      saveMaxLengthUseCase: saveMaxLengthUseCase,
      saveThemeModeUseCase: saveThemeModeUseCase,
    );
  });

  tearDown(() {
    mockRepository.reset();
    viewModel.dispose();
  });

  group('SettingsViewModel', () {
    group('初期状態', () {
      test('初期状態ではmaxLengthは280', () {
        expect(viewModel.maxLength, 280);
      });

      test('初期状態ではisDarkModeはfalse', () {
        expect(viewModel.isDarkMode, false);
      });

      test('初期状態ではisLoadingはfalse', () {
        expect(viewModel.isLoading, false);
      });

      test('初期状態ではerrorMessageはnull', () {
        expect(viewModel.errorMessage, isNull);
      });

      test('初期状態のsettingsはデフォルト値', () {
        expect(viewModel.settings.maxLength, 280);
        expect(viewModel.settings.isDarkMode, false);
      });
    });

    group('loadSettings', () {
      group('正常系', () {
        test('設定を読み込むとmaxLengthが更新される', () async {
          mockRepository.setSettings(const SettingsEntity(
            maxLength: 500,
            isDarkMode: false,
          ));

          await viewModel.loadSettings();

          expect(viewModel.maxLength, 500);
        });

        test('設定を読み込むとisDarkModeが更新される', () async {
          mockRepository.setSettings(const SettingsEntity(
            maxLength: 280,
            isDarkMode: true,
          ));

          await viewModel.loadSettings();

          expect(viewModel.isDarkMode, true);
        });

        test('設定を読み込むとsettings全体が更新される', () async {
          mockRepository.setSettings(const SettingsEntity(
            maxLength: 140,
            isDarkMode: true,
          ));

          await viewModel.loadSettings();

          expect(viewModel.settings.maxLength, 140);
          expect(viewModel.settings.isDarkMode, true);
        });

        test('loadSettings後にisLoadingはfalseになる', () async {
          await viewModel.loadSettings();

          expect(viewModel.isLoading, false);
        });

        test('loadSettings後にerrorMessageはnullになる', () async {
          await viewModel.loadSettings();

          expect(viewModel.errorMessage, isNull);
        });
      });

      group('ローディング状態', () {
        test('loadSettings中はisLoadingがtrueになる', () async {
          var loadingStateObserved = false;

          viewModel.addListener(() {
            if (viewModel.isLoading) {
              loadingStateObserved = true;
            }
          });

          await viewModel.loadSettings();

          expect(loadingStateObserved, true);
        });
      });

      group('異常系', () {
        test('エラーが発生した場合はerrorMessageが設定される', () async {
          mockRepository.shouldThrowError = true;
          mockRepository.errorMessage = 'Failed to load settings';

          await viewModel.loadSettings();

          expect(viewModel.errorMessage, contains('Failed to load settings'));
        });

        test('エラーが発生してもisLoadingはfalseになる', () async {
          mockRepository.shouldThrowError = true;

          await viewModel.loadSettings();

          expect(viewModel.isLoading, false);
        });

        test('エラー後に再度loadSettingsが成功したらerrorMessageはクリアされる',
            () async {
          mockRepository.shouldThrowError = true;
          await viewModel.loadSettings();
          expect(viewModel.errorMessage, isNotNull);

          mockRepository.shouldThrowError = false;
          await viewModel.loadSettings();

          expect(viewModel.errorMessage, isNull);
        });
      });
    });

    group('saveMaxLength', () {
      group('正常系', () {
        test('maxLengthを保存できる', () async {
          await viewModel.saveMaxLength(500);

          expect(viewModel.maxLength, 500);
        });

        test('280文字に設定できる（X/Twitter標準）', () async {
          await viewModel.saveMaxLength(280);

          expect(viewModel.maxLength, 280);
        });

        test('140文字に設定できる（旧Twitter）', () async {
          await viewModel.saveMaxLength(140);

          expect(viewModel.maxLength, 140);
        });

        test('他の設定（isDarkMode）に影響を与えない', () async {
          mockRepository.setSettings(const SettingsEntity(
            maxLength: 280,
            isDarkMode: true,
          ));
          await viewModel.loadSettings();

          await viewModel.saveMaxLength(500);

          expect(viewModel.maxLength, 500);
          expect(viewModel.isDarkMode, true);
        });

        test('settingsプロパティも更新される', () async {
          await viewModel.saveMaxLength(999);

          expect(viewModel.settings.maxLength, 999);
        });
      });

      group('境界値', () {
        test('0を設定できる', () async {
          await viewModel.saveMaxLength(0);

          expect(viewModel.maxLength, 0);
        });

        test('1を設定できる', () async {
          await viewModel.saveMaxLength(1);

          expect(viewModel.maxLength, 1);
        });

        test('非常に大きな値を設定できる', () async {
          await viewModel.saveMaxLength(100000);

          expect(viewModel.maxLength, 100000);
        });
      });

      group('連続呼び出し', () {
        test('連続して設定を変更できる', () async {
          await viewModel.saveMaxLength(100);
          expect(viewModel.maxLength, 100);

          await viewModel.saveMaxLength(200);
          expect(viewModel.maxLength, 200);

          await viewModel.saveMaxLength(300);
          expect(viewModel.maxLength, 300);
        });
      });

      group('異常系', () {
        test('エラーが発生した場合はerrorMessageが設定される', () async {
          mockRepository.shouldThrowError = true;
          mockRepository.errorMessage = 'Save failed';

          await viewModel.saveMaxLength(500);

          expect(viewModel.errorMessage, contains('Save failed'));
        });
      });
    });

    group('saveThemeMode', () {
      group('正常系', () {
        test('ダークモードをtrueに設定できる', () async {
          await viewModel.saveThemeMode(true);

          expect(viewModel.isDarkMode, true);
        });

        test('ダークモードをfalseに設定できる', () async {
          mockRepository.setSettings(const SettingsEntity(
            maxLength: 280,
            isDarkMode: true,
          ));
          await viewModel.loadSettings();

          await viewModel.saveThemeMode(false);

          expect(viewModel.isDarkMode, false);
        });

        test('他の設定（maxLength）に影響を与えない', () async {
          mockRepository.setSettings(const SettingsEntity(
            maxLength: 500,
            isDarkMode: false,
          ));
          await viewModel.loadSettings();

          await viewModel.saveThemeMode(true);

          expect(viewModel.maxLength, 500);
          expect(viewModel.isDarkMode, true);
        });

        test('settingsプロパティも更新される', () async {
          await viewModel.saveThemeMode(true);

          expect(viewModel.settings.isDarkMode, true);
        });
      });

      group('トグル操作', () {
        test('false -> true -> false とトグルできる', () async {
          expect(viewModel.isDarkMode, false);

          await viewModel.saveThemeMode(true);
          expect(viewModel.isDarkMode, true);

          await viewModel.saveThemeMode(false);
          expect(viewModel.isDarkMode, false);
        });

        test('同じ値を設定しても問題ない', () async {
          await viewModel.saveThemeMode(false);
          await viewModel.saveThemeMode(false);
          await viewModel.saveThemeMode(false);

          expect(viewModel.isDarkMode, false);
        });
      });

      group('異常系', () {
        test('エラーが発生した場合はerrorMessageが設定される', () async {
          mockRepository.shouldThrowError = true;
          mockRepository.errorMessage = 'Theme save failed';

          await viewModel.saveThemeMode(true);

          expect(viewModel.errorMessage, contains('Theme save failed'));
        });
      });
    });

    group('リスナー通知', () {
      test('loadSettingsでリスナーが通知される', () async {
        var notifyCount = 0;
        viewModel.addListener(() {
          notifyCount++;
        });

        await viewModel.loadSettings();

        // 最低でも2回（loading開始時と完了時）
        expect(notifyCount, greaterThanOrEqualTo(2));
      });

      test('saveMaxLengthでリスナーが通知される', () async {
        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        await viewModel.saveMaxLength(500);

        expect(notified, true);
      });

      test('saveThemeModeでリスナーが通知される', () async {
        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        await viewModel.saveThemeMode(true);

        expect(notified, true);
      });

      test('エラー発生時もリスナーが通知される', () async {
        mockRepository.shouldThrowError = true;
        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        await viewModel.saveMaxLength(500);

        expect(notified, true);
      });
    });

    group('典型的なユースケース', () {
      test('アプリ起動時に設定を読み込む', () async {
        mockRepository.setSettings(const SettingsEntity(
          maxLength: 500,
          isDarkMode: true,
        ));

        await viewModel.loadSettings();

        expect(viewModel.maxLength, 500);
        expect(viewModel.isDarkMode, true);
        expect(viewModel.isLoading, false);
      });

      test('ユーザーがダークモードをオンにする', () async {
        expect(viewModel.isDarkMode, false);

        await viewModel.saveThemeMode(true);

        expect(viewModel.isDarkMode, true);
      });

      test('ユーザーが文字数制限を変更する', () async {
        expect(viewModel.maxLength, 280);

        await viewModel.saveMaxLength(140);

        expect(viewModel.maxLength, 140);
      });

      test('ユーザーが全ての設定をカスタマイズする', () async {
        // ダークモードを有効に
        await viewModel.saveThemeMode(true);
        // 文字数制限を変更
        await viewModel.saveMaxLength(4000);

        expect(viewModel.isDarkMode, true);
        expect(viewModel.maxLength, 4000);
      });

      test('設定画面を開いて閉じる（読み込みのみ）', () async {
        mockRepository.setSettings(const SettingsEntity(
          maxLength: 280,
          isDarkMode: false,
        ));

        // 設定画面を開く
        await viewModel.loadSettings();

        // 設定を確認
        expect(viewModel.maxLength, 280);
        expect(viewModel.isDarkMode, false);
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, isNull);
      });

      test('設定の変更を複数回行う', () async {
        await viewModel.loadSettings();

        // 文字数制限を何度か変更
        await viewModel.saveMaxLength(100);
        await viewModel.saveMaxLength(200);
        await viewModel.saveMaxLength(300);

        // テーマも変更
        await viewModel.saveThemeMode(true);
        await viewModel.saveThemeMode(false);
        await viewModel.saveThemeMode(true);

        // 最終的な状態
        expect(viewModel.maxLength, 300);
        expect(viewModel.isDarkMode, true);
      });
    });

    group('状態の整合性', () {
      test('settingsプロパティとmaxLength/isDarkModeは同期している', () async {
        mockRepository.setSettings(const SettingsEntity(
          maxLength: 999,
          isDarkMode: true,
        ));

        await viewModel.loadSettings();

        expect(viewModel.settings.maxLength, viewModel.maxLength);
        expect(viewModel.settings.isDarkMode, viewModel.isDarkMode);
      });

      test('saveMaxLength後もsettingsプロパティと同期している', () async {
        await viewModel.saveMaxLength(777);

        expect(viewModel.settings.maxLength, viewModel.maxLength);
        expect(viewModel.settings.maxLength, 777);
      });

      test('saveThemeMode後もsettingsプロパティと同期している', () async {
        await viewModel.saveThemeMode(true);

        expect(viewModel.settings.isDarkMode, viewModel.isDarkMode);
        expect(viewModel.settings.isDarkMode, true);
      });
    });
  });
}
