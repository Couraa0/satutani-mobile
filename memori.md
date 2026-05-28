# 🧠 Memori Project SatuTani Mobile

> File ini menyimpan ringkasan & catatan yang akan **terus di-update** seiring berjalannya project.
> Setiap kali ada perubahan struktur, keputusan teknis, atau task selesai — update bagian terkait di sini.

**Last updated:** 2026-05-28 (backend setup)
**Live frontend:** https://satutani-mobile.vercel.app/
**Repo:** https://github.com/Couraa0/satutani-mobile

---

## 📋 Aturan Kerja (Penting)

- 🚫 **JANGAN sentuh** folder [`.github/`](.github/) beserta isinya (workflows).
- 📁 Folder `frontend/` adalah **hasil rename** dari `satutani_mobile/`. Path lama tidak valid lagi.
- ⚠️ [`README.md`](README.md) masih menyebut `cd satutani_mobile` di langkah instalasi — perlu diupdate kalau sempat.

---

## 🗂️ Struktur Repo Top-Level

```
satutani-mobile/
├── .github/        ← OFF-LIMITS
├── frontend/       ← Flutter app (Android/iOS/Web)
├── backend/        ← Kosong (belum ada implementasi)
└── README.md
```

---

## 📱 Frontend (Flutter)

### Stack & Library Utama
| Kategori | Library | Versi | Status |
|---|---|---|---|
| Framework | Flutter SDK | `^3.3.0` | ✅ |
| State Management | `flutter_riverpod` | `^2.5.1` | ✅ Terpasang |
| Routing | Named routes (Navigator) | — | ✅ Aktif |
| Routing (alt) | `go_router` | `^13.2.0` | ⚠️ Terpasang tapi belum dipakai |
| **Backend** | `supabase_flutter` | `^2.8.4` | ✅ Terpasang & init |
| HTTP | `dio` | `^5.4.1` | ⚠️ Belum dipakai (data masih mock) |
| Local Storage | `shared_preferences` | `^2.2.3` | ⚠️ Belum dipakai |
| UI Fonts | `google_fonts` (Plus Jakarta Sans) | `^6.1.0` | ✅ |
| Chart | `fl_chart` | `^0.69.0` | ✅ |
| Image | `cached_network_image` | `^3.3.1` | ✅ |
| WebView | `webview_flutter` | `^4.13.1` | ✅ |
| Device Preview | `device_preview` | `^1.3.1` | ✅ **Selalu enabled** |

### Arsitektur `lib/`
```
lib/
├── main.dart                       ← Entry point, named routes
├── core/
│   ├── constants/                  ← colors, strings, api_endpoints
│   ├── theme/app_theme.dart        ← MaterialApp theme (Plus Jakarta Sans, primary #2D7D46)
│   └── utils/                      ← currency_formatter, date_formatter
├── data/
│   ├── models/                     ← product, order, farmer, user (semua punya mock inline)
│   └── mock/                       ← analytics, farmers, market, orders, products, traceability
└── presentation/
    ├── consumer_navigation.dart    ← Bottom nav konsumen (5 tab)
    ├── farmer_navigation.dart      ← Bottom nav petani (5 tab)
    ├── widgets/                    ← Reusable: bottom_nav_bar, kpi_card, loading_shimmer, section_header, status_badge
    └── screens/
        ├── splash/
        ├── onboarding/
        ├── auth/                   ← role_select, login, register, forgot/new password, otp + otp_success
        ├── home/                   ← + widgets/ (banner, category_grid, farmer_card, product_card)
        ├── explore/
        ├── cart/
        ├── checkout/
        ├── orders/                 ← orders + order_tracking
        ├── product_detail/
        ├── chat/
        ├── profile/
        └── farmer/
            ├── home/               ← farmer_home, ai_price_check, market_forecast
            ├── products/           ← list + add_product
            ├── orders/             ← list + contact_courier
            └── revenue/
```

### Routing Konsumen vs Petani
- **Konsumen** ([consumer_navigation.dart](frontend/lib/presentation/consumer_navigation.dart)): Beranda · Jelajahi · Keranjang · Pesanan · Profil
- **Petani** ([farmer_navigation.dart](frontend/lib/presentation/farmer_navigation.dart)): Beranda · Produk · Pesanan · Pendapatan · Profil

