import 'package:flutter_test/flutter_test.dart';
import 'package:my_x_draft_pad/domain/entities/draft_entity.dart';

void main() {
  final testDate = DateTime(2024, 1, 15, 10, 30);
  final testDate2 = DateTime(2024, 1, 16, 12, 0);

  group('DraftEntity', () {
    group('コンストラクタ', () {
      group('正常系', () {
        test('必須フィールドを全て指定してエンティティを作成できる', () {
          final entity = DraftEntity(
            id: 1,
            content: 'Test content',
            createdAt: testDate,
            updatedAt: testDate,
          );

          expect(entity.id, 1);
          expect(entity.content, 'Test content');
          expect(entity.createdAt, testDate);
          expect(entity.updatedAt, testDate);
        });
      });

      group('境界値', () {
        test('新規下書きの場合、idをnullにできる', () {
          final entity = DraftEntity(
            content: 'New draft',
            createdAt: testDate,
            updatedAt: testDate,
          );

          expect(entity.id, isNull);
        });
      });
    });

    group('preview', () {
      group('正常系', () {
        test('30文字以下の場合、全文を返す', () {
          final entity = DraftEntity(
            content: 'Short text',
            createdAt: testDate,
            updatedAt: testDate,
          );

          expect(entity.preview, 'Short text');
        });
      });

      group('境界値', () {
        test('空のcontentの場合、空文字を返す', () {
          final entity = DraftEntity(
            content: '',
            createdAt: testDate,
            updatedAt: testDate,
          );

          expect(entity.preview, '');
        });

        test('ちょうど30文字の場合、そのまま返す', () {
          final content = '123456789012345678901234567890'; // exactly 30 chars
          final entity = DraftEntity(
            content: content,
            createdAt: testDate,
            updatedAt: testDate,
          );

          expect(entity.preview, content);
        });

        test('30文字を超える場合、省略記号付きで切り詰める', () {
          final entity = DraftEntity(
            content: 'This is a very long content that exceeds thirty characters',
            createdAt: testDate,
            updatedAt: testDate,
          );

          expect(entity.preview, 'This is a very long content th...');
          expect(entity.preview.length, 33); // 30 chars + '...'
        });

        test('複数行の場合、最初の行のみを省略記号付きで返す', () {
          final entity = DraftEntity(
            content: 'First line\nSecond line\nThird line',
            createdAt: testDate,
            updatedAt: testDate,
          );

          expect(entity.preview, 'First line...');
        });

        test('複数行で最初の行が30文字を超える場合、30文字で切り詰める', () {
          final entity = DraftEntity(
            content:
                'This is a very long first line that exceeds thirty\nSecond line',
            createdAt: testDate,
            updatedAt: testDate,
          );

          expect(entity.preview, 'This is a very long first line...');
        });
      });
    });

    group('copyWith', () {
      late DraftEntity original;

      setUp(() {
        original = DraftEntity(
          id: 1,
          content: 'Original content',
          createdAt: testDate,
          updatedAt: testDate,
        );
      });

      group('正常系', () {
        test('idのみを更新したコピーを返す', () {
          final copy = original.copyWith(id: 2);

          expect(copy.id, 2);
          expect(copy.content, original.content);
          expect(copy.createdAt, original.createdAt);
          expect(copy.updatedAt, original.updatedAt);
        });

        test('contentのみを更新したコピーを返す', () {
          final copy = original.copyWith(content: 'New content');

          expect(copy.id, original.id);
          expect(copy.content, 'New content');
          expect(copy.createdAt, original.createdAt);
          expect(copy.updatedAt, original.updatedAt);
        });

        test('updatedAtのみを更新したコピーを返す', () {
          final copy = original.copyWith(updatedAt: testDate2);

          expect(copy.id, original.id);
          expect(copy.content, original.content);
          expect(copy.createdAt, original.createdAt);
          expect(copy.updatedAt, testDate2);
        });

        test('複数フィールドを同時に更新したコピーを返す', () {
          final copy = original.copyWith(
            content: 'Updated content',
            updatedAt: testDate2,
          );

          expect(copy.id, original.id);
          expect(copy.content, 'Updated content');
          expect(copy.createdAt, original.createdAt);
          expect(copy.updatedAt, testDate2);
        });
      });

      group('境界値', () {
        test('パラメータなしの場合、同一内容のコピーを返す', () {
          final copy = original.copyWith();

          expect(copy.id, original.id);
          expect(copy.content, original.content);
          expect(copy.createdAt, original.createdAt);
          expect(copy.updatedAt, original.updatedAt);
        });
      });
    });

    group('等価性', () {
      group('正常系', () {
        test('同じ値を持つエンティティは等しい', () {
          final entity1 = DraftEntity(
            id: 1,
            content: 'Same content',
            createdAt: testDate,
            updatedAt: testDate,
          );
          final entity2 = DraftEntity(
            id: 1,
            content: 'Same content',
            createdAt: testDate,
            updatedAt: testDate,
          );

          expect(entity1, equals(entity2));
        });

        test('同一インスタンスは等しい', () {
          final entity = DraftEntity(
            id: 1,
            content: 'Content',
            createdAt: testDate,
            updatedAt: testDate,
          );

          expect(entity, equals(entity));
        });
      });

      group('異常系', () {
        test('異なるidを持つエンティティは等しくない', () {
          final entity1 = DraftEntity(
            id: 1,
            content: 'Same content',
            createdAt: testDate,
            updatedAt: testDate,
          );
          final entity2 = DraftEntity(
            id: 2,
            content: 'Same content',
            createdAt: testDate,
            updatedAt: testDate,
          );

          expect(entity1, isNot(equals(entity2)));
        });

        test('異なるcontentを持つエンティティは等しくない', () {
          final entity1 = DraftEntity(
            id: 1,
            content: 'Content A',
            createdAt: testDate,
            updatedAt: testDate,
          );
          final entity2 = DraftEntity(
            id: 1,
            content: 'Content B',
            createdAt: testDate,
            updatedAt: testDate,
          );

          expect(entity1, isNot(equals(entity2)));
        });
      });
    });

    group('hashCode', () {
      group('正常系', () {
        test('等しいエンティティは同じhashCodeを返す', () {
          final entity1 = DraftEntity(
            id: 1,
            content: 'Same content',
            createdAt: testDate,
            updatedAt: testDate,
          );
          final entity2 = DraftEntity(
            id: 1,
            content: 'Same content',
            createdAt: testDate,
            updatedAt: testDate,
          );

          expect(entity1.hashCode, equals(entity2.hashCode));
        });
      });

      group('異常系', () {
        test('異なるエンティティは異なるhashCodeを返す', () {
          final entity1 = DraftEntity(
            id: 1,
            content: 'Content A',
            createdAt: testDate,
            updatedAt: testDate,
          );
          final entity2 = DraftEntity(
            id: 2,
            content: 'Content B',
            createdAt: testDate,
            updatedAt: testDate,
          );

          expect(entity1.hashCode, isNot(equals(entity2.hashCode)));
        });
      });
    });
  });
}