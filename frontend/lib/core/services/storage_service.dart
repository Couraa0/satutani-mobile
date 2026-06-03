import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Upload file ke Supabase Storage.
class StorageService {
  static const String _bucket = 'product-images';

  /// Upload foto produk, kembalikan public URL-nya.
  /// [fileName] dipakai untuk menebak ekstensi/mime (mis. "foto.jpg").
  static Future<String> uploadProductImage(
      Uint8List bytes, String fileName) async {
    final ext = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : 'jpg';
    final contentType = ext == 'png'
        ? 'image/png'
        : ext == 'webp'
            ? 'image/webp'
            : 'image/jpeg';

    final userId = auth.currentUser?.id ?? 'anon';
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await db.storage.from(_bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: true),
        );

    return db.storage.from(_bucket).getPublicUrl(path);
  }
}
