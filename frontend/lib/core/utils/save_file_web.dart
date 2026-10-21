import 'dart:js_interop';
import 'package:web/web.dart' as web;

Future<String?> saveTextFile(String filename, String content, {String mimeType = 'text/plain'}) async {
  final blob = web.Blob(<JSAny>[content.toJS].toJS, web.BlobPropertyBag(type: mimeType));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename;
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
  // Revoke ditunda: beberapa browser membatalkan unduhan bila URL langsung dicabut.
  Future.delayed(const Duration(seconds: 2), () => web.URL.revokeObjectURL(url));
  return null;
}
