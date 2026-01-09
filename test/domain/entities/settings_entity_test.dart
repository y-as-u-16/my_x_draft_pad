import 'package:flutter_test/flutter_test.dart';
import 'package:my_x_draft_pad/domain/entities/settings_entity.dart';

void main() {
  group('SettingsEntity', () {
    group('コンストラクタ', () {
      group('正常系', () {
        test('必須フィールドを全て指定してエンティティを作成できる', () {
          const entity = SettingsEntity(
            maxLength: 140,
            isDarkMode: false,
          );

          expect(entity.maxLength, 140);
          expect(entity.isDarkMode, false);
        });

        test('ダークモード有効で作成できる', () {
          const entity = SettingsEntity(
            maxLength: 280,
            isDarkMode: true,
          );

          expect(entity.maxLength, 280);
          expect(entity.isDarkMode, true);
        });
      });

      group('境界値', () {
        test('maxLengthが0の場合も作成できる', () {
          const entity = SettingsEntity(
            maxLength: 0,
            isDarkMode: false,
          );

          expect(entity.maxLength, 0);
        });

        test('maxLengthが非常に大きい値の場合も作成できる', () {
          const entity = SettingsEntity(
            maxLength: 10000,
            isDarkMode: false,
          );

          expect(entity.maxLength, 10000);
        });
      });
    });

    group('copyWith', () {
      late SettingsEntity original;

      setUp(() {
        original = const SettingsEntity(
          maxLength: 140,
          isDarkMode: false,
        );
      });

      group('正常系', () {
        test('maxLengthのみを更新したコピーを返す', () {
          final copy = original.copyWith(maxLength: 280);

          expect(copy.maxLength, 280);
          expect(copy.isDarkMode, original.isDarkMode);
        });

        test('isDarkModeのみを更新したコピーを返す', () {
          final copy = original.copyWith(isDarkMode: true);

          expect(copy.maxLength, original.maxLength);
          expect(copy.isDarkMode, true);
        });

        test('複数フィールドを同時に更新したコピーを返す', () {
          final copy = original.copyWith(
            maxLength: 280,
            isDarkMode: true,
          );

          expect(copy.maxLength, 280);
          expect(copy.isDarkMode, true);
        });
      });

      group('境界値', () {
        test('パラメータなしの場合、同一内容のコピーを返す', () {
          final copy = original.copyWith();

          expect(copy.maxLength, original.maxLength);
          expect(copy.isDarkMode, original.isDarkMode);
        });
      });
    });

    group('等価性', () {
      group('正常系', () {
        test('同じ値を持つエンティティは等しい', () {
          const entity1 = SettingsEntity(
            maxLength: 140,
            isDarkMode: false,
          );
          const entity2 = SettingsEntity(
            maxLength: 140,
            isDarkMode: false,
          );

          expect(entity1, equals(entity2));
        });

        test('同一インスタンスは等しい', () {
          const entity = SettingsEntity(
            maxLength: 140,
            isDarkMode: false,
          );

          expect(entity, equals(entity));
        });
      });

      group('異常系', () {
        test('異なるmaxLengthを持つエンティティは等しくない', () {
          const entity1 = SettingsEntity(
            maxLength: 140,
            isDarkMode: false,
          );
          const entity2 = SettingsEntity(
            maxLength: 280,
            isDarkMode: false,
          );

          expect(entity1, isNot(equals(entity2)));
        });

        test('異なるisDarkModeを持つエンティティは等しくない', () {
          const entity1 = SettingsEntity(
            maxLength: 140,
            isDarkMode: false,
          );
          const entity2 = SettingsEntity(
            maxLength: 140,
            isDarkMode: true,
          );

          expect(entity1, isNot(equals(entity2)));
        });

        test('全てのフィールドが異なるエンティティは等しくない', () {
          const entity1 = SettingsEntity(
            maxLength: 140,
            isDarkMode: false,
          );
          const entity2 = SettingsEntity(
            maxLength: 280,
            isDarkMode: true,
          );

          expect(entity1, isNot(equals(entity2)));
        });
      });
    });

    group('hashCode', () {
      group('正常系', () {
        test('等しいエンティティは同じhashCodeを返す', () {
          const entity1 = SettingsEntity(
            maxLength: 140,
            isDarkMode: false,
          );
          const entity2 = SettingsEntity(
            maxLength: 140,
            isDarkMode: false,
          );

          expect(entity1.hashCode, equals(entity2.hashCode));
        });
      });

      group('異常系', () {
        test('異なるエンティティは異なるhashCodeを返す', () {
          const entity1 = SettingsEntity(
            maxLength: 140,
            isDarkMode: false,
          );
          const entity2 = SettingsEntity(
            maxLength: 280,
            isDarkMode: true,
          );

          expect(entity1.hashCode, isNot(equals(entity2.hashCode)));
        });
      });
    });
  });
}
