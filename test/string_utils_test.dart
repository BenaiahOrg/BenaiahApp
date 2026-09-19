import 'package:benaiah_app/core/utils/string_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StringUtils.fixMissingWordBoundary', () {
    test('inserts a space between a digit and a run-on capitalized word', () {
      final result = StringUtils.fixMissingWordBoundary(
        "Benaiah Podcast Episode 01This's an introductory episode.",
      );
      expect(
        result,
        "Benaiah Podcast Episode 01 This's an introductory episode.",
      );
    });

    test('leaves normal text untouched', () {
      const text = 'This is a normal sentence with no issues.';
      expect(StringUtils.fixMissingWordBoundary(text), text);
    });

    test('leaves short acronym-like suffixes untouched', () {
      const text = 'The iPhone 3GS was released in 2009.';
      expect(StringUtils.fixMissingWordBoundary(text), text);
    });
  });
}
