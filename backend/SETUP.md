# SatuTani — Panduan Setup Backend & Deploy

Dokumen ini berisi langkah-langkah konfigurasi dari nol hingga live.
Update bagian **Status** setiap kali satu langkah selesai.

---

## Status Checklist

- [x] Supabase project dibuat (`SatuTani_Mobile`, region: ap-northeast-2 Seoul)
- [x] Migration SQL dijalankan (Success. No rows returned)
- [x] Google OAuth dikonfigurasi (Google Cloud Console — Client ID & Secret dibuat)
- [x] Google provider diaktifkan di Supabase (Sign In / Providers → Google → Enable)
- [x] URL Configuration diset di Supabase (Site URL + Redirect URLs)
- [ ] Env vars ditambahkan ke Vercel (`SUPABASE_URL`, `SUPABASE_ANON_KEY`)
- [ ] Redeploy berhasil & OAuth berjalan

---

## 1. Jalankan Migration SQL

**Tempat:** Supabase Dashboard → SQL Editor → New query

1. Buka file: `backend/supabase/migrations/20260528000000_initial_schema.sql`
2. Copy semua isinya
3. Paste di SQL Editor → klik **Run**
4. Pastikan tidak ada error merah di output

> Tabel yang akan terbuat: `profiles`, `farmer_profiles`, `categories`,
> `products`, `orders`, `order_tracking_steps`, `reviews`,
> `traceability_steps`, `market_events`

---

## 2. Konfigurasi Google OAuth

### 2a. Google Cloud Console

URL: https://console.cloud.google.com

1. **APIs & Services → OAuth consent screen**
   - User Type: **External** → Create
   - App name: `SatuTani`
   - User support email: emailmu
   - Developer contact: emailmu
   - Save and Continue (lewati semua langkah opsional)

2. **APIs & Services → Credentials → + Create Credentials → OAuth 2.0 Client ID**
   - Application type: **Web application**
   - Name: `SatuTani Web`
   - Authorized redirect URIs → Add URI:
     ```
     [SUPABASE_URL dari .env]/auth/v1/callback
     ```
     Contoh: `https://jitlmgzlwicqpbvvudmv.supabase.co/auth/v1/callback`
     *(gunakan URL yang ada di `.env` kamu sebagai patokan)*
   - Klik **Create**
   - **Simpan Client ID dan Client Secret** yang muncul di popup

### 2b. Supabase Dashboard

URL: https://supabase.com/dashboard → pilih project SatuTani_Mobile

1. **Authentication → Providers → Google**
   - Toggle **Enable** → ON
   - Client ID: *(paste dari Google Cloud)*
   - Client Secret: *(paste dari Google Cloud)*
   - Klik **Save**

2. **Authentication → URL Configuration**
   - Site URL:
     ```
     https://satutani-mobile.vercel.app
     ```
   - Redirect URLs → Add:
     ```
     https://satutani-mobile.vercel.app/**
     ```
   - Klik **Save**

---

## 3. Konfigurasi Env Vars di Vercel

URL: https://vercel.com/dashboard → Project SatuTani → Settings → Environment Variables

Tambahkan dua variabel berikut (pilih environment: **Production, Preview, Development**):

| Name | Value |
|---|---|
| `SUPABASE_URL` | lihat `.env` → nilai `SUPABASE_URL` |
| `SUPABASE_ANON_KEY` | `sb_publishable_GTvM_M3eKti0dM...` *(publishable key dari Supabase → Settings → API Keys)* |

Setelah save → **Deployments → titik tiga → Redeploy**

---

## 4. Verifikasi

Setelah redeploy selesai, buka https://satutani-mobile.vercel.app dan:
- [ ] App terbuka tanpa error
- [ ] Tombol Google di login screen bisa diklik dan redirect ke Google
- [ ] Setelah login Google → masuk ke home screen

---

## Referensi Credential Proyek

> **Jangan tulis credential asli di sini.** Simpan di `.env` (sudah di-gitignore).

| Item | Lokasi |
|---|---|
| Supabase URL | `.env` → `SUPABASE_URL` |
| Supabase Anon Key | `.env` → `SUPABASE_ANON_KEY` |
| Google Client ID | Supabase Dashboard → Auth → Google |
| Google Client Secret | Supabase Dashboard → Auth → Google |

---

## Struktur Backend

```
backend/
├── supabase/
│   ├── config.toml                           ← Supabase CLI config
│   ├── migrations/
│   │   └── 20260528000000_initial_schema.sql ← Jalankan sekali di SQL Editor
│   └── seed.sql                              ← Data awal (opsional)
├── .env                                      ← GITIGNORED — credential lokal
├── .env.example                              ← Template (aman di-commit)
└── SETUP.md                                  ← File ini
```
