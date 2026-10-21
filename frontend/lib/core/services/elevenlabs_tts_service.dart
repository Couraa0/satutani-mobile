import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';

/// Service for high-quality Text-to-Speech via ElevenLabs API.
///
/// Uses the backend as a proxy to avoid exposing the API key in the client.
/// Falls back to device TTS (flutter_tts) if the ElevenLabs call fails.
class ElevenLabsTtsService {
  /// Request TTS audio from ElevenLabs via our backend proxy.
  ///
  /// Returns raw MP3 audio bytes on success, or null on failure.
  /// The caller should play the audio using just_audio or audioplayers.
  static Future<Uint8List?> synthesize(String text) async {
    if (text.trim().isEmpty) return null;

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/ai/tts');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: '{"text": ${_jsonEscape(text)}}',
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 &&
          response.headers['content-type']?.contains('audio') == true) {
        return response.bodyBytes;
      }

      // If the backend returned JSON (e.g. error), treat as failure
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Simple JSON string escaper for the text payload.
  static String _jsonEscape(String s) {
    return '"${s.replaceAll('\\', '\\\\').replaceAll('"', '\\"').replaceAll('\n', '\\n').replaceAll('\r', '\\r')}"';
  }
}
