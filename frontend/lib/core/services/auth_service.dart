import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

const _kPendingRole = 'pending_oauth_role';

class AuthService {
  // ── Google OAuth ──────────────────────────────────────────────────────────

  /// Simpan role yang dipilih sebelum redirect OAuth, lalu buka Google login.
  /// Dipanggil dari halaman register (ada role) maupun login (role dikosongkan).
  static Future<void> signInWithGoogle({String? intendedRole}) async {
    if (intendedRole != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPendingRole, intendedRole);
    }
    await auth.signInWithOAuth(OAuthProvider.google);
  }

  // ── Session & user ────────────────────────────────────────────────────────

  static bool get isLoggedIn => auth.currentSession != null;
  static User? get currentUser => auth.currentUser;

  /// Ambil role user dari tabel profiles.
  /// Jika ada pending role dari OAuth register, update dulu lalu hapus.
  static Future<String> resolveRole() async {
    final user = currentUser;
    if (user == null) return 'consumer';

    // Cek apakah ada pending role dari alur register → Google OAuth
    final prefs = await SharedPreferences.getInstance();
    final pendingRole = prefs.getString(_kPendingRole);
    if (pendingRole != null) {
      await db
          .from('profiles')
          .update({'role': pendingRole})
          .eq('id', user.id);
      await prefs.remove(_kPendingRole);
      return pendingRole;
    }

    // Baca role dari database
    try {
      final data = await db
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();
      return (data['role'] as String?) ?? 'consumer';
    } catch (_) {
      return 'consumer';
    }
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  static Future<void> signOut() async {
    await auth.signOut();
  }
}
