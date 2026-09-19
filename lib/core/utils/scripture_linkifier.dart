/// Rewrites plain-text scripture references inside markdown into the
/// `bible.com` links the rest of the app already understands.
///
/// Devotionals and writings are authored with bare references
/// ("John 3:16 NIV", "— ዮሐንስ 3፥16") rather than markdown links, so nothing
/// downstream could detect them. This sits between the text and
/// `BibleService.parseBibleLink`, so neither the authoring format nor the
/// `youversion_sdk` package has to change.
abstract class ScriptureLinkifier {
  /// Bible version per app language: NASV (አዲሱ መደበኛ ትርጒም) for Amharic,
  /// ASV for everything else. `BibleService.getPassage` falls back to 12 if a
  /// version request fails, so an unreachable translation still reads.
  // ponytail: one version per language; add a picker only if users ask.
  static const _bibleIds = {'am': '1260', 'en': '12'};
  static const _defaultBibleId = '12';

  /// Returns [markdown] with every recognized bare reference replaced by
  /// `[original text](https://www.bible.com/bible/<version>/BOOK.CH.VERSES)`.
  ///
  /// Text already inside a markdown link, a bare URL or an HTML/JSX-ish tag is
  /// left alone, so content that *does* use the old link format is untouched.
  ///
  /// Chapter-only references ("Genesis 22") are deliberately ignored: they are
  /// indistinguishable from ordinary prose without a verse number.
  /// [languageCode] selects the translation the popover will fetch, so an
  /// Amharic article opens Amharic scripture.
  static String linkify(String markdown, {String languageCode = 'en'}) {
    if (markdown.isEmpty) return markdown;

    final bibleId = _bibleIds[languageCode] ?? _defaultBibleId;

    return markdown.replaceAllMapped(_pattern, (match) {
      final whole = match.group(0)!;
      // Group 1 matched => protected chunk, pass it through.
      if (match.group(1) != null) return whole;

      final candidate = match.group(2)!;
      final words = _word.allMatches(candidate).toList();

      // The regex grabs up to three leading words because book names can be
      // numbered and multi-word ("1 ዜና መዋዕል", "Song of Songs"). Try the
      // longest run first, dropping leading words that are just prose.
      for (var start = 0; start < words.length; start++) {
        final name = candidate.substring(words[start].start);
        final code = _lookup(
          words.sublist(start).map((w) => w[0]!).toList(),
        );
        if (code == null) continue;

        final verses = match
            .group(4)!
            .replaceAll(' ', '')
            .replaceAll('፣', ',')
            .replaceAll(RegExp('[–—]'), '-');

        return '${candidate.substring(0, words[start].start)}'
            '[$name${whole.substring(candidate.length)}]'
            '(https://www.bible.com/bible/$bibleId'
            '/$code.${match.group(3)}.$verses)';
      }
      return whole;
    });
  }

  /// Resolves [words] to a USFM book code, retrying without the Amharic
  /// prepositional prefix authors attach to the book name ("በዮሐንስ").
  static String? _lookup(List<String> words) {
    final key = words.map(_fold).join();
    final direct = _folded[key];
    if (direct != null) return direct;

    // Amharic authors abbreviate ("ኤፌ" for ኤፌሶን). Accept a shortened
    // Ethiopic name when it can only mean one book.
    if (words.length == 1 && key.length >= 2 && _ethiopic.hasMatch(key)) {
      final hits = _folded.entries
          .where((e) => e.key.startsWith(key))
          .map((e) => e.value)
          .toSet();
      if (hits.length == 1) return hits.first;
    }

    for (final prefix in _amharicPrefixes) {
      if (words.first.startsWith(prefix)) {
        final stripped = [
          words.first.substring(prefix.length),
          ...words.skip(1),
        ];
        if (stripped.first.isEmpty) continue;
        final hit = _folded[stripped.map(_fold).join()];
        if (hit != null) return hit;
      }
    }
    return null;
  }

  static final RegExp _ethiopic = RegExp('[ሀ-፿]');

  static const _amharicPrefixes = ['እንደ', 'ስለ', 'ወደ', 'በ', 'ከ', 'ለ', 'ያ'];

