abstract class CloudinaryUrl {
  /// Widths we ever request. Few enough that screens drawing images at
  /// similar sizes share one downloaded and decoded copy.
  static const _widths = [320, 640, 960, 1280, 1920];

  static const _upload = '/image/upload/';

  /// Returns [url] rewritten to ask Cloudinary for a copy no wider than
  /// [width] pixels, rounded up to one of a few fixed steps.
  ///
  /// The artwork is uploaded at print size (up to 4258x7543, several MB per
  /// file), while the app draws it at a few hundred points. Resizing on the
  /// CDN cuts each download ~20x and keeps decoded images small enough that
  /// the image cache holds a whole screen's worth. Non-Cloudinary URLs, and
  /// ones that already carry a transformation, are returned unchanged.
  static String sized(String url, int width) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host != 'res.cloudinary.com') return url;

    final index = url.indexOf(_upload);
    if (index == -1) return url;

    final rest = url.substring(index + _upload.length);
    // The first segment after /upload/ is either a version ("v1741484789")
    // or the asset path; a transformation looks like "w_800,c_limit".
    if (RegExp('^[a-z]{1,3}_[^/]*/').hasMatch(rest)) return url;

    final step = _widths.firstWhere(
      (w) => w >= width,
      orElse: () => _widths.last,
    );
    return '${url.substring(0, index + _upload.length)}'
        'w_$step,c_limit,f_auto,q_auto/$rest';
  }
}
