import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/user_service.dart';
import '../../widgets/address_sheet.dart';

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
    if (mounted) {
      setState(() {
        _profile = data;
        _loading = false;
      });
    }
  }

  String get _name =>
      _profile?['name'] ?? AuthService.currentUser?.email ?? 'User';
  String get _email => AuthService.currentUser?.email ?? '';
  String get _role {
    final r = _profile?['role'] ?? 'consumer';
    if (r == 'farmer') return 'Petani';
    if (r == 'admin') return 'Admin';
    return 'Pembeli';
  }

  String get _avatarUrl =>
      (_profile?['avatar_url'] as String?)?.isNotEmpty == true
          ? _profile!['avatar_url']
          : (AuthService.currentUser?.userMetadata?['avatar_url'] ?? '');

  String get _address => (_profile?['address'] as String?) ?? '';

  int _stat(String key) => (_profile?[key] as num?)?.toInt() ?? 0;

  // ── Aksi menu ─────────────────────────────────────────────────────────────

  Future<void> _openSheet(Widget sheet) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: sheet,
      ),
    );
    if (changed == true) _loadProfile();
  }

  void _openAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'SatuTani',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('🌱', style: TextStyle(fontSize: 26))),
      ),
      children: const [
        Text(
          'SatuTani menghubungkan petani dan pembeli secara langsung — '
          'tanpa perantara, harga adil untuk semua.',
          style: TextStyle(fontSize: 13, height: 1.5),
        ),
      ],
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar?'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.signOut();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                  context, '/splash', (_) => false);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                minimumSize: const Size(100, 44)),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsRow()
                        .animate()
                        .fadeIn(duration: 350.ms)
                        .slideY(begin: 0.15, curve: Curves.easeOut),
                    const SizedBox(height: 24),
                    _sectionLabel('AKUN'),
                    _MenuTile(
                      icon: Icons.person_outline_rounded,
                      color: AppColors.primary,
                      title: 'Edit Profil',
                      subtitle: 'Nama, telepon, kota, foto profil',
                      onTap: () => _openSheet(_EditProfileSheet(
                          profile: _profile ?? {}, avatarUrl: _avatarUrl)),
                    ),
                    _MenuTile(
                      icon: Icons.location_on_outlined,
                      color: AppColors.secondary,
                      title: 'Alamat Pengiriman',
                      subtitle: _address.isEmpty
                          ? 'Belum diatur — dipakai saat checkout'
                          : _address,
                      onTap: () =>
                          _openSheet(AddressSheet(current: _address)),
                    ),
                    _MenuTile(
                      icon: Icons.lock_outline_rounded,
                      color: AppColors.info,
                      title: 'Ubah Kata Sandi',
                      subtitle: 'Perbarui kata sandi akun Anda',
                      onTap: () => _openSheet(const _ChangePasswordSheet()),
                    ),
                    const SizedBox(height: 20),
                    _sectionLabel('LAINNYA'),
                    _MenuTile(
                      icon: Icons.help_outline_rounded,
                      color: AppColors.preOrderPurple,
                      title: 'Pusat Bantuan',
                      subtitle: 'Pertanyaan yang sering diajukan',
                      onTap: () => _openSheet(const _HelpSheet()),
                    ),
                    _MenuTile(
                      icon: Icons.info_outline_rounded,
                      color: AppColors.textSecondary,
                      title: 'Tentang Aplikasi',
                      subtitle: 'SatuTani v1.0.0',
                      onTap: _openAbout,
                    ),
                    const SizedBox(height: 20),
                    _MenuTile(
                      icon: Icons.logout_rounded,
                      color: AppColors.danger,
                      title: 'Keluar',
                      titleColor: AppColors.danger,
                      showChevron: false,
                      onTap: _confirmLogout,
                    ),
                  ]
                      .animate(interval: 45.ms)
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.08, curve: Curves.easeOut),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Profil Saya',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 18),
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: _avatarUrl.isNotEmpty
                          ? CachedNetworkImageProvider(_avatarUrl)
                          : null,
                      child: _avatarUrl.isEmpty
                          ? Text(
                              _name.isNotEmpty ? _name[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary),
                            )
                          : null,
                    ),
                  ),
                ],
              ).animate().scale(
                  duration: 350.ms,
                  begin: const Offset(0.9, 0.9),
                  curve: Curves.easeOutBack),
              const SizedBox(height: 12),
              Text(_name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              const SizedBox(height: 3),
              Text(_email,
                  style:
                      const TextStyle(fontSize: 13, color: Colors.white70)),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_role,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      ('$_totalOrders', 'Pesanan', Icons.receipt_long_rounded),
      ('$_points', 'Poin', Icons.stars_rounded),
      ('$_reviews', 'Ulasan', Icons.rate_review_rounded),
    ];
    return Row(
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Icon(stats[i].$3, color: AppColors.primary, size: 20),
                  const SizedBox(height: 6),
                  Text(stats[i].$1,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(stats[i].$2,
                      style: const TextStyle(
                          fontSize: 11.5, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  int get _totalOrders => _stat('total_orders');
  int get _points => _stat('loyalty_points');
  int get _reviews => _stat('total_reviews');

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(text,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: AppColors.textSecondary)),
    );
  }
}

