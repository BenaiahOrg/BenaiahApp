import 'package:benaiah_app/core/utils/scripture_linkifier.dart';
import 'package:flutter_test/flutter_test.dart';

String? _hrefIn(String markdown) => RegExp(
  r'\]\((https://www\.bible\.com/[^)]+)\)',
).firstMatch(markdown)?.group(1);

void main() {
  group('ScriptureLinkifier.linkify', () {
    test('links an English reference written inline', () {
      final result = ScriptureLinkifier.linkify(
        'eternal life” (John 3:16 NIV). While this verse',
      );
      expect(
        result,
        contains('[John 3:16](https://www.bible.com/bible/12/JHN.3.16)'),
      );
      expect(result, contains(' NIV). While this verse'));
    });

    test('links an Amharic reference using the Ethiopic colon', () {
      final result = ScriptureLinkifier.linkify('— ዮሐንስ 3፥16');
      expect(_hrefIn(result), 'https://www.bible.com/bible/12/JHN.3.16');
    });

    test('resolves numbered books, in both scripts', () {
      expect(
        _hrefIn(ScriptureLinkifier.linkify('1 John 4:8')),
        'https://www.bible.com/bible/12/1JN.4.8',
      );
      expect(
        _hrefIn(ScriptureLinkifier.linkify('፩ኛ ዮሐንስ 4፥8')),
        'https://www.bible.com/bible/12/1JN.4.8',
      );
      expect(
        _hrefIn(ScriptureLinkifier.linkify('2 Cor. 5:17')),
        'https://www.bible.com/bible/12/2CO.5.17',
      );
    });

    test('keeps ranges and verse lists in the passage id', () {
      expect(
        _hrefIn(ScriptureLinkifier.linkify('Matthew 6:25-27')),
        'https://www.bible.com/bible/12/MAT.6.25-27',
      );
      expect(
        _hrefIn(ScriptureLinkifier.linkify('John 3:16, 19')),
        'https://www.bible.com/bible/12/JHN.3.16,19',
      );
    });

    test('handles multi-word book names', () {
      expect(
        _hrefIn(ScriptureLinkifier.linkify('Song of Songs 2:4')),
        'https://www.bible.com/bible/12/SNG.2.4',
      );
      expect(
        _hrefIn(ScriptureLinkifier.linkify('1 ዜና መዋዕል 16፥11')),
        'https://www.bible.com/bible/12/1CH.16.11',
      );
    });

    test('points Amharic articles at the Amharic translation', () {
      expect(
        _hrefIn(ScriptureLinkifier.linkify('በ2ቆሮንቶስ 5፡7', languageCode: 'am')),
        'https://www.bible.com/bible/1260/2CO.5.7',
      );
      // Unknown languages keep the English default.
      expect(
        _hrefIn(ScriptureLinkifier.linkify('John 3:16', languageCode: 'fr')),
        'https://www.bible.com/bible/12/JHN.3.16',
      );
    });

    test('leaves already-linked references untouched', () {
      const input = '[John 3:16](https://www.bible.com/bible/111/JHN.3.16)';
      expect(ScriptureLinkifier.linkify(input), input);
    });

    test('ignores references inside html/jsx tags and bare urls', () {
      const input =
          '<ArticleHeader content="John 3:16 explained" />\n'
          'https://example.com/john-3:16';
      expect(ScriptureLinkifier.linkify(input), input);
    });

    test('reads Amharic spelling variants and prepositional prefixes', () {
      // ዘፀአት/ዘጸአት and ኢዮብ/እዮብ are both current in print.
      expect(
        _hrefIn(ScriptureLinkifier.linkify('ዘፀአት 34:14')),
        'https://www.bible.com/bible/12/EXO.34.14',
      );
      expect(
        _hrefIn(ScriptureLinkifier.linkify('እዮብ 19፥25')),
        'https://www.bible.com/bible/12/JOB.19.25',
      );
      expect(
        _hrefIn(ScriptureLinkifier.linkify('በዮሐንስ 15:13 ላይ')),
        'https://www.bible.com/bible/12/JHN.15.13',
      );
    });

    test('accepts the Ethiopic wordspace as a chapter separator', () {
      // Authors type ፡ (U+1361) far more often than ፥ (U+1365); the two are
      // near-identical on screen.
      expect(
        _hrefIn(ScriptureLinkifier.linkify('በ2ቆሮንቶስ 5፡7 በእምነት')),
        'https://www.bible.com/bible/12/2CO.5.7',
      );
      expect(
        _hrefIn(ScriptureLinkifier.linkify('በ2 ኛ ቆሮንቶስ 11፡2 ውስጥ')),
        'https://www.bible.com/bible/12/2CO.11.2',
      );
      expect(
        _hrefIn(ScriptureLinkifier.linkify('የዮሐንስ ወንጌል 3፡16')),
        'https://www.bible.com/bible/12/JHN.3.16',
      );
    });

    test('resolves an unambiguous Amharic abbreviation', () {
      expect(
        _hrefIn(ScriptureLinkifier.linkify('**ኤፌ 1:7**')),
        'https://www.bible.com/bible/12/EPH.1.7',
      );
    });

    test('keeps two-digit chapters out of the book name', () {
      expect(
        _hrefIn(ScriptureLinkifier.linkify('(Proverbs 27:4)')),
        'https://www.bible.com/bible/12/PRO.27.4',
      );
      expect(
        _hrefIn(ScriptureLinkifier.linkify('1Corinthians 13:4')),
        'https://www.bible.com/bible/12/1CO.13.4',
      );
    });

    test('skips prose words leading into the reference', () {
      final result = ScriptureLinkifier.linkify('as we read in Psalm 31:3.');
      expect(result, startsWith('as we read in ['));
      expect(_hrefIn(result), 'https://www.bible.com/bible/12/PSA.31.3');
    });

    test('ignores text that is not a reference', () {
      const input = 'The meeting is at 3:16 and Matthew agreed.';
      expect(ScriptureLinkifier.linkify(input), input);
    });
  });
}
