import 'dart:io';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ImageUtils {
  static final Dio _dio = Dio();

  static Future<void> downloadAndSaveImage(String url) async {
    try {
      // Request permission
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }

      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      await _dio.download(url, path);
      await Gal.putImage(path);
      
      // Clean up
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> shareImage(String url, String title) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      await _dio.download(url, path);
      await Share.shareXFiles([XFile(path)], text: title);
      
      // We don't delete immediately because share might need the file
      // In a real app we might want to clean up later
    } catch (e) {
      rethrow;
    }
  }
}