// ── Baris menu ────────────────────────────────────────────────────────────────

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final bool showChevron;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.showChevron = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 22, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: titleColor ?? AppColors.textPrimary)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                      ],
                    ],
                  ),
                ),
                if (showChevron)
                  const Icon(Icons.chevron_right_rounded,
                      size: 24, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sheet: Edit Profil ────────────────────────────────────────────────────────

class _EditProfileSheet extends StatefulWidget {
  final Map<String, dynamic> profile;
  final String avatarUrl;
  const _EditProfileSheet({required this.profile, required this.avatarUrl});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final _nameCtrl =
      TextEditingController(text: widget.profile['name'] ?? '');
  late final _usernameCtrl =
      TextEditingController(text: widget.profile['username'] ?? '');
  late final _phoneCtrl =
      TextEditingController(text: widget.profile['phone'] ?? '');
  late final _cityCtrl =
      TextEditingController(text: widget.profile['city'] ?? '');
  late final _provinceCtrl =
      TextEditingController(text: widget.profile['province'] ?? '');

  final _picker = ImagePicker();
  late String _avatarUrl = widget.avatarUrl;
  bool _uploadingAvatar = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _provinceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    if (_uploadingAvatar) return;
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 640,
      );
      if (picked == null) return;
      setState(() => _uploadingAvatar = true);
      final bytes = await picked.readAsBytes();
      final url = await StorageService.uploadAvatar(bytes, picked.name);
      if (!mounted) return;
      setState(() => _avatarUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Gagal upload foto: $e'),
            backgroundColor: AppColors.danger));
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Nama tidak boleh kosong'),
          backgroundColor: AppColors.danger));
      return;
    }
    setState(() => _saving = true);
    final ok = await UserService.updateProfile(
      name: name,
      username: _usernameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      province: _provinceCtrl.text.trim(),
      avatarUrl: _avatarUrl.isNotEmpty ? _avatarUrl : null,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Gagal menyimpan profil'),
          backgroundColor: AppColors.danger));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'Edit Profil',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickAvatar,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: _avatarUrl.isNotEmpty
                        ? CachedNetworkImageProvider(_avatarUrl)
                        : null,
                    child: _avatarUrl.isEmpty
                        ? const Icon(Icons.person_rounded,
                            size: 40, color: AppColors.primary)
                        : null,
                  ),
                  if (_uploadingAvatar)
                    const Positioned.fill(
                      child: CircleAvatar(
                        backgroundColor: Colors.black38,
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          size: 15, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text('Ketuk foto untuk mengganti',
                style: TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 18),
          _field('Nama Lengkap', _nameCtrl, Icons.person_outline_rounded),
          const SizedBox(height: 14),
          _field('Username', _usernameCtrl, Icons.alternate_email_rounded,
              hint: 'Nama panggilan singkat, mis. rafly'),
          const SizedBox(height: 14),
          _field('No. Telepon', _phoneCtrl, Icons.phone_outlined,
              keyboard: TextInputType.phone),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
                child: _field('Kota', _cityCtrl, Icons.location_city_rounded)),
            const SizedBox(width: 12),
            Expanded(
                child: _field('Provinsi', _provinceCtrl, Icons.map_outlined)),
          ]),
          const SizedBox(height: 24),
          _SheetButton(
              label: 'Simpan', loading: _saving, onPressed: _save),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon,
      {TextInputType? keyboard, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: keyboard,
          style: const TextStyle(fontSize: 15),
          decoration: _sheetInputDecor(hint: hint ?? label, icon: icon),
        ),
      ],
    );
  }
}

