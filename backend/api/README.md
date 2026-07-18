# SatuTani Backend API (NestJS)

Ini adalah backend utama untuk aplikasi SatuTani yang menangani pengguna, produk, dan pesanan.
Dibangun menggunakan **NestJS**, **Prisma ORM**, dan **PostgreSQL** (via Supabase).

## ⚙️ Persiapan (Setup) Lingkungan
Sebelum menjalankan aplikasi, pastikan Anda telah menduplikasi file `.env.example` menjadi `.env` dan mengisinya dengan kredensial yang tepat:

```bash
cp .env.example .env
```

Pastikan variabel berikut sudah terisi di `.env`:
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `DATABASE_URL` (Gunakan Connection Pooling untuk server utama)
- `DIRECT_URL` (Koneksi langsung untuk migrasi Prisma)
- `PORT=4000`

## 🚀 Menjalankan Aplikasi

```bash
# Install dependensi
npm install

# Generate Prisma Client
npx prisma generate

# Jalankan dalam mode development
npm run start:dev

# Jalankan dalam mode production
npm run build
npm run start:prod
```

## ☁️ Deployment
Aplikasi ini sudah diatur menggunakan GitHub Actions untuk di-deploy ke **Microsoft Azure App Service**. 
File workflow terletak di `../../.github/workflows/azure-api-deploy.yml`.
