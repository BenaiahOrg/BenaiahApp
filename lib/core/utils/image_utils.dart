import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ImageUtils {
  static final Dio _dio = Dio();

  static Future<void> downloadAndSaveImage(String url) async {
    final hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      await Gal.requestAccess();
    }

    final tempDir = await getTemporaryDirectory();
    final path =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    await _dio.download(url, path);
    await Gal.putImage(path);

    final file = File(path);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  /// The downloaded file is left in the temp directory: the share target
  /// may still be reading it after `share` returns.
  static Future<void> shareImage(String url, String title) async {
    final tempDir = await getTemporaryDirectory();
    final path =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    await _dio.download(url, path);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path)],
        text: title,
      ),
    );
  }
}
