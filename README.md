# 🌾 SatuTani (Mobile App)

**SatuTani** adalah platform e-commerce dan manajemen pertanian (*Direct Farm to Consumer*) yang menghubungkan langsung petani dengan pembeli (B2C & B2B) tanpa perantara kotor. Aplikasi ini bertujuan membantu petani mendapatkan harga wajar serta memastikan konsumen menerima produk segar, harga terjangkau, dan berkualitas.

---

## ✨ Fitur Utama
Aplikasi ini memiliki 2 peran (*role*) utama: **Petani** dan **Pembeli / Konsumen**.

### 👨‍🌾 Untuk Petani
- **Dashboard & Analitik:** Pantau pendapatan harian, pesanan aktif, dan laporan stok.
- **Manajemen Produk:** Tambah produk dengan mudah (termasuk fitur *Pre-Order* sebelum panen).
- **Manajemen Pesanan:** Konfirmasi, tolak, dan pantau status pesanan hingga selesai.
- **Hubungi Kurir & Logistik:** Pesan logistik pihak ketiga secara real-time dan lacak (termasuk *Cold Chain Delivery*).
- **Aksi Cepat AI:** Dapatkan prediksi harga pasar menggunakan AI, dan ajukan KUR (Kredit Usaha Rakyat).

### 🛒 Untuk Pembeli (Individu & B2B)
- **Katalog Produk Segar:** Telusuri produk sayuran, buah, beras, rempah, dsb langsung dari lahan.
- **Traceability (Lacak Produk):** Pindai QR Code untuk melihat perjalanan produk (Dari lahan -> kurir -> konsumen).
- **Paket Langganan:** Beli bahan makanan secara reguler mingguan/bulanan.
- **Keranjang & Checkout Mudah:** Mendukung berbagai metode pembayaran dan pengiriman.

---

## 🛠️ Tech Stack & Library
Aplikasi ini dibangun menggunakan **Flutter** dengan arsitektur yang modern:
- **Framework:** Flutter (versi SDK `^3.3.0`+)
- **State Management:** Riverpod (`flutter_riverpod`)
- **Navigation:** Go Router (`go_router`)
- **Networking:** Dio (`dio`)
- **UI & Styling:** Google Fonts (Inter), Shimmer, Cached Network Image, SVGs.
- **Device Support:** Android, iOS, & Web (Device Preview mode untuk web simulation).

---

## 🚀 Cara Menjalankan Project (Getting Started)

### 1. Prasyarat (Requirements)
Pastikan Anda sudah menginstall:
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Android Studio / VS Code
- Git

### 2. Instalasi & Menjalankan
1. *Clone* repository ini:
   ```bash
   git clone https://github.com/MuhammadRafly23100/SatuTani.git
   ```
2. Masuk ke direktori mobile app:
   ```bash
   cd SatuTani/satutani_mobile
   ```
3. Unduh semua dependencies:
   ```bash
   flutter pub get
   ```
4. Jalankan aplikasi (Pilih target device: Android/iOS emulator atau Chrome):
   ```bash
   flutter run
   ```

*(Khusus untuk Desktop/Web Localhost, tampilan dipaksa berbentuk bingkai ponsel otomatis berkat fitur Device Preview).*

---

## 📸 Tampilan Aplikasi (Preview)
*(Tambahkan URL screenshot / GIF aplikasi di sini nantinya)*

---

### Dikembangkan Oleh
**Muhammad Rafly** & Tim Pengembang SatuTani 2026.
