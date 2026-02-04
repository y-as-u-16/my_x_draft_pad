import 'package:flutter_test/flutter_test.dart';
import 'package:my_x_draft_pad/domain/entities/draft_entity.dart';
import 'package:my_x_draft_pad/domain/usecases/draft_usecases.dart';
import 'package:my_x_draft_pad/domain/repositories/draft_repository.dart';
import 'package:my_x_draft_pad/presentation/viewmodels/draft_list_viewmodel.dart';

/// DraftRepositoryのモック実装
class MockDraftRepository implements DraftRepository {
  List<DraftEntity> _drafts = [];
  bool shouldThrowError = false;
  String errorMessage = 'Mock error';

  void setDrafts(List<DraftEntity> drafts) {
    _drafts = List.from(drafts);
  }

  void reset() {
    _drafts = [];
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
    return 1;
  }

  @override
  Future<void> updateDraft(DraftEntity draft) async {
    if (shouldThrowError) throw Exception(errorMessage);
  }

  @override
  Future<void> deleteDraft(int id) async {
    if (shouldThrowError) throw Exception(errorMessage);
    _drafts.removeWhere((d) => d.id == id);
  }
}

void main() {
  late MockDraftRepository mockRepository;
  late GetAllDraftsUseCase getAllDraftsUseCase;
  late DeleteDraftUseCase deleteDraftUseCase;
  late DraftListViewModel viewModel;
  final testDate = DateTime(2024, 1, 15, 10, 30);
  final testDate2 = DateTime(2024, 1, 16, 12, 0);

  setUp(() {
    mockRepository = MockDraftRepository();
    getAllDraftsUseCase = GetAllDraftsUseCase(mockRepository);
    deleteDraftUseCase = DeleteDraftUseCase(mockRepository);
    viewModel = DraftListViewModel(
      getAllDraftsUseCase: getAllDraftsUseCase,
      deleteDraftUseCase: deleteDraftUseCase,
    );
  });

  tearDown(() {
    mockRepository.reset();
    viewModel.dispose();
  });

  group('DraftListViewModel', () {
    group('初期状態', () {
      test('初期状態ではdraftsは空リスト', () {
        expect(viewModel.drafts, isEmpty);
      });

      test('初期状態ではisLoadingはfalse', () {
        expect(viewModel.isLoading, false);
      });

      test('初期状態ではerrorMessageはnull', () {
        expect(viewModel.errorMessage, isNull);
      });

      test('初期状態ではisEmptyはtrue', () {
        expect(viewModel.isEmpty, true);
      });
    });

    group('loadDrafts', () {
      group('正常系', () {
        test('下書きがない場合は空のリストを返す', () async {
          await viewModel.loadDrafts();

          expect(viewModel.drafts, isEmpty);
          expect(viewModel.isEmpty, true);
          expect(viewModel.isLoading, false);
        });

        test('下書きが1件ある場合はリストに含まれる', () async {
          mockRepository.setDrafts([
            DraftEntity(
              id: 1,
              content: 'Draft 1',
              createdAt: testDate,
              updatedAt: testDate,
            ),
          ]);

          await viewModel.loadDrafts();

          expect(viewModel.drafts.length, 1);
          expect(viewModel.drafts.first.content, 'Draft 1');
          expect(viewModel.isEmpty, false);
        });

        test('複数の下書きがある場合は全てリストに含まれる', () async {
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

          await viewModel.loadDrafts();

          expect(viewModel.drafts.length, 3);
        });

        test('loadDrafts後にerrorMessageはnullになる', () async {
          await viewModel.loadDrafts();

          expect(viewModel.errorMessage, isNull);
        });

        test('loadDrafts後にisLoadingはfalseになる', () async {
          await viewModel.loadDrafts();

          expect(viewModel.isLoading, false);
        });
      });

      group('ローディング状態', () {
        test('loadDrafts中はisLoadingがtrueになる', () async {
          var loadingStateObserved = false;

          viewModel.addListener(() {
            if (viewModel.isLoading) {
              loadingStateObserved = true;
            }
          });

          await viewModel.loadDrafts();

          expect(loadingStateObserved, true);
        });
      });

      group('異常系', () {
        test('エラーが発生した場合はerrorMessageが設定される', () async {
          mockRepository.shouldThrowError = true;
          mockRepository.errorMessage = 'Network error';

          await viewModel.loadDrafts();

          expect(viewModel.errorMessage, contains('Network error'));
          expect(viewModel.isLoading, false);
        });

        test('エラーが発生してもisLoadingはfalseになる', () async {
          mockRepository.shouldThrowError = true;

          await viewModel.loadDrafts();

          expect(viewModel.isLoading, false);
        });

        test('エラー後に再度loadDraftsが成功したらerrorMessageはクリアされる',
            () async {
          mockRepository.shouldThrowError = true;
          await viewModel.loadDrafts();
          expect(viewModel.errorMessage, isNotNull);

          mockRepository.shouldThrowError = false;
          await viewModel.loadDrafts();

          expect(viewModel.errorMessage, isNull);
        });
      });

      group('notifyListeners', () {
        test('loadDrafts中に複数回notifyListenersが呼ばれる', () async {
          var notifyCount = 0;

          viewModel.addListener(() {
            notifyCount++;
          });

          await viewModel.loadDrafts();

          // 最低でも2回（loading開始時と完了時）
          expect(notifyCount, greaterThanOrEqualTo(2));
        });
      });
    });

    group('deleteDraft', () {
      setUp(() {
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
        test('指定したIDの下書きを削除できる', () async {
          await viewModel.loadDrafts();
          expect(viewModel.drafts.length, 2);

          await viewModel.deleteDraft(1);

          expect(viewModel.drafts.length, 1);
          expect(viewModel.drafts.first.id, 2);
        });

        test('削除後にリストが自動的に更新される', () async {
          await viewModel.loadDrafts();

          await viewModel.deleteDraft(2);

          expect(viewModel.drafts.length, 1);
          expect(viewModel.drafts.any((d) => d.id == 2), false);
        });

        test('全ての下書きを削除できる', () async {
          await viewModel.loadDrafts();

          await viewModel.deleteDraft(1);
          await viewModel.deleteDraft(2);

          expect(viewModel.drafts, isEmpty);
          expect(viewModel.isEmpty, true);
        });
      });

      group('異常系', () {
        test('エラーが発生した場合はerrorMessageが設定される', () async {
          await viewModel.loadDrafts();
          mockRepository.shouldThrowError = true;
          mockRepository.errorMessage = 'Delete failed';

          await viewModel.deleteDraft(1);

          expect(viewModel.errorMessage, contains('Delete failed'));
        });
      });
    });

    group('isEmpty', () {
      test('下書きがない場合はtrue', () async {
        await viewModel.loadDrafts();

        expect(viewModel.isEmpty, true);
      });

      test('下書きがある場合はfalse', () async {
        mockRepository.setDrafts([
          DraftEntity(
            id: 1,
            content: 'Draft',
            createdAt: testDate,
            updatedAt: testDate,
          ),
        ]);

        await viewModel.loadDrafts();

        expect(viewModel.isEmpty, false);
      });

      test('下書きを全て削除するとtrueになる', () async {
        mockRepository.setDrafts([
          DraftEntity(
            id: 1,
            content: 'Draft',
            createdAt: testDate,
            updatedAt: testDate,
          ),
        ]);

        await viewModel.loadDrafts();
        expect(viewModel.isEmpty, false);

        await viewModel.deleteDraft(1);
        expect(viewModel.isEmpty, true);
      });
    });

    group('リスナー通知', () {
      test('loadDraftsでリスナーが通知される', () async {
        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        await viewModel.loadDrafts();

        expect(notified, true);
      });

      test('deleteDraftでリスナーが通知される', () async {
        mockRepository.setDrafts([
          DraftEntity(
            id: 1,
            content: 'Draft',
            createdAt: testDate,
            updatedAt: testDate,
          ),
        ]);
        await viewModel.loadDrafts();

        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        await viewModel.deleteDraft(1);

        expect(notified, true);
      });

      test('エラー発生時もリスナーが通知される', () async {
        mockRepository.shouldThrowError = true;
        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        await viewModel.loadDrafts();

        expect(notified, true);
      });
    });

    group('典型的なユースケース', () {
      test('アプリ起動時に下書き一覧を読み込む', () async {
        mockRepository.setDrafts([
          DraftEntity(
            id: 1,
            content: 'Previous draft 1',
            createdAt: testDate,
            updatedAt: testDate,
          ),
          DraftEntity(
            id: 2,
            content: 'Previous draft 2',
            createdAt: testDate2,
            updatedAt: testDate2,
          ),
        ]);

        // 初期状態
        expect(viewModel.drafts, isEmpty);

        // 読み込み
        await viewModel.loadDrafts();

        // 下書きが表示される
        expect(viewModel.drafts.length, 2);
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, isNull);
      });

      test('ユーザーが下書きをスワイプ削除する', () async {
        mockRepository.setDrafts([
          DraftEntity(
            id: 1,
            content: 'Draft to delete',
            createdAt: testDate,
            updatedAt: testDate,
          ),
          DraftEntity(
            id: 2,
            content: 'Draft to keep',
            createdAt: testDate2,
            updatedAt: testDate2,
          ),
        ]);

        await viewModel.loadDrafts();
        expect(viewModel.drafts.length, 2);

        // ユーザーが下書き1をスワイプ削除
        await viewModel.deleteDraft(1);

        // 削除された下書きは表示されない
        expect(viewModel.drafts.length, 1);
        expect(viewModel.drafts.first.content, 'Draft to keep');
      });

      test('Pull-to-refreshで下書き一覧を更新する', () async {
        mockRepository.setDrafts([
          DraftEntity(
            id: 1,
            content: 'Initial draft',
            createdAt: testDate,
            updatedAt: testDate,
          ),
        ]);

        await viewModel.loadDrafts();
        expect(viewModel.drafts.length, 1);

        // 外部で新しい下書きが追加された（別のデバイスなど）
        mockRepository.setDrafts([
          DraftEntity(
            id: 1,
            content: 'Initial draft',
            createdAt: testDate,
            updatedAt: testDate,
          ),
          DraftEntity(
            id: 2,
            content: 'New draft from another device',
            createdAt: testDate2,
            updatedAt: testDate2,
          ),
        ]);

        // Pull-to-refreshで再読み込み
        await viewModel.loadDrafts();

        expect(viewModel.drafts.length, 2);
      });
    });
  });
}