### Konfigurasi Penting
- API base URL: `https://satutani.vercel.app/api` ([api_endpoints.dart:2](frontend/lib/core/constants/api_endpoints.dart#L2)) — ⚠️ beda dengan host frontend, backend belum live.
- Primary color: `#2D7D46` (hijau).
- Orientasi: Portrait only ([main.dart:25](frontend/lib/main.dart#L25)).
- DevicePreview: **selalu on**, termasuk di production web.

### Deploy (Vercel)
- Script: [vercel-build.sh](frontend/vercel-build.sh) → clone Flutter stable shallow → `flutter build web --release`.
- Output: `frontend/build/web/`.
- Config: [vercel.json](frontend/vercel.json) → SPA rewrite semua route ke `/index.html`.

---

## 🖥️ Backend — Supabase

**Platform:** Supabase (PostgreSQL + Auth + Storage + Edge Functions)
**Alasan dipilih:** Free tier all-feature (cuma beda slot project vs paid), mudah dikonfigurasi, Flutter SDK resmi, cocok dengan Vercel.

### Struktur `backend/`
```
backend/
├── supabase/
│   ├── config.toml                          ← Supabase CLI config (auth, Google OAuth, ports)
│   ├── migrations/
│   │   └── 20260528000000_initial_schema.sql ← Skema lengkap + RLS
│   └── seed.sql                             ← Data awal (market events)
└── .env.example                             ← Template env vars
```

### Tabel database
| Tabel | Keterangan |
|---|---|
| `profiles` | Extends `auth.users`, role: farmer/consumer |
| `farmer_profiles` | Data tambahan khusus petani (lokasi, spesialisasi, rating) |
| `categories` | Kategori produk (vegetable, fruit, grain, spice, dairy, other) |
| `products` | Produk petani (termasuk pre-order & AI price flag) |
| `orders` | Pesanan konsumen, auto-ID `ORD-000001` |
| `order_tracking_steps` | Langkah tracking per pesanan |
| `reviews` | Review produk — auto-update rating produk via trigger |
| `traceability_steps` | Jejak produk dari lahan ke konsumen (QR) |
| `market_events` | Data event pasar untuk Market Forecast screen |

### Row Level Security
- **profiles**: publik read, edit hanya milik sendiri
- **products**: publik read, CRUD hanya oleh farmer pemilik
- **orders**: consumer lihat pesanannya, farmer lihat pesanan produknya
- **reviews/traceability/market_events**: publik read

### Flutter Integration
- Package: `supabase_flutter ^2.8.4` (di `pubspec.yaml`)
- Config: `lib/core/constants/supabase_config.dart` — baca dari `--dart-define`
- Client accessor: `lib/core/services/supabase_service.dart` — `db` & `auth` getter
- Init: `main.dart` — `Supabase.initialize()` sebelum `runApp()`
- Build Vercel: `vercel-build.sh` — `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`

### Setup Supabase (langkah untuk developer baru)
1. Buat project di https://supabase.com/dashboard
2. Jalankan migration: Dashboard → SQL Editor → paste isi `migrations/20260528000000_initial_schema.sql`
3. Salin URL & anon key dari Project Settings → API
4. Tambahkan ke Vercel env vars: `SUPABASE_URL`, `SUPABASE_ANON_KEY`
5. *(Opsional)* Untuk lokal: install Supabase CLI → `supabase start`

---

## 📜 Riwayat Commit Penting

| Hash | Pesan | Catatan |
|---|---|---|
| `39486e5` | Update repository URL and directory path in README | — |
| `a296e38` | Delete KUR, Add Ai Price and Market Forecast UI | Fitur KUR dihapus, ganti AI Price Check + Market Forecast di farmer home |
| `b1e86d2` | fix: use official vercel env variables | — |
| `4cef28c` | fix: deploy from within build/web directory | — |
| `c090fa1` | fix: explicit project ids for vercel deploy | — |

---

## ✅ TODO / Catatan ke Depan

- [ ] Update [README.md:51](README.md#L51) — ganti `cd satutani_mobile` jadi `cd frontend`.
- [ ] Buat project di Supabase dashboard & jalankan migration SQL.
- [ ] Set env vars `SUPABASE_URL` & `SUPABASE_ANON_KEY` di Vercel dashboard.
- [ ] Ganti data mock dengan query Supabase di setiap screen (mulai dari products & orders).
- [ ] Implementasi auth nyata (login/register → Supabase Auth).
- [ ] Pakai `go_router` atau hapus dari pubspec (saat ini cuma deadweight).
- [ ] Auth state persistence (Supabase Flutter sudah handle session otomatis via `shared_preferences`).

---

## 📝 Log Update Memori

| Tanggal | Perubahan |
|---|---|
| 2026-05-28 | Initial memori — struktur project, stack, screens, deploy config. |
| 2026-05-28 | Backend setup: Supabase dipilih, schema PostgreSQL + RLS dibuat, Flutter integration (supabase_flutter), vercel-build.sh diupdate. |
