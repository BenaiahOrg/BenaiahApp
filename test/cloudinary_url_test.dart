import 'package:benaiah_app/core/utils/cloudinary_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const original =
      'https://res.cloudinary.com/doh7zyphl/image/upload/v1741484789/13_p1ckg7.png';

  group('CloudinaryUrl.sized', () {
    test('asks the CDN for a copy no wider than drawn', () {
      expect(
        CloudinaryUrl.sized(original, 600),
        'https://res.cloudinary.com/doh7zyphl/image/upload/'
        'w_640,c_limit,f_auto,q_auto/v1741484789/13_p1ckg7.png',
      );
    });

    test('rounds up to a shared step so screens reuse one copy', () {
      expect(
        CloudinaryUrl.sized(original, 641),
        CloudinaryUrl.sized(original, 900),
      );
      expect(CloudinaryUrl.sized(original, 5000), contains('/w_1920,'));
    });

    test('leaves other hosts and transformed URLs alone', () {
      const other = 'https://www.benaiah.org/_app/immutable/assets/a.png';
      const transformed =
          'https://res.cloudinary.com/doh7zyphl/image/upload/w_300/v1/a.png';

      expect(CloudinaryUrl.sized(other, 600), other);
      expect(CloudinaryUrl.sized(transformed, 600), transformed);
      expect(CloudinaryUrl.sized('', 600), '');
    });
  });
}
