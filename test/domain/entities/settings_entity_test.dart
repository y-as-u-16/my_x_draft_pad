import 'package:flutter_test/flutter_test.dart';
import 'package:my_x_draft_pad/domain/entities/settings_entity.dart';

void main() {
  group('SettingsEntity', () {
    group('コンストラクタ', () {
      group('正常系', () {
        test('必須フィールドを全て指定してエンティティを作成できる', () {
          const entity = SettingsEntity(maxLength: 280, isDarkMode: false);

          expect(entity.maxLength, 280);
          expect(entity.isDarkMode, false);
        });

        test('ダークモードをtrueで作成できる', () {
          const entity = SettingsEntity(maxLength: 140, isDarkMode: true);

          expect(entity.maxLength, 140);
          expect(entity.isDarkMode, true);
        });
      });

      group('境界値', () {
        test('maxLengthを0で作成できる', () {
          const entity = SettingsEntity(maxLength: 0, isDarkMode: false);

          expect(entity.maxLength, 0);
        });

        test('maxLengthを1で作成できる', () {
          const entity = SettingsEntity(maxLength: 1, isDarkMode: false);

          expect(entity.maxLength, 1);
        });

        test('maxLengthを大きな値で作成できる', () {
          const entity = SettingsEntity(maxLength: 10000, isDarkMode: false);

          expect(entity.maxLength, 10000);
        });

        test('負のmaxLengthでも作成できる（バリデーションは別レイヤー）', () {
          const entity = SettingsEntity(maxLength: -1, isDarkMode: false);

          expect(entity.maxLength, -1);
        });
      });

      group('典型的なユースケース', () {
        test('X/Twitter互換の280文字制限を設定できる', () {
          const entity = SettingsEntity(maxLength: 280, isDarkMode: false);

          expect(entity.maxLength, 280);
        });

        test('旧Twitter互換の140文字制限を設定できる', () {
          const entity = SettingsEntity(maxLength: 140, isDarkMode: false);

          expect(entity.maxLength, 140);
        });

        test('長文投稿用の制限を設定できる', () {
          const entity = SettingsEntity(maxLength: 4000, isDarkMode: true);

          expect(entity.maxLength, 4000);
        });
      });
    });

    group('copyWith', () {
      late SettingsEntity original;

      setUp(() {
        original = const SettingsEntity(maxLength: 280, isDarkMode: false);
      });

      group('正常系', () {
        test('maxLengthのみを更新したコピーを返す', () {
          final copy = original.copyWith(maxLength: 140);

          expect(copy.maxLength, 140);
          expect(copy.isDarkMode, original.isDarkMode);
        });

        test('isDarkModeのみを更新したコピーを返す', () {
          final copy = original.copyWith(isDarkMode: true);

          expect(copy.maxLength, original.maxLength);
          expect(copy.isDarkMode, true);
        });

        test('両方のフィールドを同時に更新したコピーを返す', () {
          final copy = original.copyWith(maxLength: 500, isDarkMode: true);

          expect(copy.maxLength, 500);
          expect(copy.isDarkMode, true);
        });
      });

      group('境界値', () {
        test('パラメータなしの場合、同一内容のコピーを返す', () {
          final copy = original.copyWith();

          expect(copy.maxLength, original.maxLength);
          expect(copy.isDarkMode, original.isDarkMode);
        });

        test('同じ値で更新しても新しいインスタンスを返す', () {
          final copy = original.copyWith(maxLength: 280);

          expect(identical(copy, original), isFalse);
          expect(copy.maxLength, original.maxLength);
        });
      });

      group('immutability', () {
        test('copyWithは元のインスタンスを変更しない', () {
          original.copyWith(maxLength: 100, isDarkMode: true);

          expect(original.maxLength, 280);
          expect(original.isDarkMode, false);
        });
      });
    });

    group('等価性 (==)', () {
      group('正常系', () {
        test('同じ値を持つエンティティは等しい', () {
          const entity1 = SettingsEntity(maxLength: 280, isDarkMode: false);
          const entity2 = SettingsEntity(maxLength: 280, isDarkMode: false);

          expect(entity1, equals(entity2));
        });

        test('同一インスタンスは等しい', () {
          const entity = SettingsEntity(maxLength: 280, isDarkMode: false);

          expect(entity, equals(entity));
        });

        test('ダークモードがtrueの場合も正しく比較できる', () {
          const entity1 = SettingsEntity(maxLength: 280, isDarkMode: true);
          const entity2 = SettingsEntity(maxLength: 280, isDarkMode: true);

          expect(entity1, equals(entity2));
        });
      });

      group('異常系', () {
        test('異なるmaxLengthを持つエンティティは等しくない', () {
          const entity1 = SettingsEntity(maxLength: 280, isDarkMode: false);
          const entity2 = SettingsEntity(maxLength: 140, isDarkMode: false);

          expect(entity1, isNot(equals(entity2)));
        });

        test('異なるisDarkModeを持つエンティティは等しくない', () {
          const entity1 = SettingsEntity(maxLength: 280, isDarkMode: false);
          const entity2 = SettingsEntity(maxLength: 280, isDarkMode: true);

          expect(entity1, isNot(equals(entity2)));
        });

        test('両方異なる場合は等しくない', () {
          const entity1 = SettingsEntity(maxLength: 280, isDarkMode: false);
          const entity2 = SettingsEntity(maxLength: 140, isDarkMode: true);

          expect(entity1, isNot(equals(entity2)));
        });

        test('異なる型との比較は等しくない', () {
          const entity = SettingsEntity(maxLength: 280, isDarkMode: false);

          expect(entity == 'not an entity', isFalse);
          expect(entity == 280, isFalse);
          expect(entity == null, isFalse);
        });
      });
    });

    group('hashCode', () {
      group('正常系', () {
        test('等しいエンティティは同じhashCodeを返す', () {
          const entity1 = SettingsEntity(maxLength: 280, isDarkMode: false);
          const entity2 = SettingsEntity(maxLength: 280, isDarkMode: false);

          expect(entity1.hashCode, equals(entity2.hashCode));
        });

        test('ダークモードがtrueの場合も同じhashCodeを返す', () {
          const entity1 = SettingsEntity(maxLength: 280, isDarkMode: true);
          const entity2 = SettingsEntity(maxLength: 280, isDarkMode: true);

          expect(entity1.hashCode, equals(entity2.hashCode));
        });
      });

      group('異常系', () {
        test('異なるmaxLengthのエンティティは異なるhashCodeを返す', () {
          const entity1 = SettingsEntity(maxLength: 280, isDarkMode: false);
          const entity2 = SettingsEntity(maxLength: 140, isDarkMode: false);

          expect(entity1.hashCode, isNot(equals(entity2.hashCode)));
        });

        test('異なるisDarkModeのエンティティは異なるhashCodeを返す', () {
          const entity1 = SettingsEntity(maxLength: 280, isDarkMode: false);
          const entity2 = SettingsEntity(maxLength: 280, isDarkMode: true);

          expect(entity1.hashCode, isNot(equals(entity2.hashCode)));
        });
      });

      group('HashSetでの使用', () {
        test('Setに追加した場合、重複が排除される', () {
          const entity1 = SettingsEntity(maxLength: 280, isDarkMode: false);
          const entity2 = SettingsEntity(maxLength: 280, isDarkMode: false);
          const entity3 = SettingsEntity(maxLength: 140, isDarkMode: true);

          final set = {entity1, entity2, entity3};

          expect(set.length, 2);
        });

        test('Mapのキーとして使用できる', () {
          const entity1 = SettingsEntity(maxLength: 280, isDarkMode: false);
          const entity2 = SettingsEntity(maxLength: 280, isDarkMode: false);

          final map = <SettingsEntity, String>{entity1: 'value1'};

          expect(map[entity2], 'value1');
        });
      });
    });

    group('const constructor', () {
      test('constコンストラクタで同じ値を持つインスタンスは同一', () {
        const entity1 = SettingsEntity(maxLength: 280, isDarkMode: false);
        const entity2 = SettingsEntity(maxLength: 280, isDarkMode: false);

        expect(identical(entity1, entity2), isTrue);
      });

      test('異なる値のconstインスタンスは異なる', () {
        const entity1 = SettingsEntity(maxLength: 280, isDarkMode: false);
        const entity2 = SettingsEntity(maxLength: 140, isDarkMode: false);

        expect(identical(entity1, entity2), isFalse);
      });
    });
  });
}
