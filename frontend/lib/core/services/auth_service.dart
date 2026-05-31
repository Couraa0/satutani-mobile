import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_config.dart';
import 'supabase_service.dart';

const _kPendingRole = 'pending_oauth_role';

class AuthService {
  // ── Google OAuth ──────────────────────────────────────────────────────────

  /// Simpan role yang dipilih sebelum redirect OAuth, lalu buka Google login.
  /// Dipanggil dari halaman register (ada role) maupun login (role dikosongkan).
  static Future<void> signInWithGoogle({String? intendedRole}) async {
    if (SupabaseConfig.url.isEmpty) {
      throw Exception(
        'Supabase belum dikonfigurasi.\n'
        'Jalankan: flutter run -d chrome --dart-define-from-file=.env.json --web-port=3000',
      );
    }
    if (intendedRole != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPendingRole, intendedRole);
    }
    // Redirect ke origin saat ini — otomatis handle localhost vs production
    final redirectTo = kIsWeb ? Uri.base.origin : null;
    await auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectTo,
    );
  }

  // ── Session & user ────────────────────────────────────────────────────────

  static bool get isLoggedIn => auth.currentSession != null;
  static User? get currentUser => auth.currentUser;

  /// JWT access token untuk dikirim ke backend (AuthGuard memverifikasi via
  /// supabase.auth.getUser(token)). JANGAN pakai currentUser.id sebagai token.
  static String? get accessToken => auth.currentSession?.accessToken;

  /// Ambil role user dari tabel profiles.
  /// Jika ada pending role dari OAuth register, update dulu lalu hapus.
  static Future<String> resolveRole() async {
    if (SupabaseConfig.url.isEmpty) return 'consumer';

    try {
      final user = currentUser;
      if (user == null) return 'consumer';

      // Cek apakah ada pending role dari OAuth register
      final prefs = await SharedPreferences.getInstance();
      final pendingRole = prefs.getString(_kPendingRole);
      debugPrint('[AuthService] pendingRole from storage: $pendingRole');
      if (pendingRole != null) {
        try {
          final res = await db
              .from('profiles')
              .update({'role': pendingRole})
              .eq('id', user.id)
              .select();
          debugPrint('[AuthService] Role update result: $res');
        } catch (e) {
          debugPrint('[AuthService] Failed to update role: $e');
        }
        await prefs.remove(_kPendingRole);
        return pendingRole;
      }

      // Baca role dari database
      final data = await db
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();
      return (data['role'] as String?) ?? 'consumer';
    } catch (e) {
      debugPrint('[AuthService] resolveRole error: $e');
      return 'consumer';
    }
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  static Future<void> signOut() async {
    await auth.signOut();
  }
}