// ── Sheet: Pusat Bantuan ──────────────────────────────────────────────────────

class _HelpSheet extends StatelessWidget {
  const _HelpSheet();

  static const _faqs = [
    (
      'Bagaimana cara memesan produk?',
      'Buka menu Jelajahi atau Beranda, pilih produk, ketuk tombol Tambah, '
          'lalu buka Keranjang dan ketuk Checkout. Ikuti langkahnya sampai selesai.'
    ),
    (
      'Bagaimana cara melacak pesanan saya?',
      'Buka menu Pesanan di bagian bawah layar. Pesanan yang sudah '
          'dikonfirmasi petani memiliki tombol "Lacak" untuk melihat statusnya.'
    ),
    (
      'Metode pembayaran apa saja yang tersedia?',
      'Saat ini tersedia QRIS dan Transfer Bank yang dipilih saat checkout.'
    ),
    (
      'Bagaimana jika produk yang diterima rusak?',
      'Hubungi kami melalui tombol Chat di Beranda, sertakan foto produk. '
          'Tim kami akan membantu proses pengembalian atau penggantian.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'Pusat Bantuan',
      child: Column(
        children: [
          for (final f in _faqs)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 14),
                  childrenPadding:
                      const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  title: Text(f.$1,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(f.$2,
                          style: const TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: AppColors.textSecondary)),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/chat');
              },
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              label: const Text('Masih butuh bantuan? Chat kami'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sheet: Ubah Kata Sandi ────────────────────────────────────────────────────

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
        backgroundColor: error ? AppColors.danger : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'Ubah Kata Sandi',
      subtitle:
          'Buat kata sandi baru untuk akun Anda. Setelah disimpan, Anda bisa login dengan email + kata sandi.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kata Sandi Baru',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          TextField(
            controller: _newCtrl,
            obscureText: _obscureNew,
            decoration: _sheetInputDecor(
              hint: 'Minimal 6 karakter',
              icon: Icons.lock_outline_rounded,
              suffix: GestureDetector(
                onTap: () => setState(() => _obscureNew = !_obscureNew),
                child: Icon(
                  _obscureNew
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Konfirmasi Kata Sandi',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmCtrl,
            obscureText: _obscureConfirm,
            decoration: _sheetInputDecor(
              hint: 'Ulangi kata sandi',
              icon: Icons.lock_outline_rounded,
              suffix: GestureDetector(
                onTap: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                child: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _SheetButton(label: 'Simpan', loading: _loading, onPressed: _save),
        ],
      ),
    );
  }
}

// ── Kerangka & elemen bersama untuk semua sheet ───────────────────────────────

class _SheetShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  const _SheetShell({required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4)),
            ],
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onPressed;
  const _SheetButton(
      {required this.label, required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Text(label,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
      ),
    );
  }
}

InputDecoration _sheetInputDecor(
    {required String hint, required IconData icon, Widget? suffix}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
    prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
    suffixIcon: suffix,
    filled: true,
    fillColor: const Color(0xFFF7F8FA),
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
