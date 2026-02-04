import 'package:flutter_test/flutter_test.dart';
import 'package:my_x_draft_pad/domain/entities/draft_entity.dart';
import 'package:my_x_draft_pad/domain/repositories/draft_repository.dart';
import 'package:my_x_draft_pad/domain/usecases/draft_usecases.dart';

/// DraftRepositoryのモック実装
class MockDraftRepository implements DraftRepository {
  List<DraftEntity> _drafts = [];
  int _nextId = 1;
  bool shouldThrowError = false;
  String errorMessage = 'Mock error';

  void setDrafts(List<DraftEntity> drafts) {
    _drafts = drafts;
  }

  void reset() {
    _drafts = [];
    _nextId = 1;
    shouldThrowError = false;
    errorMessage = 'Mock error';
  }

  @override
  Future<List<DraftEntity>> getAllDrafts() async {
    if (shouldThrowError) throw Exception(errorMessage);
    return _drafts;
  }

  @override
  Future<DraftEntity?> getDraftById(int id) async {
    if (shouldThrowError) throw Exception(errorMessage);
    try {
      return _drafts.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> createDraft(DraftEntity draft) async {
    if (shouldThrowError) throw Exception(errorMessage);
    final newDraft = draft.copyWith(id: _nextId);
    _drafts.add(newDraft);
    return _nextId++;
  }

  @override
  Future<void> updateDraft(DraftEntity draft) async {
    if (shouldThrowError) throw Exception(errorMessage);
    final index = _drafts.indexWhere((d) => d.id == draft.id);
    if (index != -1) {
      _drafts[index] = draft;
    }
  }

  @override
  Future<void> deleteDraft(int id) async {
    if (shouldThrowError) throw Exception(errorMessage);
    _drafts.removeWhere((d) => d.id == id);
  }
}

void main() {
  late MockDraftRepository mockRepository;
  final testDate = DateTime(2024, 1, 15, 10, 30);
  final testDate2 = DateTime(2024, 1, 16, 12, 0);

  setUp(() {
    mockRepository = MockDraftRepository();
  });

  tearDown(() {
    mockRepository.reset();
  });

  group('GetAllDraftsUseCase', () {
    late GetAllDraftsUseCase useCase;

    setUp(() {
      useCase = GetAllDraftsUseCase(mockRepository);
    });

    group('正常系', () {
      test('空のリストを返す', () async {
        final result = await useCase();

        expect(result, isEmpty);
      });

      test('1件の下書きを返す', () async {
        mockRepository.setDrafts([
          DraftEntity(
            id: 1,
            content: 'Draft 1',
            createdAt: testDate,
            updatedAt: testDate,
          ),
        ]);

        final result = await useCase();

        expect(result.length, 1);
        expect(result.first.content, 'Draft 1');
      });

      test('複数件の下書きを返す', () async {
        mockRepository.setDrafts([
          DraftEntity(
            id: 1,
            content: 'Draft 1',
            createdAt: testDate,
            updatedAt: testDate,
          ),
          DraftEntity(
            id: 2,
            content: 'Draft 2',
            createdAt: testDate2,
            updatedAt: testDate2,
          ),
          DraftEntity(
            id: 3,
            content: 'Draft 3',
            createdAt: testDate,
            updatedAt: testDate,
          ),
        ]);

        final result = await useCase();

        expect(result.length, 3);
        expect(result.map((d) => d.content).toList(),
            ['Draft 1', 'Draft 2', 'Draft 3']);
      });
    });

    group('異常系', () {
      test('エラーが発生した場合は例外をスローする', () async {
        mockRepository.shouldThrowError = true;
        mockRepository.errorMessage = 'Database error';

        expect(
          () => useCase(),
          throwsA(isA<Exception>()),
        );
      });
    });
  });

  group('GetDraftByIdUseCase', () {
    late GetDraftByIdUseCase useCase;

    setUp(() {
      useCase = GetDraftByIdUseCase(mockRepository);
      mockRepository.setDrafts([
        DraftEntity(
          id: 1,
          content: 'Draft 1',
          createdAt: testDate,
          updatedAt: testDate,
        ),
        DraftEntity(
          id: 2,
          content: 'Draft 2',
          createdAt: testDate2,
          updatedAt: testDate2,
        ),
      ]);
    });

    group('正常系', () {
      test('存在するIDで下書きを取得できる', () async {
        final result = await useCase(1);

        expect(result, isNotNull);
        expect(result!.id, 1);
        expect(result.content, 'Draft 1');
      });

      test('別のIDで下書きを取得できる', () async {
        final result = await useCase(2);

        expect(result, isNotNull);
        expect(result!.id, 2);
        expect(result.content, 'Draft 2');
      });
    });

    group('異常系', () {
      test('存在しないIDの場合はnullを返す', () async {
        final result = await useCase(999);

        expect(result, isNull);
      });

      test('負のIDでもnullを返す', () async {
        final result = await useCase(-1);

        expect(result, isNull);
      });

      test('IDが0の場合もnullを返す', () async {
        final result = await useCase(0);

        expect(result, isNull);
      });

      test('エラーが発生した場合は例外をスローする', () async {
        mockRepository.shouldThrowError = true;

        expect(
          () => useCase(1),
          throwsA(isA<Exception>()),
        );
      });
    });
  });

  group('CreateDraftUseCase', () {
    late CreateDraftUseCase useCase;

    setUp(() {
      useCase = CreateDraftUseCase(mockRepository);
    });

    group('正常系', () {
      test('新しい下書きを作成して生成されたIDを返す', () async {
        final result = await useCase('New draft content');

        expect(result, 1);
      });

      test('連続して作成すると連番のIDが返される', () async {
        final id1 = await useCase('Draft 1');
        final id2 = await useCase('Draft 2');
        final id3 = await useCase('Draft 3');

        expect(id1, 1);
        expect(id2, 2);
        expect(id3, 3);
      });

      test('作成した下書きはリポジトリに保存される', () async {
        await useCase('Saved draft');

        final drafts = await mockRepository.getAllDrafts();
        expect(drafts.length, 1);
        expect(drafts.first.content, 'Saved draft');
      });

      test('createdAtとupdatedAtが自動的に設定される', () async {
        final beforeCreate = DateTime.now();
        await useCase('Timestamp test');
        final afterCreate = DateTime.now();

        final drafts = await mockRepository.getAllDrafts();
        final draft = drafts.first;

        expect(draft.createdAt.isAfter(beforeCreate.subtract(Duration(seconds: 1))), isTrue);
        expect(draft.createdAt.isBefore(afterCreate.add(Duration(seconds: 1))), isTrue);
        expect(draft.updatedAt, draft.createdAt);
      });
    });

    group('境界値', () {
      test('空のコンテンツで下書きを作成できる', () async {
        final result = await useCase('');

        expect(result, isPositive);
      });

      test('非常に長いコンテンツで下書きを作成できる', () async {
        final longContent = 'x' * 10000;
        final result = await useCase(longContent);

        expect(result, isPositive);

        final drafts = await mockRepository.getAllDrafts();
        expect(drafts.first.content.length, 10000);
      });

      test('改行を含むコンテンツで下書きを作成できる', () async {
        final result = await useCase('Line 1\nLine 2\nLine 3');

        expect(result, isPositive);

        final drafts = await mockRepository.getAllDrafts();
        expect(drafts.first.content.contains('\n'), isTrue);
      });

      test('絵文字を含むコンテンツで下書きを作成できる', () async {
        final result = await useCase('Hello 👋 World 🌍');

        expect(result, isPositive);

        final drafts = await mockRepository.getAllDrafts();
        expect(drafts.first.content, 'Hello 👋 World 🌍');
      });

      test('日本語を含むコンテンツで下書きを作成できる', () async {
        final result = await useCase('日本語テスト 漢字とひらがなとカタカナ');

        expect(result, isPositive);
      });
    });

    group('異常系', () {
      test('エラーが発生した場合は例外をスローする', () async {
        mockRepository.shouldThrowError = true;

        expect(
          () => useCase('Will fail'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });

  group('UpdateDraftUseCase', () {
    late UpdateDraftUseCase useCase;

    setUp(() {
      useCase = UpdateDraftUseCase(mockRepository);
      mockRepository.setDrafts([
        DraftEntity(
          id: 1,
          content: 'Original content',
          createdAt: testDate,
          updatedAt: testDate,
        ),
      ]);
    });

    group('正常系', () {
      test('下書きの内容を更新できる', () async {
        final draft = DraftEntity(
          id: 1,
          content: 'Updated content',
          createdAt: testDate,
          updatedAt: testDate,
        );

        await useCase(draft);

        final updatedDraft = await mockRepository.getDraftById(1);
        expect(updatedDraft!.content, 'Updated content');
      });

      test('updatedAtが自動的に更新される', () async {
        final draft = DraftEntity(
          id: 1,
          content: 'Updated',
          createdAt: testDate,
          updatedAt: testDate,
        );

        final beforeUpdate = DateTime.now();
        await useCase(draft);
        final afterUpdate = DateTime.now();

        final updatedDraft = await mockRepository.getDraftById(1);
        expect(
            updatedDraft!.updatedAt
                .isAfter(beforeUpdate.subtract(Duration(seconds: 1))),
            isTrue);
        expect(
            updatedDraft.updatedAt.isBefore(afterUpdate.add(Duration(seconds: 1))),
            isTrue);
      });

      test('createdAtは変更されない', () async {
        final draft = DraftEntity(
          id: 1,
          content: 'Updated',
          createdAt: testDate,
          updatedAt: testDate,
        );

        await useCase(draft);

        final updatedDraft = await mockRepository.getDraftById(1);
        expect(updatedDraft!.createdAt, testDate);
      });
    });

    group('境界値', () {
      test('空のコンテンツに更新できる', () async {
        final draft = DraftEntity(
          id: 1,
          content: '',
          createdAt: testDate,
          updatedAt: testDate,
        );

        await useCase(draft);

        final updatedDraft = await mockRepository.getDraftById(1);
        expect(updatedDraft!.content, '');
      });
    });

    group('異常系', () {
      test('エラーが発生した場合は例外をスローする', () async {
        mockRepository.shouldThrowError = true;

        final draft = DraftEntity(
          id: 1,
          content: 'Will fail',
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(
          () => useCase(draft),
          throwsA(isA<Exception>()),
        );
      });
    });
  });

  group('DeleteDraftUseCase', () {
    late DeleteDraftUseCase useCase;

    setUp(() {
      useCase = DeleteDraftUseCase(mockRepository);
      mockRepository.setDrafts([
        DraftEntity(
          id: 1,
          content: 'Draft 1',
          createdAt: testDate,
          updatedAt: testDate,
        ),
        DraftEntity(
          id: 2,
          content: 'Draft 2',
          createdAt: testDate,
          updatedAt: testDate,
        ),
      ]);
    });

    group('正常系', () {
      test('指定したIDの下書きを削除できる', () async {
        await useCase(1);

        final drafts = await mockRepository.getAllDrafts();
        expect(drafts.length, 1);
        expect(drafts.first.id, 2);
      });

      test('2番目の下書きを削除できる', () async {
        await useCase(2);

        final drafts = await mockRepository.getAllDrafts();
        expect(drafts.length, 1);
        expect(drafts.first.id, 1);
      });

      test('すべての下書きを削除できる', () async {
        await useCase(1);
        await useCase(2);

        final drafts = await mockRepository.getAllDrafts();
        expect(drafts, isEmpty);
      });
    });

    group('異常系', () {
      test('存在しないIDを削除しても例外は発生しない', () async {
        // 存在しないIDの削除は例外を発生させない（idempotent）
        await useCase(999);

        final drafts = await mockRepository.getAllDrafts();
        expect(drafts.length, 2);
      });

      test('エラーが発生した場合は例外をスローする', () async {
        mockRepository.shouldThrowError = true;

        expect(
          () => useCase(1),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('削除の独立性', () {
      test('他の下書きに影響を与えない', () async {
        await useCase(1);

        final remaining = await mockRepository.getDraftById(2);
        expect(remaining, isNotNull);
        expect(remaining!.content, 'Draft 2');
      });
    });
  });

  group('UseCase間の連携', () {
    test('作成 -> 取得 -> 更新 -> 削除の一連の操作が正しく動作する', () async {
      final createUseCase = CreateDraftUseCase(mockRepository);
      final getByIdUseCase = GetDraftByIdUseCase(mockRepository);
      final updateUseCase = UpdateDraftUseCase(mockRepository);
      final deleteUseCase = DeleteDraftUseCase(mockRepository);
      final getAllUseCase = GetAllDraftsUseCase(mockRepository);

      // 作成
      final id = await createUseCase('Initial content');
      expect(id, isPositive);

      // 取得
      final created = await getByIdUseCase(id);
      expect(created, isNotNull);
      expect(created!.content, 'Initial content');

      // 更新
      await updateUseCase(created.copyWith(content: 'Modified content'));
      final updated = await getByIdUseCase(id);
      expect(updated!.content, 'Modified content');

      // 削除
      await deleteUseCase(id);
      final deleted = await getByIdUseCase(id);
      expect(deleted, isNull);

      // 最終確認
      final all = await getAllUseCase();
      expect(all, isEmpty);
    });
  });
}
