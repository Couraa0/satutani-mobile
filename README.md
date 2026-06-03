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

Proyek ini terdiri dari 3 bagian utama yang harus dijalankan secara bersamaan di terminal yang berbeda.

### Prasyarat (Requirements)
- **Node.js** & **npm** (untuk NestJS Backend)
- **Python 3.9+** (untuk AI Server)
- **Flutter SDK** (untuk Frontend Mobile/Web)

---

### 🖥️ Terminal 1 — Backend (NestJS API)
Menjalankan API utama (otomatis berjalan di port 4000).

```bash
cd backend/api
npm install
npm run start:dev
```
*(Catatan: pastikan file `.env` di dalam `backend/api` sudah mengarah ke `AI_SERVICE_URL=http://localhost:8001`)*

---

### 🖥️ Terminal 2 — AI Chatbot Server (FastAPI/Python)
Menjalankan layanan AI di port 8001 (untuk menghindari bentrok dengan port 8000).

```bash
cd backend/ai
# Aktifkan virtual environment (Windows)
.\.venv\Scripts\Activate.ps1
# Jalankan server
$env:PORT=8001; python main.py
```
*(Atau menggunakan uvicorn: `uvicorn main:app --host 0.0.0.0 --port 8001 --reload`)*

---

### 🖥️ Terminal 3 — Frontend (Flutter)
Menjalankan aplikasi mobile. **Wajib menyertakan `.env.json`** agar koneksi ke Supabase dan Backend berhasil.

```bash
cd frontend
flutter pub get

# Menjalankan di Chrome (Web) dengan port 3000
flutter run -d chrome --dart-define-from-file=.env --web-port=3000

# Menjalankan di Emulator/Android
flutter run --dart-define-from-file=.env
```

---

## 🚀 Deployment

Proyek ini telah dikonfigurasi dengan GitHub Actions untuk CI/CD:
- **Frontend (Flutter Web)** di-deploy ke Vercel secara otomatis.
- **Backend (NestJS API)** di-deploy ke Azure App Service secara otomatis (`azure-api-deploy.yml`).
- **AI Server (FastAPI)** di-deploy ke Azure App Service secara otomatis (`azure-ai-deploy.yml`).

---

## 📸 Tampilan Aplikasi (Preview)
*(Tambahkan URL screenshot / GIF aplikasi di sini nantinya)*

---

### Dikembangkan Oleh
**M Rakha Syamputra & Muhammad Rafly** & Tim Pengembang SatuTani 2026.
