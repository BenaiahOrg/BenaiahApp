import 'package:benaiah_app/core/network/bible_service.dart';
import 'package:benaiah_app/flavors.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youversion_sdk/youversion_sdk.dart';

void main() {
  setUpAll(() {
    F.appFlavor = Flavor.dev;
  });

  group('BibleService.parsePassageIds', () {
    test('returns single ID when no comma is present', () {
      final result = BibleService.parsePassageIds('JHN.3.16');
      expect(result, equals(['JHN.3.16']));
    });

    test(
      'parses comma-separated verses within the same book/chapter',
      () {
        final result = BibleService.parsePassageIds('JHN.3.16,19');
        expect(result, equals(['JHN.3.16', 'JHN.3.19']));
      },
    );

    test(
      'parses multiple comma-separated verses within the same book/chapter',
      () {
        final result = BibleService.parsePassageIds('JHN.3.16,17,19');
        expect(result, equals(['JHN.3.16', 'JHN.3.17', 'JHN.3.19']));
      },
    );

    test('parses fully qualified comma-separated passage IDs', () {
      final result = BibleService.parsePassageIds('JHN.3.16,JHN.3.19');
      expect(result, equals(['JHN.3.16', 'JHN.3.19']));
    });

    test('parses range mixed with comma-separated verses', () {
      final result = BibleService.parsePassageIds('JHN.3.16-17,19');
      expect(result, equals(['JHN.3.16-17', 'JHN.3.19']));
    });

    test('ignores empty components and trims whitespace gracefully', () {
      final result = BibleService.parsePassageIds('  JHN.3.16  ,  19  ');
      expect(result, equals(['JHN.3.16', 'JHN.3.19']));
    });
  });

  group('BibleService.combineReferences', () {
    // Instantiate a dummy BibleService to test its instance method
    // (Note: Since we are not calling getPassage in this unit test group,
    // the uninitialized _client won't cause issues for testing
    // combineReferences)
    late BibleService bibleService;

    setUp(() {
      bibleService = BibleService();
    });

    test('returns empty string when list is empty', () {
      final result = bibleService.combineReferences([]);
      expect(result, isEmpty);
    });

    test('returns single reference when list has one item', () {
      const passage = Passage(
        id: 'JHN.3.16',
        content: 'text',
        reference: 'John 3:16',
      );
      final result = bibleService.combineReferences([passage]);
      expect(result, equals('John 3:16'));
    });

    test('combines references sharing the same book/chapter prefix', () {
      const p1 = Passage(
        id: 'JHN.3.16',
        content: 'text1',
        reference: 'John 3:16',
      );
      const p2 = Passage(
        id: 'JHN.3.19',
        content: 'text2',
        reference: 'John 3:19',
      );
      final result = bibleService.combineReferences([p1, p2]);
      expect(result, equals('John 3: 16, 19'));
    });

    test('combines references with range sharing same prefix', () {
      const p1 = Passage(
        id: 'JHN.3.16-17',
        content: 'text1',
        reference: 'John 3:16-17',
      );
      const p2 = Passage(
        id: 'JHN.3.19',
        content: 'text2',
        reference: 'John 3:19',
      );
      final result = bibleService.combineReferences([p1, p2]);
      expect(result, equals('John 3: 16-17, 19'));
    });

    test(
      'falls back to simple join if references have different books/chapters',
      () {
        const p1 = Passage(
          id: 'JHN.3.16',
          content: 'text1',
          reference: 'John 3:16',
        );
        const p2 = Passage(
          id: 'JHN.4.4',
          content: 'text2',
          reference: 'John 4:4',
        );
        final result = bibleService.combineReferences([p1, p2]);
        expect(result, equals('John 3:16, John 4:4'));
      },
    );

    test('falls back to simple join if references do not contain colons', () {
      const p1 = Passage(
        id: 'JHN.3',
        content: 'text1',
        reference: 'John 3',
      );
      const p2 = Passage(
        id: 'JHN.4',
        content: 'text2',
        reference: 'John 4',
      );
      final result = bibleService.combineReferences([p1, p2]);
      expect(result, equals('John 3, John 4'));
    });
  });
}
