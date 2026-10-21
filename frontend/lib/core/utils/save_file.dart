// `saveTextFile(filename, content, mimeType: ...)`:
// - Web: memicu unduhan browser, mengembalikan null.
// - Mobile/desktop: menulis ke folder dokumen aplikasi, mengembalikan path file.
export 'save_file_io.dart' if (dart.library.js_interop) 'save_file_web.dart';
