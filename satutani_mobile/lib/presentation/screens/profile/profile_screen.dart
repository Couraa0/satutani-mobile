import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  _buildMenuItem(Icons.password_rounded, 'Ubah Kata Sandi'),
                  
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
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
              backgroundColor: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 16),
          
          // Name and Email
          const Text('Andi Pratama', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 4),
          Text('andi.pratama@email.com', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          
          const SizedBox(height: 8),
          
          // Role and Location
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Petani', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text('·', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ),
              Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text('Bandung, Indonesia', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
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

  Widget _buildMenuItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
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
                    onPressed: () { Navigator.pop(context); Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false); },
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