  /// Normalizes one word for lookup.
  ///
  /// Ethiopic syllables are folded to their consonant row and homophone
  /// families are merged, so the many accepted spellings of a book name
  /// ("ዘጸአት"/"ዘፀአት", "ኢዮብ"/"እዮብ") collapse onto one key.
  static String _fold(String word) {
    final buffer = StringBuffer();
    final cleaned = word.toLowerCase().replaceAll('ኛ', '').replaceAll('.', '');
    for (final rune in cleaned.runes) {
      if (rune >= 0x1369 && rune <= 0x136B) {
        buffer.write(rune - 0x1368); // Ethiopic ፩ ፪ ፫
      } else if (rune >= 0x1200 && rune <= 0x137F) {
        final row = rune - (rune - 0x1200) % 8;
        buffer.writeCharCode(_homophoneRows[row] ?? row);
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString().replaceFirstMapped(
      RegExp(r'^(iii|ii|i)$'),
      (m) => '${m.group(1)!.length}',
    );
  }

  /// Ethiopic rows that sound alike in Amharic and get spelled either way.
  static const Map<int, int> _homophoneRows = {
    0x1210: 0x1200, // ሐ -> ሀ
    0x1280: 0x1200, // ኀ -> ሀ
    0x1288: 0x1200, // ኈ -> ሀ
    0x12B8: 0x1200, // ኸ -> ሀ
    0x1220: 0x1230, // ሠ -> ሰ
    0x1340: 0x1338, // ፀ -> ጸ
    0x12D0: 0x12A0, // ዐ -> አ
    0x1248: 0x1240, // ቈ -> ቀ
    0x12B0: 0x12A8, // ኰ -> ከ
    0x1310: 0x1308, // ጐ -> ገ
  };

  /// Alias (number prefix + normalized name) to USFM book code.
  static const Map<String, String> _books = {
    // Old Testament — English
    'genesis': 'GEN', 'gen': 'GEN',
    'exodus': 'EXO', 'exod': 'EXO', 'exo': 'EXO', 'ex': 'EXO',
    'leviticus': 'LEV', 'lev': 'LEV',
    'numbers': 'NUM', 'num': 'NUM',
    'deuteronomy': 'DEU', 'deut': 'DEU', 'deu': 'DEU',
    'joshua': 'JOS', 'josh': 'JOS', 'jos': 'JOS',
    'judges': 'JDG', 'judg': 'JDG', 'jdg': 'JDG',
    'ruth': 'RUT', 'rut': 'RUT',
    '1samuel': '1SA', '1sam': '1SA', '1sa': '1SA',
    '2samuel': '2SA', '2sam': '2SA', '2sa': '2SA',
    '1kings': '1KI', '1kgs': '1KI', '1ki': '1KI',
    '2kings': '2KI', '2kgs': '2KI', '2ki': '2KI',
    '1chronicles': '1CH', '1chron': '1CH', '1chr': '1CH', '1ch': '1CH',
    '2chronicles': '2CH', '2chron': '2CH', '2chr': '2CH', '2ch': '2CH',
    'ezra': 'EZR', 'ezr': 'EZR',
    'nehemiah': 'NEH', 'neh': 'NEH',
    'esther': 'EST', 'esth': 'EST', 'est': 'EST',
    'job': 'JOB',
    'psalms': 'PSA', 'psalm': 'PSA', 'psa': 'PSA', 'ps': 'PSA',
    'proverbs': 'PRO', 'prov': 'PRO', 'pro': 'PRO', 'prv': 'PRO',
    'ecclesiastes': 'ECC', 'eccl': 'ECC', 'ecc': 'ECC',
    'songofsongs': 'SNG', 'songofsolomon': 'SNG', 'song': 'SNG', 'sos': 'SNG',
    'isaiah': 'ISA', 'isa': 'ISA',
    'jeremiah': 'JER', 'jer': 'JER',
    'lamentations': 'LAM', 'lam': 'LAM',
    'ezekiel': 'EZK', 'ezek': 'EZK', 'eze': 'EZK',
    'daniel': 'DAN', 'dan': 'DAN',
    'hosea': 'HOS', 'hos': 'HOS',
    'joel': 'JOL', 'joe': 'JOL',
    'amos': 'AMO', 'amo': 'AMO',
    'obadiah': 'OBA', 'obad': 'OBA', 'oba': 'OBA',
    'jonah': 'JON', 'jon': 'JON',
    'micah': 'MIC', 'mic': 'MIC',
    'nahum': 'NAM', 'nah': 'NAM',
    'habakkuk': 'HAB', 'hab': 'HAB',
    'zephaniah': 'ZEP', 'zeph': 'ZEP', 'zep': 'ZEP',
    'haggai': 'HAG', 'hag': 'HAG',
    'zechariah': 'ZEC', 'zech': 'ZEC', 'zec': 'ZEC',
    'malachi': 'MAL', 'mal': 'MAL',

    // New Testament — English
    'matthew': 'MAT', 'matt': 'MAT', 'mat': 'MAT', 'mt': 'MAT',
    'mark': 'MRK', 'mrk': 'MRK', 'mk': 'MRK',
    'luke': 'LUK', 'luk': 'LUK', 'lk': 'LUK',
    'john': 'JHN', 'jhn': 'JHN', 'jn': 'JHN',
    'acts': 'ACT', 'act': 'ACT',
    'romans': 'ROM', 'rom': 'ROM',
    '1corinthians': '1CO', '1cor': '1CO', '1co': '1CO',
    '2corinthians': '2CO', '2cor': '2CO', '2co': '2CO',
    'galatians': 'GAL', 'gal': 'GAL',
    'ephesians': 'EPH', 'eph': 'EPH',
    'philippians': 'PHP', 'phil': 'PHP', 'php': 'PHP',
    'colossians': 'COL', 'col': 'COL',
    '1thessalonians': '1TH', '1thess': '1TH', '1th': '1TH',
    '2thessalonians': '2TH', '2thess': '2TH', '2th': '2TH',
    '1timothy': '1TI', '1tim': '1TI', '1ti': '1TI',
    '2timothy': '2TI', '2tim': '2TI', '2ti': '2TI',
    'titus': 'TIT', 'tit': 'TIT',
    'philemon': 'PHM', 'phlm': 'PHM', 'phm': 'PHM',
    'hebrews': 'HEB', 'heb': 'HEB',
    'james': 'JAS', 'jas': 'JAS', 'jam': 'JAS',
    '1peter': '1PE', '1pet': '1PE', '1pe': '1PE',
    '2peter': '2PE', '2pet': '2PE', '2pe': '2PE',
    '1john': '1JN', '1jhn': '1JN', '1jn': '1JN',
    '2john': '2JN', '2jhn': '2JN', '2jn': '2JN',
    '3john': '3JN', '3jhn': '3JN', '3jn': '3JN',
    'jude': 'JUD',
    'revelation': 'REV', 'rev': 'REV',

    // Old Testament — Amharic
    'ዘፍጥረት': 'GEN', 'ኦሪትዘፍጥረት': 'GEN',
    'ዘጸአት': 'EXO', 'ኦሪትዘጸአት': 'EXO',
    'ዘሌዋውያን': 'LEV', 'ኦሪትዘሌዋውያን': 'LEV',
    'ዘኍልቍ': 'NUM', 'ዘኁልቁ': 'NUM', 'ዘቁጥር': 'NUM',
    'ዘዳግም': 'DEU', 'ኦሪትዘዳግም': 'DEU',
    'ኢያሱ': 'JOS', 'መጽሐፈኢያሱ': 'JOS',
    'መሳፍንት': 'JDG', 'መጽሐፈመሳፍንት': 'JDG',
    'ሩት': 'RUT',
    '1ሳሙኤል': '1SA', '2ሳሙኤል': '2SA',
    '1ነገሥት': '1KI', '1ነገስት': '1KI', '2ነገሥት': '2KI', '2ነገስት': '2KI',
    '1ዜናመዋዕል': '1CH', '2ዜናመዋዕል': '2CH',
    'ዕዝራ': 'EZR', 'እዝራ': 'EZR',
    'ነህምያ': 'NEH', 'ነኬምያ': 'NEH',
    'አስቴር': 'EST',
    'ኢዮብ': 'JOB',
    'መዝሙር': 'PSA', 'መዝሙረዳዊት': 'PSA', 'መዝ': 'PSA',
    'ምሳሌ': 'PRO', 'መጽሐፈምሳሌ': 'PRO',
    'መክብብ': 'ECC',
    'መኃልየመኃልይ': 'SNG', 'መኃልይ': 'SNG',
    'ኢሳይያስ': 'ISA', 'ኢሳያስ': 'ISA',
    'ኤርምያስ': 'JER',
    'ሰቆቃወኤርምያስ': 'LAM', 'ሰቆቃው': 'LAM',
    'ሕዝቅኤል': 'EZK', 'ህዝቅኤል': 'EZK',
    'ዳንኤል': 'DAN',
    'ሆሴዕ': 'HOS',
    'ኢዩኤል': 'JOL', 'ኢዮኤል': 'JOL',
    'አሞጽ': 'AMO',
    'አብድዩ': 'OBA',
    'ዮናስ': 'JON',
    'ሚክያስ': 'MIC',
    'ናሆም': 'NAM',
    'ዕንባቆም': 'HAB', 'እንባቆም': 'HAB',
    'ሶፎንያስ': 'ZEP',
    'ሐጌ': 'HAG',
    'ዘካርያስ': 'ZEC',
    'ሚልክያስ': 'MAL',

    // New Testament — Amharic
    'ማቴዎስ': 'MAT', 'የማቴዎስወንጌል': 'MAT',
    'ማርቆስ': 'MRK', 'የማርቆስወንጌል': 'MRK',
    'ሉቃስ': 'LUK', 'የሉቃስወንጌል': 'LUK',
    'ዮሐንስ': 'JHN', 'ዮሀንስ': 'JHN', 'የዮሐንስወንጌል': 'JHN',
    // Folding drops vowels, so "ዮሐ" alone collides with "የሐዋርያት ሥራ".
    'ዮሐ': 'JHN',
    'የሐዋርያትሥራ': 'ACT', 'ሐዋርያትሥራ': 'ACT',
    'የሐዋርያትስራ': 'ACT', 'ሐዋርያትስራ': 'ACT',
    'ሮሜ': 'ROM',
    '1ቆሮንቶስ': '1CO', '2ቆሮንቶስ': '2CO',
    'ገላትያ': 'GAL',
    'ኤፌሶን': 'EPH',
    'ፊልጵስዩስ': 'PHP',
    'ቆላስይስ': 'COL',
    '1ተሰሎንቄ': '1TH', '2ተሰሎንቄ': '2TH',
    '1ጢሞቴዎስ': '1TI', '2ጢሞቴዎስ': '2TI',
    'ቲቶ': 'TIT',
    'ፊልሞና': 'PHM',
    'ዕብራውያን': 'HEB', 'እብራውያን': 'HEB',
    'ያዕቆብ': 'JAS',
    '1ጴጥሮስ': '1PE', '2ጴጥሮስ': '2PE',
    '1ዮሐንስ': '1JN', '2ዮሐንስ': '2JN', '3ዮሐንስ': '3JN',
    '1ዮሀንስ': '1JN', '2ዮሀንስ': '2JN', '3ዮሀንስ': '3JN',
    'ይሁዳ': 'JUD',
    'ራእይ': 'REV', 'ራዕይ': 'REV', 'የዮሐንስራእይ': 'REV', 'የዮሐንስራዕይ': 'REV',
  };

  /// The alias table keyed by folded form, so lookups survive spelling and
  /// vowel-order variation.
  static final Map<String, String> _folded = {
    for (final entry in _books.entries) _fold(entry.key): entry.value,
  };

  /// A word of a reference candidate. Leading words may be a book number
  /// ("1 John"); the book name itself never contains digits — letting it
  /// would make it swallow the chapter number.
  static final RegExp _word = RegExp('[0-9ሀ-፿a-zA-Z]+');
  static const _namePattern = '[0-9]?[ሀ-፿a-zA-Z]+';

  static final RegExp _pattern = RegExp(
    // 1: protected — existing markdown link, bare URL, or HTML/JSX-ish tag.
    r'(\[[^\]\n]*\]\([^)\s]*\)|https?://\S+|<[^>\n]+>)'
    '|'
    // 2: up to three words leading into the reference, 3: chapter,
    // 4: verse spec (single, range, or list).
    '((?:${_word.pattern}[ .]){0,2}$_namePattern)'
    r'\.? ?'
    r'(\d{1,3})'
    // Authors type the chapter:verse separator as an ASCII colon, an
    // Ethiopic colon (፥), or — most often — an Ethiopic wordspace (፡),
    // which looks the same on screen.
    ' ?[:፡፥፦] ?'
    r'(\d{1,3}(?: ?[-–—] ?\d{1,3})?(?: ?[,፣] ?\d{1,3}(?: ?[-–—] ?\d{1,3})?)*)',
  );
}
