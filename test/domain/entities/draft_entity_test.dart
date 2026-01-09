import 'package:flutter_test/flutter_test.dart';
import 'package:my_x_draft_pad/domain/entities/draft_entity.dart';

void main() {
  final testDate = DateTime(2024, 1, 15, 10, 30);
  final testDate2 = DateTime(2024, 1, 16, 12, 0);

  group('DraftEntity', () {
    group('constructor', () {
      test('should create entity with all required fields', () {
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

      test('should allow null id for new drafts', () {
        final entity = DraftEntity(
          content: 'New draft',
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(entity.id, isNull);
      });
    });

    group('preview', () {
      test('should return empty string for empty content', () {
        final entity = DraftEntity(
          content: '',
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(entity.preview, '');
      });

      test('should return full content if 30 chars or less', () {
        final entity = DraftEntity(
          content: 'Short text',
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(entity.preview, 'Short text');
      });

      test('should truncate content longer than 30 chars with ellipsis', () {
        final entity = DraftEntity(
          content: 'This is a very long content that exceeds thirty characters',
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(entity.preview, 'This is a very long content th...');
        expect(entity.preview.length, 33); // 30 chars + '...'
      });

      test(
        'should return only first line with ellipsis for multiline content',
        () {
          final entity = DraftEntity(
            content: 'First line\nSecond line\nThird line',
            createdAt: testDate,
            updatedAt: testDate,
          );

          expect(entity.preview, 'First line...');
        },
      );

      test('should truncate first line if longer than 30 chars in multiline', () {
        final entity = DraftEntity(
          content:
              'This is a very long first line that exceeds thirty\nSecond line',
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(entity.preview, 'This is a very long first line...');
      });

      test('should handle exactly 30 characters', () {
        final content = '123456789012345678901234567890'; // exactly 30 chars
        final entity = DraftEntity(
          content: content,
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(entity.preview, content);
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

      test('should return copy with updated id', () {
        final copy = original.copyWith(id: 2);

        expect(copy.id, 2);
        expect(copy.content, original.content);
        expect(copy.createdAt, original.createdAt);
        expect(copy.updatedAt, original.updatedAt);
      });

      test('should return copy with updated content', () {
        final copy = original.copyWith(content: 'New content');

        expect(copy.id, original.id);
        expect(copy.content, 'New content');
        expect(copy.createdAt, original.createdAt);
        expect(copy.updatedAt, original.updatedAt);
      });

      test('should return copy with updated updatedAt', () {
        final copy = original.copyWith(updatedAt: testDate2);

        expect(copy.id, original.id);
        expect(copy.content, original.content);
        expect(copy.createdAt, original.createdAt);
        expect(copy.updatedAt, testDate2);
      });

      test('should return identical copy when no parameters provided', () {
        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.content, original.content);
        expect(copy.createdAt, original.createdAt);
        expect(copy.updatedAt, original.updatedAt);
      });

      test('should return copy with multiple updated fields', () {
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

    group('equality', () {
      test('should be equal for same values', () {
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

      test('should not be equal for different id', () {
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

      test('should not be equal for different content', () {
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

      test('should be equal for same instance', () {
        final entity = DraftEntity(
          id: 1,
          content: 'Content',
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(entity, equals(entity));
      });
    });

    group('hashCode', () {
      test('should return same hashCode for equal entities', () {
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

      test('should return different hashCode for different entities', () {
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
}
