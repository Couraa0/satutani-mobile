import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await UserService.getMyProfile();
    if (mounted) setState(() { _profile = data; _loading = false; });
  }

  String get _name => _profile?['name'] ?? AuthService.currentUser?.email ?? 'User';
  String get _email => AuthService.currentUser?.email ?? '';
  String get _role {
    final r = _profile?['role'] ?? 'consumer';
    if (r == 'farmer') return 'Petani';
    if (r == 'admin') return 'Admin';
    return 'Pembeli';
  }
  String get _location {
    final city = _profile?['city'] ?? '';
    final province = _profile?['province'] ?? '';
    if (city.isEmpty && province.isEmpty) return 'Indonesia';
    if (city.isEmpty) return province;
    return '$city, $province';
  }
  String get _avatarUrl => AuthService.currentUser?.userMetadata?['avatar_url'] ?? '';

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: Stack(
        children: [
          // Background Radial Blob Gradient — Full Screen (Canva fluid style)
          Positioned.fill(
            child: Stack(
              children: [
                // Dasar warna
                Container(color: const Color(0xFFE8F5E9)),
                // Blob 1 — Kanan atas: Hijau solid kuat
                Positioned(
                  top: -100,
                  right: -100,
                  child: _blob(360, const Color(0xFF2D7D46), 0.75),
                ),
                // Blob 2 — Kiri tengah: Hijau tua lebih kecil
                Positioned(
                  top: 200,
                  left: -120,
                  child: _blob(300, const Color(0xFF1B5E20), 0.5),
                ),
                // Blob 3 — Kanan bawah: Hijau medium
                Positioned(
                  bottom: -80,
                  right: -60,
                  child: _blob(280, const Color(0xFF4CAF50), 0.45),
                ),
                // Blob 4 — Tengah bawah kiri: Hijau muda
                Positioned(
                  bottom: 100,
                  left: 40,
                  child: _blob(200, const Color(0xFF81C784), 0.35),
                ),
                // Blob 5 — Atas tengah: Sedikit overlap untuk naturalness
                Positioned(
                  top: 80,
                  left: 80,
                  child: _blob(180, const Color(0xFFA5D6A7), 0.4),
                ),
              ],
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12), // Sedikit padding pengganti agar Profile tidak terlalu mepet dengan atas layar
                  const Text('Profile', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 20),

                  // Profile Card
                  _buildProfileCard(context),
                  const SizedBox(height: 32),

                  // Menu Items (Group 1)
                  _buildMenuItem(Icons.language_rounded, 'Bahasa'),
                  _buildMenuItem(Icons.currency_exchange_rounded, 'Mata Uang'),
                  _buildMenuItem(Icons.palette_outlined, 'Tampilan'),
                  
                  const SizedBox(height: 16),

                  // Menu Items (Group 2)
                  _buildMenuItem(Icons.security_rounded, 'Keamanan Aplikasi'),
                  _buildMenuItem(Icons.devices_rounded, 'Kelola Perangkat'),
                  _buildMenuItem(Icons.password_rounded, 'Ubah Kata Sandi',
                      onTap: () => _showChangePasswordSheet(context)),
                  
                  const SizedBox(height: 16),
                  
                  // Logout Button
                  _buildLogoutMenuItem(context),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper: Membuat "blob" lingkaran dengan RadialGradient, menyebar ke transparan
  Widget _blob(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
            child: _avatarUrl.isEmpty
                ? Text(
                    _name.isNotEmpty ? _name[0].toUpperCase() : 'U',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                  )
                : null,
          ),
          const SizedBox(height: 16),

          // Name and Email
          Text(_name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(_email, style: TextStyle(fontSize: 13, color: Colors.grey[600])),

          const SizedBox(height: 8),

          // Role and Location
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_role, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text('·', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ),
              Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(_location, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Edit Profile Button (Warna khusus Color(0xFFF5A623))
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
            label: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF5A623),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: const _ChangePasswordSheet(),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap ?? () {},
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Icon(icon, size: 22, color: Colors.black87),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
                ),
                const Icon(Icons.chevron_right_rounded, size: 22, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutMenuItem(BuildContext context) {
    return Container(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Text('Keluar?'),
                content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await AuthService.signOut();
                      if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/splash', (_) => false);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                    child: const Text('Keluar'),
                  ),
                ],
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.logout_rounded, color: AppColors.danger, size: 22),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text('Keluar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.danger)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final pass = _newCtrl.text;
    final confirm = _confirmCtrl.text;

    if (pass.isEmpty || confirm.isEmpty) {
      _toast('Kata sandi wajib diisi', error: true);
      return;
    }
    if (pass.length < 6) {
      _toast('Kata sandi minimal 6 karakter', error: true);
      return;
    }
    if (pass != confirm) {
      _toast('Konfirmasi kata sandi tidak cocok', error: true);
      return;
    }

    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: pass),
      );
      if (!mounted) return;
      Navigator.pop(context);
      _toast('Kata sandi berhasil disimpan');
    } on AuthException catch (e) {
      _toast(e.message, error: true);
    } catch (e) {
      _toast('Gagal menyimpan kata sandi', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Ubah Kata Sandi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(
            'Buat kata sandi baru untuk akun Anda. Setelah disimpan, Anda bisa login dengan email + kata sandi.',
            style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
          ),
          const SizedBox(height: 20),

          const Text('Kata Sandi Baru',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          TextField(
            controller: _newCtrl,
            obscureText: _obscureNew,
            decoration: _decor(
              hint: 'Minimal 6 karakter',
              icon: Icons.lock_outline_rounded,
              obscured: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
            ),
          ),
          const SizedBox(height: 16),

          const Text('Konfirmasi Kata Sandi',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmCtrl,
            obscureText: _obscureConfirm,
            decoration: _decor(
              hint: 'Ulangi kata sandi',
              icon: Icons.lock_outline_rounded,
              obscured: _obscureConfirm,
              onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _loading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Simpan',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decor({
    required String hint,
    required IconData icon,
    required bool obscured,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
      suffixIcon: GestureDetector(
        onTap: onToggle,
        child: Icon(
          obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.textSecondary, size: 20,
        ),
      ),
      filled: true,
      fillColor: const Color(0xFFF7F8FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
