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
        contains('[John 3:16](https://www.bible.com/bible/111/JHN.3.16)'),
      );
      expect(result, contains(' NIV). While this verse'));
    });

    test('links an Amharic reference using the Ethiopic colon', () {
      final result = ScriptureLinkifier.linkify('— ዮሐንስ 3፥16');
      expect(_hrefIn(result), 'https://www.bible.com/bible/111/JHN.3.16');
    });

    test('resolves numbered books, in both scripts', () {
      expect(
        _hrefIn(ScriptureLinkifier.linkify('1 John 4:8')),
        'https://www.bible.com/bible/111/1JN.4.8',
      );
      expect(
        _hrefIn(ScriptureLinkifier.linkify('፩ኛ ዮሐንስ 4፥8')),
        'https://www.bible.com/bible/111/1JN.4.8',
      );
      expect(
        _hrefIn(ScriptureLinkifier.linkify('2 Cor. 5:17')),
        'https://www.bible.com/bible/111/2CO.5.17',
      );
    });

    test('keeps ranges and verse lists in the passage id', () {
      expect(
        _hrefIn(ScriptureLinkifier.linkify('Matthew 6:25-27')),
        'https://www.bible.com/bible/111/MAT.6.25-27',
      );
      expect(
        _hrefIn(ScriptureLinkifier.linkify('John 3:16, 19')),
        'https://www.bible.com/bible/111/JHN.3.16,19',
      );
    });

    test('handles multi-word book names', () {
      expect(
        _hrefIn(ScriptureLinkifier.linkify('Song of Songs 2:4')),
        'https://www.bible.com/bible/111/SNG.2.4',
      );
      expect(
        _hrefIn(ScriptureLinkifier.linkify('1 ዜና መዋዕል 16፥11')),
        'https://www.bible.com/bible/111/1CH.16.11',
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
        'https://www.bible.com/bible/111/JHN.3.16',
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
        'https://www.bible.com/bible/111/EXO.34.14',
      );
      expect(
        _hrefIn(ScriptureLinkifier.linkify('እዮብ 19፥25')),
        'https://www.bible.com/bible/111/JOB.19.25',
      );
      expect(
        _hrefIn(ScriptureLinkifier.linkify('በዮሐንስ 15:13 ላይ')),
        'https://www.bible.com/bible/111/JHN.15.13',
      );
    });

    test('accepts the Ethiopic wordspace as a chapter separator', () {
      // Authors type ፡ (U+1361) far more often than ፥ (U+1365); the two are
      // near-identical on screen.
      expect(
        _hrefIn(ScriptureLinkifier.linkify('በ2ቆሮንቶስ 5፡7 በእምነት')),
        'https://www.bible.com/bible/111/2CO.5.7',
      );
      expect(
        _hrefIn(ScriptureLinkifier.linkify('በ2 ኛ ቆሮንቶስ 11፡2 ውስጥ')),
        'https://www.bible.com/bible/111/2CO.11.2',
      );
      expect(
        _hrefIn(ScriptureLinkifier.linkify('የዮሐንስ ወንጌል 3፡16')),
        'https://www.bible.com/bible/111/JHN.3.16',
      );
    });

    test('resolves an unambiguous Amharic abbreviation', () {
      expect(
        _hrefIn(ScriptureLinkifier.linkify('**ኤፌ 1:7**')),
        'https://www.bible.com/bible/111/EPH.1.7',
      );
    });

    test('keeps two-digit chapters out of the book name', () {
      expect(
        _hrefIn(ScriptureLinkifier.linkify('(Proverbs 27:4)')),
        'https://www.bible.com/bible/111/PRO.27.4',
      );
      expect(
        _hrefIn(ScriptureLinkifier.linkify('1Corinthians 13:4')),
        'https://www.bible.com/bible/111/1CO.13.4',
      );
    });

    test('skips prose words leading into the reference', () {
      final result = ScriptureLinkifier.linkify('as we read in Psalm 31:3.');
      expect(result, startsWith('as we read in ['));
      expect(_hrefIn(result), 'https://www.bible.com/bible/111/PSA.31.3');
    });

    test('ignores text that is not a reference', () {
      const input = 'The meeting is at 3:16 and Matthew agreed.';
      expect(ScriptureLinkifier.linkify(input), input);
    });

    test('opens the translation the author cites, when licensed', () {
      String? hrefFor(String text) => _hrefIn(ScriptureLinkifier.linkify(text));

      expect(
        hrefFor('(Psalm 18:2, AMP)'),
        'https://www.bible.com/bible/1588/PSA.18.2',
      );
      expect(
        hrefFor('(Romans 5:5, NASB)'),
        'https://www.bible.com/bible/2692/ROM.5.5',
      );
      expect(
        hrefFor('(Isaiah 55:8-9 (NIV))'),
        'https://www.bible.com/bible/111/ISA.55.8-9',
      );
      expect(
        hrefFor('In John 15:13, (NIV) Jesus says'),
        'https://www.bible.com/bible/111/JHN.15.13',
      );
    });

    test('maps unlicensed translations to the closest licensed one', () {
      String? hrefFor(String text) => _hrefIn(ScriptureLinkifier.linkify(text));

      // KJV and NKJV are not available to the app key; ASV shares their
      // wording.
      expect(
        hrefFor('Psalm 107:20 KJV.'),
        'https://www.bible.com/bible/12/PSA.107.20',
      );
      expect(
        hrefFor('1 Corinthians 13:13 NKJV'),
        'https://www.bible.com/bible/12/1CO.13.13',
      );
      // NLT and ESV fall back to the language default.
      expect(
        hrefFor('(1 Samuel 17:45 NLT)'),
        'https://www.bible.com/bible/111/1SA.17.45',
      );
    });

    test('keeps the translation label out of the link text', () {
      expect(
        ScriptureLinkifier.linkify('Psalm 18:2, AMP'),
        '[Psalm 18:2](https://www.bible.com/bible/1588/PSA.18.2), AMP',
      );
    });

    test('ignores prose after a reference that is not a translation', () {
      expect(
        _hrefIn(ScriptureLinkifier.linkify('As Proverbs 18:10 says, trust.')),
        'https://www.bible.com/bible/111/PRO.18.10',
      );
      expect(
        _hrefIn(
          ScriptureLinkifier.linkify('1 ቆሮንቶስ 13:13(አመት)', languageCode: 'am'),
        ),
        'https://www.bible.com/bible/1260/1CO.13.13',
      );
    });
  });
}
