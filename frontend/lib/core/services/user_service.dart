import 'package:flutter/foundation.dart';
import 'supabase_service.dart';
import 'auth_service.dart';

class UserService {
  /// Ambil profil user yang sedang login dari database
  static Future<Map<String, dynamic>?> getMyProfile() async {
    try {
      final user = AuthService.currentUser;
      if (user == null) return null;

      final data = await db
          .from('profiles')
          .select('*, farmer_profiles(*)')
          .eq('id', user.id)
          .single();

      return data;
    } catch (e) {
      debugPrint('[UserService] getMyProfile error: $e');
      return null;
    }
  }

  /// Update profil user
  static Future<bool> updateProfile({
    String? name,
    String? phone,
    String? city,
    String? province,
  }) async {
    try {
      final user = AuthService.currentUser;
      if (user == null) return false;

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (city != null) updates['city'] = city;
      if (province != null) updates['province'] = province;

      await db.from('profiles').update(updates).eq('id', user.id);
      return true;
    } catch (e) {
      debugPrint('[UserService] updateProfile error: $e');
      return false;
    }
  }
}
