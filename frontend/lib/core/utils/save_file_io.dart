import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String?> saveTextFile(String filename, String content, {String mimeType = 'text/plain'}) async {
  // ponytail: disimpan di folder dokumen aplikasi; di Android folder ini privat.
  // Tambah share_plus ("Bagikan ke…") bila rilis mobile butuh akses file langsung.
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}${Platform.pathSeparator}$filename');
  await file.writeAsString(content);
  return file.path;
}
