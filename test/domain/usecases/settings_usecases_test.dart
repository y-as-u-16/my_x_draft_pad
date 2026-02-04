import 'package:flutter_test/flutter_test.dart';
import 'package:my_x_draft_pad/domain/entities/settings_entity.dart';
import 'package:my_x_draft_pad/domain/repositories/settings_repository.dart';
import 'package:my_x_draft_pad/domain/usecases/settings_usecases.dart';

/// SettingsRepositoryのモック実装
class MockSettingsRepository implements SettingsRepository {
  SettingsEntity _settings = const SettingsEntity(
    maxLength: 280,
    isDarkMode: false,
  );
  bool shouldThrowError = false;
  String errorMessage = 'Mock error';

  void setSettings(SettingsEntity settings) {
    _settings = settings;
  }

  void reset() {
    _settings = const SettingsEntity(maxLength: 280, isDarkMode: false);
    shouldThrowError = false;
    errorMessage = 'Mock error';
  }

  @override
  Future<SettingsEntity> getSettings() async {
    if (shouldThrowError) throw Exception(errorMessage);
    return _settings;
  }

  @override
  Future<void> saveMaxLength(int maxLength) async {
    if (shouldThrowError) throw Exception(errorMessage);
    _settings = _settings.copyWith(maxLength: maxLength);
  }

  @override
  Future<void> saveThemeMode(bool isDarkMode) async {
    if (shouldThrowError) throw Exception(errorMessage);
    _settings = _settings.copyWith(isDarkMode: isDarkMode);
  }
}

