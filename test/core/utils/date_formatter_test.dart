import 'package:flutter_test/flutter_test.dart';
import 'package:my_x_draft_pad/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    group('formatDateTime', () {
      // 注意: このテストはDateTime.now()に依存するため、
      // 実行タイミングによって結果が変わる可能性があります。
      // 実際のプロダクションコードでは、時刻を注入可能にすることを推奨します。

      group('「たった今」表示', () {
        test('0秒前は「たった今」を返す', () {
          final now = DateTime.now();
          final result = DateFormatter.formatDateTime(now);

          expect(result, 'たった今');
        });

        test('30秒前は「たった今」を返す', () {
          final dateTime = DateTime.now().subtract(const Duration(seconds: 30));
          final result = DateFormatter.formatDateTime(dateTime);

          expect(result, 'たった今');
        });

        test('59秒前は「たった今」を返す', () {
          final dateTime = DateTime.now().subtract(const Duration(seconds: 59));
          final result = DateFormatter.formatDateTime(dateTime);

          expect(result, 'たった今');
        });
      });

      group('「X分前」表示', () {
        test('1分前は「1分前」を返す', () {
          final dateTime = DateTime.now().subtract(const Duration(minutes: 1));
          final result = DateFormatter.formatDateTime(dateTime);

          expect(result, '1分前');
        });

        test('30分前は「30分前」を返す', () {
          final dateTime = DateTime.now().subtract(const Duration(minutes: 30));
          final result = DateFormatter.formatDateTime(dateTime);

          expect(result, '30分前');
        });

        test('59分前は「59分前」を返す', () {
          final dateTime = DateTime.now().subtract(const Duration(minutes: 59));
          final result = DateFormatter.formatDateTime(dateTime);

          expect(result, '59分前');
        });
      });

      group('「X時間前」表示', () {
        test('1時間前は「1時間前」を返す', () {
          final dateTime = DateTime.now().subtract(const Duration(hours: 1));
          final result = DateFormatter.formatDateTime(dateTime);

          expect(result, '1時間前');
        });

        test('12時間前は「12時間前」を返す', () {
          final dateTime = DateTime.now().subtract(const Duration(hours: 12));
          final result = DateFormatter.formatDateTime(dateTime);

          expect(result, '12時間前');
        });

        test('23時間前は「23時間前」を返す', () {
          final dateTime = DateTime.now().subtract(const Duration(hours: 23));
          final result = DateFormatter.formatDateTime(dateTime);

          expect(result, '23時間前');
        });
      });

      group('「昨日」表示', () {
        test('1日前は「昨日」を返す', () {
          final dateTime = DateTime.now().subtract(const Duration(days: 1));
          final result = DateFormatter.formatDateTime(dateTime);

          expect(result, '昨日');
        });

        test('24時間前は「昨日」を返す', () {
          final dateTime = DateTime.now().subtract(const Duration(hours: 24));
          final result = DateFormatter.formatDateTime(dateTime);

          expect(result, '昨日');
        });
      });

      group('「X日前」表示', () {
        test('2日前は「2日前」を返す', () {
          final dateTime = DateTime.now().subtract(const Duration(days: 2));
          final result = DateFormatter.formatDateTime(dateTime);

          expect(result, '2日前');
        });

        test('3日前は「3日前」を返す', () {
          final dateTime = DateTime.now().subtract(const Duration(days: 3));
          final result = DateFormatter.formatDateTime(dateTime);

          expect(result, '3日前');
        });

        test('6日前は「6日前」を返す', () {
          final dateTime = DateTime.now().subtract(const Duration(days: 6));
          final result = DateFormatter.formatDateTime(dateTime);

          expect(result, '6日前');
        });
      });

      group('日付表示 (7日以上前)', () {
        test('7日前は日付形式を返す', () {
          final dateTime = DateTime.now().subtract(const Duration(days: 7));
          final result = DateFormatter.formatDateTime(dateTime);

          // YYYY/MM/DD 形式であることを確認
          expect(result, matches(RegExp(r'^\d{4}/\d{2}/\d{2}$')));
        });

        test('30日前は日付形式を返す', () {
          final dateTime = DateTime.now().subtract(const Duration(days: 30));
          final result = DateFormatter.formatDateTime(dateTime);

          expect(result, matches(RegExp(r'^\d{4}/\d{2}/\d{2}$')));
        });

        test('365日前は日付形式を返す', () {
          final dateTime = DateTime.now().subtract(const Duration(days: 365));
          final result = DateFormatter.formatDateTime(dateTime);

          expect(result, matches(RegExp(r'^\d{4}/\d{2}/\d{2}$')));
        });
      });

      group('日付形式の正確性', () {
        test('2024年1月5日は「2024/01/05」形式で返す', () {
          // 7日以上前の日付を作成（テスト実行日に依存しないように遠い過去を使用）
          final dateTime = DateTime(2024, 1, 5, 10, 30);
          final result = DateFormatter.formatDateTime(dateTime);

          expect(result, '2024/01/05');
        });

        test('2023年12月25日は「2023/12/25」形式で返す', () {
          final dateTime = DateTime(2023, 12, 25, 14, 0);
          final result = DateFormatter.formatDateTime(dateTime);

          expect(result, '2023/12/25');
        });

        test('月と日が1桁の場合はゼロパディングされる', () {
          final dateTime = DateTime(2024, 3, 7, 8, 0);
          final result = DateFormatter.formatDateTime(dateTime);

          expect(result, '2024/03/07');
        });

        test('年の境界を正しく処理する', () {
          final dateTime = DateTime(2024, 1, 1, 0, 0);
          final result = DateFormatter.formatDateTime(dateTime);

          expect(result, '2024/01/01');
        });

        test('年末の日付を正しく処理する', () {
          final dateTime = DateTime(2023, 12, 31, 23, 59);
          final result = DateFormatter.formatDateTime(dateTime);

          expect(result, '2023/12/31');
        });
      });

      group('境界値', () {
        test('ちょうど60秒前は「1分前」を返す', () {
          final dateTime = DateTime.now().subtract(const Duration(seconds: 60));
          final result = DateFormatter.formatDateTime(dateTime);

          expect(result, '1分前');
        });

        test('ちょうど60分前は「1時間前」を返す', () {
          final dateTime = DateTime.now().subtract(const Duration(minutes: 60));
          final result = DateFormatter.formatDateTime(dateTime);

          expect(result, '1時間前');
        });
      });
    });

    group('formatFullDateTime', () {
      group('正常系', () {
        test('日時を「YYYY/MM/DD HH:mm」形式で返す', () {
          final dateTime = DateTime(2024, 1, 15, 10, 30);
          final result = DateFormatter.formatFullDateTime(dateTime);

          expect(result, '2024/01/15 10:30');
        });

        test('深夜0時を正しくフォーマットする', () {
          final dateTime = DateTime(2024, 1, 1, 0, 0);
          final result = DateFormatter.formatFullDateTime(dateTime);

          expect(result, '2024/01/01 00:00');
        });

        test('23:59を正しくフォーマットする', () {
          final dateTime = DateTime(2024, 12, 31, 23, 59);
          final result = DateFormatter.formatFullDateTime(dateTime);

          expect(result, '2024/12/31 23:59');
        });
      });

      group('ゼロパディング', () {
        test('月が1桁の場合はゼロパディングされる', () {
          final dateTime = DateTime(2024, 3, 15, 10, 30);
          final result = DateFormatter.formatFullDateTime(dateTime);

          expect(result, '2024/03/15 10:30');
        });

        test('日が1桁の場合はゼロパディングされる', () {
          final dateTime = DateTime(2024, 10, 5, 10, 30);
          final result = DateFormatter.formatFullDateTime(dateTime);

          expect(result, '2024/10/05 10:30');
        });

        test('時が1桁の場合はゼロパディングされる', () {
          final dateTime = DateTime(2024, 10, 15, 8, 30);
          final result = DateFormatter.formatFullDateTime(dateTime);

          expect(result, '2024/10/15 08:30');
        });

        test('分が1桁の場合はゼロパディングされる', () {
          final dateTime = DateTime(2024, 10, 15, 10, 5);
          final result = DateFormatter.formatFullDateTime(dateTime);

          expect(result, '2024/10/15 10:05');
        });

        test('全ての値が1桁の場合もゼロパディングされる', () {
          final dateTime = DateTime(2024, 1, 5, 8, 5);
          final result = DateFormatter.formatFullDateTime(dateTime);

          expect(result, '2024/01/05 08:05');
        });
      });

      group('異なる年の処理', () {
        test('過去の年を正しくフォーマットする', () {
          final dateTime = DateTime(2020, 6, 15, 14, 30);
          final result = DateFormatter.formatFullDateTime(dateTime);

          expect(result, '2020/06/15 14:30');
        });

        test('未来の年を正しくフォーマットする', () {
          final dateTime = DateTime(2030, 12, 25, 9, 0);
          final result = DateFormatter.formatFullDateTime(dateTime);

          expect(result, '2030/12/25 09:00');
        });

        test('2000年を正しくフォーマットする', () {
          final dateTime = DateTime(2000, 1, 1, 0, 0);
          final result = DateFormatter.formatFullDateTime(dateTime);

          expect(result, '2000/01/01 00:00');
        });
      });

      group('特殊な日時', () {
        test('うるう年の2月29日を正しくフォーマットする', () {
          final dateTime = DateTime(2024, 2, 29, 12, 0);
          final result = DateFormatter.formatFullDateTime(dateTime);

          expect(result, '2024/02/29 12:00');
        });

        test('月末日を正しくフォーマットする', () {
          // 4月30日
          final dateTime1 = DateTime(2024, 4, 30, 15, 45);
          expect(DateFormatter.formatFullDateTime(dateTime1), '2024/04/30 15:45');

          // 6月30日
          final dateTime2 = DateTime(2024, 6, 30, 15, 45);
          expect(DateFormatter.formatFullDateTime(dateTime2), '2024/06/30 15:45');

          // 2月28日（非うるう年）
          final dateTime3 = DateTime(2023, 2, 28, 15, 45);
          expect(DateFormatter.formatFullDateTime(dateTime3), '2023/02/28 15:45');
        });
      });

      group('現在時刻の処理', () {
        test('現在時刻を正しくフォーマットできる', () {
          final now = DateTime.now();
          final result = DateFormatter.formatFullDateTime(now);

          // フォーマットが正しいことを確認
          expect(result, matches(RegExp(r'^\d{4}/\d{2}/\d{2} \d{2}:\d{2}$')));

          // 値が現在時刻と一致することを確認
          final year = now.year.toString();
          final month = now.month.toString().padLeft(2, '0');
          final day = now.day.toString().padLeft(2, '0');
          final hour = now.hour.toString().padLeft(2, '0');
          final minute = now.minute.toString().padLeft(2, '0');

          expect(result, '$year/$month/$day $hour:$minute');
        });
      });
    });

    group('プライベートコンストラクタ', () {
      test('DateFormatterはインスタンス化できない（staticメソッドのみ）', () {
        // DateFormatter._() プライベートコンストラクタのため、
        // 外部からのインスタンス化はコンパイルエラーになる
        // このテストはドキュメント的な意味で存在

        // staticメソッドが直接呼び出せることを確認
        expect(DateFormatter.formatDateTime(DateTime.now()), isA<String>());
        expect(DateFormatter.formatFullDateTime(DateTime.now()), isA<String>());
      });
    });
  });
}
