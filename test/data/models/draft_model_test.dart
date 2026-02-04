import 'package:flutter_test/flutter_test.dart';
import 'package:my_x_draft_pad/data/models/draft_model.dart';
import 'package:my_x_draft_pad/domain/entities/draft_entity.dart';

void main() {
  final testDate = DateTime(2024, 1, 15, 10, 30, 45);
  final testDate2 = DateTime(2024, 1, 16, 12, 0, 0);

  group('DraftModel', () {
    group('コンストラクタ', () {
      group('正常系', () {
        test('全てのフィールドを指定してモデルを作成できる', () {
          final model = DraftModel(
            id: 1,
            content: 'Test content',
            createdAt: testDate,
            updatedAt: testDate,
          );

          expect(model.id, 1);
          expect(model.content, 'Test content');
          expect(model.createdAt, testDate);
          expect(model.updatedAt, testDate);
        });

        test('idをnullで作成できる（新規下書き）', () {
          final model = DraftModel(
            content: 'New draft',
            createdAt: testDate,
            updatedAt: testDate,
          );

          expect(model.id, isNull);
        });

        test('異なるcreatedAtとupdatedAtで作成できる', () {
          final model = DraftModel(
            id: 1,
            content: 'Test',
            createdAt: testDate,
            updatedAt: testDate2,
          );

          expect(model.createdAt, testDate);
          expect(model.updatedAt, testDate2);
        });
      });

      group('境界値', () {
        test('空のcontentで作成できる', () {
          final model = DraftModel(
            content: '',
            createdAt: testDate,
            updatedAt: testDate,
          );

          expect(model.content, '');
        });

        test('非常に長いcontentで作成できる', () {
          final longContent = 'a' * 10000;
          final model = DraftModel(
            content: longContent,
            createdAt: testDate,
            updatedAt: testDate,
          );

          expect(model.content.length, 10000);
        });

        test('改行を含むcontentで作成できる', () {
          final model = DraftModel(
            content: 'Line 1\nLine 2\nLine 3',
            createdAt: testDate,
            updatedAt: testDate,
          );

          expect(model.content.contains('\n'), isTrue);
        });

        test('絵文字を含むcontentで作成できる', () {
          final model = DraftModel(
            content: 'Hello 👋 World 🌍',
            createdAt: testDate,
            updatedAt: testDate,
          );

          expect(model.content, 'Hello 👋 World 🌍');
        });

        test('特殊文字を含むcontentで作成できる', () {
          final model = DraftModel(
            content: '<script>alert("XSS")</script> & "quotes" \'single\'',
            createdAt: testDate,
            updatedAt: testDate,
          );

          expect(model.content.contains('<script>'), isTrue);
        });
      });
    });

    group('fromMap', () {
      group('正常系', () {
        test('Mapから正しくモデルを生成できる', () {
          final map = {
            'id': 1,
            'content': 'Test content',
            'created_at': testDate.millisecondsSinceEpoch,
            'updated_at': testDate.millisecondsSinceEpoch,
          };

          final model = DraftModel.fromMap(map);

          expect(model.id, 1);
          expect(model.content, 'Test content');
          expect(model.createdAt.millisecondsSinceEpoch,
              testDate.millisecondsSinceEpoch);
          expect(model.updatedAt.millisecondsSinceEpoch,
              testDate.millisecondsSinceEpoch);
        });

        test('idがnullのMapから正しくモデルを生成できる', () {
          final map = {
            'id': null,
            'content': 'New draft',
            'created_at': testDate.millisecondsSinceEpoch,
            'updated_at': testDate.millisecondsSinceEpoch,
          };

          final model = DraftModel.fromMap(map);

          expect(model.id, isNull);
        });
      });

      group('境界値', () {
        test('Unix Epoch (0) の日時を正しく変換できる', () {
          final map = {
            'id': 1,
            'content': 'Test',
            'created_at': 0,
            'updated_at': 0,
          };

          final model = DraftModel.fromMap(map);

          expect(model.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
        });

        test('大きなタイムスタンプ値を正しく変換できる', () {
          final farFuture = DateTime(2100, 12, 31, 23, 59, 59);
          final map = {
            'id': 1,
            'content': 'Test',
            'created_at': farFuture.millisecondsSinceEpoch,
            'updated_at': farFuture.millisecondsSinceEpoch,
          };

          final model = DraftModel.fromMap(map);

          expect(model.createdAt.year, 2100);
        });

        test('空文字のcontentを正しく変換できる', () {
          final map = {
            'id': 1,
            'content': '',
            'created_at': testDate.millisecondsSinceEpoch,
            'updated_at': testDate.millisecondsSinceEpoch,
          };

          final model = DraftModel.fromMap(map);

          expect(model.content, '');
        });
      });

      group('データベースからの読み込みシミュレーション', () {
        test('SQLiteのクエリ結果形式のMapを変換できる', () {
          // SQLiteクエリ結果をシミュレート
          final queryResult = <String, dynamic>{
            'id': 42,
            'content': 'Draft from database',
            'created_at': 1705315845000, // 2024-01-15 10:30:45 UTC
            'updated_at': 1705315845000,
          };

          final model = DraftModel.fromMap(queryResult);

          expect(model.id, 42);
          expect(model.content, 'Draft from database');
        });
      });
    });

    group('toMap', () {
      group('正常系', () {
        test('モデルを正しくMapに変換できる', () {
          final model = DraftModel(
            id: 1,
            content: 'Test content',
            createdAt: testDate,
            updatedAt: testDate,
          );

          final map = model.toMap();

          expect(map['id'], 1);
          expect(map['content'], 'Test content');
          expect(map['created_at'], testDate.millisecondsSinceEpoch);
          expect(map['updated_at'], testDate.millisecondsSinceEpoch);
        });

        test('idがnullのモデルを正しくMapに変換できる', () {
          final model = DraftModel(
            content: 'New draft',
            createdAt: testDate,
            updatedAt: testDate,
          );

          final map = model.toMap();

          expect(map['id'], isNull);
        });
      });

      group('境界値', () {
        test('空文字のcontentを正しくMapに変換できる', () {
          final model = DraftModel(
            content: '',
            createdAt: testDate,
            updatedAt: testDate,
          );

          final map = model.toMap();

          expect(map['content'], '');
        });

        test('特殊文字を含むcontentを正しくMapに変換できる', () {
          final model = DraftModel(
            content: 'Test\nWith\tSpecial\rChars',
            createdAt: testDate,
            updatedAt: testDate,
          );

          final map = model.toMap();

          expect(map['content'], 'Test\nWith\tSpecial\rChars');
        });
      });

      group('往復変換', () {
        test('toMap -> fromMap で同じデータが復元される', () {
          final original = DraftModel(
            id: 123,
            content: 'Round trip test',
            createdAt: testDate,
            updatedAt: testDate2,
          );

          final map = original.toMap();
          final restored = DraftModel.fromMap(map);

          expect(restored.id, original.id);
          expect(restored.content, original.content);
          expect(restored.createdAt.millisecondsSinceEpoch,
              original.createdAt.millisecondsSinceEpoch);
          expect(restored.updatedAt.millisecondsSinceEpoch,
              original.updatedAt.millisecondsSinceEpoch);
        });

        test('絵文字を含むcontentでも往復変換で同じデータが復元される', () {
          final original = DraftModel(
            id: 1,
            content: '🎉 テスト 🚀 Test 日本語 🇯🇵',
            createdAt: testDate,
            updatedAt: testDate,
          );

          final map = original.toMap();
          final restored = DraftModel.fromMap(map);

          expect(restored.content, original.content);
        });
      });
    });

    group('fromEntity', () {
      group('正常系', () {
        test('DraftEntityから正しくDraftModelを生成できる', () {
          final entity = DraftEntity(
            id: 1,
            content: 'Entity content',
            createdAt: testDate,
            updatedAt: testDate,
          );

          final model = DraftModel.fromEntity(entity);

          expect(model.id, entity.id);
          expect(model.content, entity.content);
          expect(model.createdAt, entity.createdAt);
          expect(model.updatedAt, entity.updatedAt);
        });

        test('idがnullのDraftEntityから正しくDraftModelを生成できる', () {
          final entity = DraftEntity(
            content: 'New entity',
            createdAt: testDate,
            updatedAt: testDate,
          );

          final model = DraftModel.fromEntity(entity);

          expect(model.id, isNull);
        });
      });

      group('境界値', () {
        test('空のcontentを持つEntityから生成できる', () {
          final entity = DraftEntity(
            content: '',
            createdAt: testDate,
            updatedAt: testDate,
          );

          final model = DraftModel.fromEntity(entity);

          expect(model.content, '');
        });

        test('長いcontentを持つEntityから生成できる', () {
          final longContent = 'x' * 5000;
          final entity = DraftEntity(
            content: longContent,
            createdAt: testDate,
            updatedAt: testDate,
          );

          final model = DraftModel.fromEntity(entity);

          expect(model.content.length, 5000);
        });
      });
    });

    group('toEntity', () {
      group('正常系', () {
        test('DraftModelから正しくDraftEntityを生成できる', () {
          final model = DraftModel(
            id: 1,
            content: 'Model content',
            createdAt: testDate,
            updatedAt: testDate,
          );

          final entity = model.toEntity();

          expect(entity.id, model.id);
          expect(entity.content, model.content);
          expect(entity.createdAt, model.createdAt);
          expect(entity.updatedAt, model.updatedAt);
        });

        test('idがnullのDraftModelから正しくDraftEntityを生成できる', () {
          final model = DraftModel(
            content: 'New model',
            createdAt: testDate,
            updatedAt: testDate,
          );

          final entity = model.toEntity();

          expect(entity.id, isNull);
        });
      });

      group('往復変換', () {
        test('toEntity -> fromEntity で同じデータが復元される', () {
          final original = DraftModel(
            id: 42,
            content: 'Round trip model',
            createdAt: testDate,
            updatedAt: testDate2,
          );

          final entity = original.toEntity();
          final restored = DraftModel.fromEntity(entity);

          expect(restored.id, original.id);
          expect(restored.content, original.content);
          expect(restored.createdAt, original.createdAt);
          expect(restored.updatedAt, original.updatedAt);
        });
      });
    });

    group('Entity <-> Model 変換の一貫性', () {
      test('Entity -> Model -> Entity で元のEntityと同等のデータを持つ', () {
        final originalEntity = DraftEntity(
          id: 100,
          content: 'Original entity content',
          createdAt: testDate,
          updatedAt: testDate2,
        );

        final model = DraftModel.fromEntity(originalEntity);
        final restoredEntity = model.toEntity();

        expect(restoredEntity.id, originalEntity.id);
        expect(restoredEntity.content, originalEntity.content);
        expect(restoredEntity.createdAt, originalEntity.createdAt);
        expect(restoredEntity.updatedAt, originalEntity.updatedAt);
      });

      test('Model -> Entity -> Model で同じデータが復元される', () {
        final originalModel = DraftModel(
          id: 200,
          content: 'Original model content',
          createdAt: testDate,
          updatedAt: testDate2,
        );

        final entity = originalModel.toEntity();
        final restoredModel = DraftModel.fromEntity(entity);

        expect(restoredModel.id, originalModel.id);
        expect(restoredModel.content, originalModel.content);
        expect(restoredModel.createdAt, originalModel.createdAt);
        expect(restoredModel.updatedAt, originalModel.updatedAt);
      });
    });

    group('Model -> Map -> Model -> Entity の完全な変換チェーン', () {
      test('すべての変換を通しても正しいデータが保持される', () {
        final originalModel = DraftModel(
          id: 999,
          content: 'Full chain test with 日本語 and emoji 🎉',
          createdAt: testDate,
          updatedAt: testDate2,
        );

        // Model -> Map
        final map = originalModel.toMap();
        // Map -> Model
        final restoredModel = DraftModel.fromMap(map);
        // Model -> Entity
        final entity = restoredModel.toEntity();

        expect(entity.id, originalModel.id);
        expect(entity.content, originalModel.content);
        expect(entity.createdAt.millisecondsSinceEpoch,
            originalModel.createdAt.millisecondsSinceEpoch);
        expect(entity.updatedAt.millisecondsSinceEpoch,
            originalModel.updatedAt.millisecondsSinceEpoch);
      });
    });
  });
}