void main() {
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
  });

  tearDown(() {
    mockRepository.reset();
  });

  group('GetSettingsUseCase', () {
    late GetSettingsUseCase useCase;

    setUp(() {
      useCase = GetSettingsUseCase(mockRepository);
    });

    group('正常系', () {
      test('デフォルト設定を取得できる', () async {
        final result = await useCase();

        expect(result.maxLength, 280);
        expect(result.isDarkMode, false);
      });

      test('カスタム設定を取得できる', () async {
        mockRepository.setSettings(const SettingsEntity(
          maxLength: 140,
          isDarkMode: true,
        ));

        final result = await useCase();

        expect(result.maxLength, 140);
        expect(result.isDarkMode, true);
      });

      test('ダークモードのみtrueの設定を取得できる', () async {
        mockRepository.setSettings(const SettingsEntity(
          maxLength: 280,
          isDarkMode: true,
        ));

        final result = await useCase();

        expect(result.maxLength, 280);
        expect(result.isDarkMode, true);
      });
    });

    group('境界値', () {
      test('maxLengthが0の設定を取得できる', () async {
        mockRepository.setSettings(const SettingsEntity(
          maxLength: 0,
          isDarkMode: false,
        ));

        final result = await useCase();

        expect(result.maxLength, 0);
      });

      test('maxLengthが大きな値の設定を取得できる', () async {
        mockRepository.setSettings(const SettingsEntity(
          maxLength: 100000,
          isDarkMode: false,
        ));

        final result = await useCase();

        expect(result.maxLength, 100000);
      });
    });

    group('異常系', () {
      test('エラーが発生した場合は例外をスローする', () async {
        mockRepository.shouldThrowError = true;
        mockRepository.errorMessage = 'Settings not found';

        expect(
          () => useCase(),
          throwsA(isA<Exception>()),
        );
      });
    });
  });

  group('SaveMaxLengthUseCase', () {
    late SaveMaxLengthUseCase useCase;

    setUp(() {
      useCase = SaveMaxLengthUseCase(mockRepository);
    });

    group('正常系', () {
      test('maxLengthを保存できる', () async {
        await useCase(500);

        final settings = await mockRepository.getSettings();
        expect(settings.maxLength, 500);
      });

      test('280文字に設定できる（X/Twitter標準）', () async {
        await useCase(280);

        final settings = await mockRepository.getSettings();
        expect(settings.maxLength, 280);
      });

      test('140文字に設定できる（旧Twitter）', () async {
        await useCase(140);

        final settings = await mockRepository.getSettings();
        expect(settings.maxLength, 140);
      });

      test('他の設定（isDarkMode）に影響を与えない', () async {
        mockRepository.setSettings(const SettingsEntity(
          maxLength: 280,
          isDarkMode: true,
        ));

        await useCase(500);

        final settings = await mockRepository.getSettings();
        expect(settings.maxLength, 500);
        expect(settings.isDarkMode, true);
      });
    });

    group('境界値', () {
      test('0を設定できる', () async {
        await useCase(0);

        final settings = await mockRepository.getSettings();
        expect(settings.maxLength, 0);
      });

      test('1を設定できる', () async {
        await useCase(1);

        final settings = await mockRepository.getSettings();
        expect(settings.maxLength, 1);
      });

      test('非常に大きな値を設定できる', () async {
        await useCase(1000000);

        final settings = await mockRepository.getSettings();
        expect(settings.maxLength, 1000000);
      });

      test('負の値も設定できる（バリデーションは別レイヤー）', () async {
        await useCase(-1);

        final settings = await mockRepository.getSettings();
        expect(settings.maxLength, -1);
      });
    });

    group('連続呼び出し', () {
      test('連続して設定を変更できる', () async {
        await useCase(100);
        var settings = await mockRepository.getSettings();
        expect(settings.maxLength, 100);

        await useCase(200);
        settings = await mockRepository.getSettings();
        expect(settings.maxLength, 200);

        await useCase(300);
        settings = await mockRepository.getSettings();
        expect(settings.maxLength, 300);
      });
    });

    group('異常系', () {
      test('エラーが発生した場合は例外をスローする', () async {
        mockRepository.shouldThrowError = true;

        expect(
          () => useCase(500),
          throwsA(isA<Exception>()),
        );
      });
    });
  });

  group('SaveThemeModeUseCase', () {
    late SaveThemeModeUseCase useCase;

    setUp(() {
      useCase = SaveThemeModeUseCase(mockRepository);
    });

    group('正常系', () {
      test('ダークモードをtrueに設定できる', () async {
        await useCase(true);

        final settings = await mockRepository.getSettings();
        expect(settings.isDarkMode, true);
      });

      test('ダークモードをfalseに設定できる', () async {
        mockRepository.setSettings(const SettingsEntity(
          maxLength: 280,
          isDarkMode: true,
        ));

        await useCase(false);

        final settings = await mockRepository.getSettings();
        expect(settings.isDarkMode, false);
      });

      test('他の設定（maxLength）に影響を与えない', () async {
        mockRepository.setSettings(const SettingsEntity(
          maxLength: 500,
          isDarkMode: false,
        ));

        await useCase(true);

        final settings = await mockRepository.getSettings();
        expect(settings.maxLength, 500);
        expect(settings.isDarkMode, true);
      });
    });

    group('トグル操作', () {
      test('false -> true -> false とトグルできる', () async {
        // 初期値はfalse
        var settings = await mockRepository.getSettings();
        expect(settings.isDarkMode, false);

        // trueに変更
        await useCase(true);
        settings = await mockRepository.getSettings();
        expect(settings.isDarkMode, true);

        // falseに戻す
        await useCase(false);
        settings = await mockRepository.getSettings();
        expect(settings.isDarkMode, false);
      });

      test('同じ値を設定しても問題ない', () async {
        await useCase(false);
        await useCase(false);
        await useCase(false);

        final settings = await mockRepository.getSettings();
        expect(settings.isDarkMode, false);
      });
    });

    group('異常系', () {
      test('エラーが発生した場合は例外をスローする', () async {
        mockRepository.shouldThrowError = true;

        expect(
          () => useCase(true),
          throwsA(isA<Exception>()),
        );
      });
    });
  });

  group('UseCase間の連携', () {
    test('GetSettings -> SaveMaxLength -> SaveThemeMode の一連の操作', () async {
      final getUseCase = GetSettingsUseCase(mockRepository);
      final saveMaxLengthUseCase = SaveMaxLengthUseCase(mockRepository);
      final saveThemeModeUseCase = SaveThemeModeUseCase(mockRepository);

      // 初期設定を取得
      var settings = await getUseCase();
      expect(settings.maxLength, 280);
      expect(settings.isDarkMode, false);

      // maxLengthを変更
      await saveMaxLengthUseCase(500);
      settings = await getUseCase();
      expect(settings.maxLength, 500);
      expect(settings.isDarkMode, false);

      // isDarkModeを変更
      await saveThemeModeUseCase(true);
      settings = await getUseCase();
      expect(settings.maxLength, 500);
      expect(settings.isDarkMode, true);

      // 両方の変更が保持されていることを確認
      final finalSettings = await getUseCase();
      expect(finalSettings.maxLength, 500);
      expect(finalSettings.isDarkMode, true);
    });

    test('複数回の設定変更が正しく反映される', () async {
      final saveMaxLengthUseCase = SaveMaxLengthUseCase(mockRepository);
      final saveThemeModeUseCase = SaveThemeModeUseCase(mockRepository);

      // 複数回の変更
      await saveMaxLengthUseCase(100);
      await saveThemeModeUseCase(true);
      await saveMaxLengthUseCase(200);
      await saveThemeModeUseCase(false);
      await saveMaxLengthUseCase(300);
      await saveThemeModeUseCase(true);

      final settings = await mockRepository.getSettings();
      expect(settings.maxLength, 300);
      expect(settings.isDarkMode, true);
    });
  });

  group('典型的なユーザーシナリオ', () {
    test('ユーザーが初回起動でデフォルト設定を取得する', () async {
      final getUseCase = GetSettingsUseCase(mockRepository);

      final settings = await getUseCase();

      expect(settings.maxLength, 280);
      expect(settings.isDarkMode, false);
    });

    test('ユーザーがダークモードを有効にする', () async {
      final getUseCase = GetSettingsUseCase(mockRepository);
      final saveThemeModeUseCase = SaveThemeModeUseCase(mockRepository);

      await saveThemeModeUseCase(true);
      final settings = await getUseCase();

      expect(settings.isDarkMode, true);
    });

    test('ユーザーが文字数制限を旧Twitter互換の140文字に変更する', () async {
      final getUseCase = GetSettingsUseCase(mockRepository);
      final saveMaxLengthUseCase = SaveMaxLengthUseCase(mockRepository);

      await saveMaxLengthUseCase(140);
      final settings = await getUseCase();

      expect(settings.maxLength, 140);
    });

    test('ユーザーが全ての設定をカスタマイズする', () async {
      final getUseCase = GetSettingsUseCase(mockRepository);
      final saveMaxLengthUseCase = SaveMaxLengthUseCase(mockRepository);
      final saveThemeModeUseCase = SaveThemeModeUseCase(mockRepository);

      // ダークモードを有効に
      await saveThemeModeUseCase(true);
      // 長文投稿用に制限を増やす
      await saveMaxLengthUseCase(4000);

      final settings = await getUseCase();

      expect(settings.maxLength, 4000);
      expect(settings.isDarkMode, true);
    });
  });
}
