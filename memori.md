# 🧠 Memori Project SatuTani Mobile

> File ini menyimpan ringkasan & catatan yang akan **terus di-update** seiring berjalannya project.
> Setiap kali ada perubahan struktur, keputusan teknis, atau task selesai — update bagian terkait di sini.

**Last updated:** 2026-05-30 (auth flow lengkap — register/login email+password, Google OAuth, set/ubah password)
**Live frontend:** https://satutani-mobile.vercel.app/
**Repo:** https://github.com/Couraa0/satutani-mobile
**Supabase project:** `SatuTani_Mobile` (organization: Muhammad Rafly, plan: Free)

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
├── .vscode/        ← Editor settings lokal
├── frontend/       ← Flutter app (Android/iOS/Web)
├── backend/        ← Supabase setup (config, migrations, seed)
├── memori.md       ← File ini
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
| Local Storage | `shared_preferences` | `^2.2.3` | ✅ Dipakai untuk `pending_oauth_role` saat OAuth signup |
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
│   ├── constants/                  ← colors, strings, api_endpoints, supabase_config
│   ├── services/                   ← supabase_service, auth_service, user_service
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
│   ├── config.toml                                       ← Supabase CLI config (auth, Google OAuth, ports)
│   ├── migrations/
│   │   ├── 20260528000000_initial_schema.sql             ← Skema lengkap + RLS
│   │   └── 20260529000000_fix_handle_new_user_role.sql   ← Fix trigger baca role dari signup metadata
│   └── seed.sql                                          ← Data awal (market events)
└── .env.example                                          ← Template env vars
```

**⚠️ Apply via SQL Editor**, bukan Supabase CLI. Folder `migrations/` adalah dokumentasi/reference. Edit schema = jalankan SQL manual di Dashboard + commit file migration baru biar history konsisten.

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
2. Jalankan migration: Dashboard → SQL Editor → paste isi **setiap file** di `migrations/` **berurutan**
3. Salin URL & anon key dari Project Settings → API
4. Tambahkan ke Vercel env vars: `SUPABASE_URL`, `SUPABASE_ANON_KEY`
5. Untuk dev lokal: buat `frontend/.env.json` dengan key yang sama, jalankan `flutter run -d chrome --dart-define-from-file=.env.json --web-port=3000`
6. Supabase Dashboard → Authentication → URL Configuration → tambah `http://localhost:3000` di **Site URL** & **Redirect URLs** supaya link konfirmasi email dari dev bisa kembali ke localhost
7. *(Opsional dev)* Authentication → Providers → Email → matikan "Confirm email" supaya testing tidak perlu konfirmasi via inbox

---

## 🔐 Auth Flow (Status)

| Flow | Status | Catatan |
|---|---|---|
| Register email + password | ✅ | Role dikirim via `signUp(data: {'role': ..., 'full_name': ...})`. Trigger `handle_new_user` baca dari metadata. |
| Login email + password | ✅ | `signInWithPassword` lalu `AuthService.resolveRole()` query DB → routing per role |
| Google OAuth signup | ✅ | `signInWithOAuth` + `pending_oauth_role` di SharedPreferences (set saat pilih role sebelum redirect) |
| Set/Ubah password (untuk user OAuth) | ✅ | Bottom sheet di Profile → `auth.updateUser(UserAttributes(password: ...))`. User OAuth bisa lanjut login pakai email+password setelahnya. |
| Email confirmation | ✅ | Aktif default Supabase. Testing manual: `UPDATE auth.users SET email_confirmed_at = NOW() WHERE email = '...';` |
| Logout | ✅ | Dialog konfirmasi → `auth.signOut()` → redirect ke `/splash` |
| Forgot password | ⏳ | Route ada (`/forgot-password`) tapi belum implementasi |
| Edit profile | ⏳ | Tombol ada tapi onPressed kosong; service `UserService.updateProfile()` siap pakai |

### File auth Flutter
- [auth_service.dart](frontend/lib/core/services/auth_service.dart) — `signInWithGoogle`, `resolveRole`, `signOut`, `currentUser`, `isLoggedIn`
- [user_service.dart](frontend/lib/core/services/user_service.dart) — `getMyProfile`, `updateProfile`
- [supabase_service.dart](frontend/lib/core/services/supabase_service.dart) — `auth` & `db` shortcut
- [register_screen.dart](frontend/lib/presentation/screens/auth/register_screen.dart) — manual + Google
- [login_screen.dart](frontend/lib/presentation/screens/auth/login_screen.dart) — manual + Google + debug print
- [profile_screen.dart](frontend/lib/presentation/screens/profile/profile_screen.dart) — load profile real, set/ubah password sheet
- [splash_screen.dart](frontend/lib/presentation/screens/splash/splash_screen.dart) — auto-route berdasarkan session + role

---

## ⚠️ Pitfall Penting (jangan lupa)

### 1. SECURITY DEFINER function di Supabase
Function trigger di `auth.users` (mis. [handle_new_user](backend/supabase/migrations/20260529000000_fix_handle_new_user_role.sql)) **wajib**:
1. `SET search_path = public, pg_temp` di header function
2. Schema-qualified types: `public.user_role` (BUKAN `user_role` saja)
3. Owner `postgres` → `ALTER FUNCTION ... OWNER TO postgres`
4. `GRANT EXECUTE ON FUNCTION ... TO supabase_auth_admin`
5. INSERT policy fallback: `CREATE POLICY ... FOR INSERT WITH CHECK (true)`

**Kenapa:** Saat dipanggil dari SQL Editor (role `postgres`), search_path mencakup `public` → semua reference type ketemu. Saat dipanggil dari Auth service (role `supabase_auth_admin`), search_path berbeda → reference `user_role` tanpa schema gagal → error `type "user_role" does not exist` → Supabase return generic **"Database error saving new user" (500)**. Bug sulit dideteksi karena manual SQL test berhasil padahal real signup gagal.

### 2. NULL cast ke enum tidak throw exception
`NULL::user_role` = NULL (BUKAN error). Kalau key tidak ada di JSON, `->>` return NULL, lalu cast ke NULL → insert NULL ke kolom `NOT NULL` → constraint violation → trigger fail. **Selalu** check `IS NOT NULL AND <> ''` sebelum cast.

### 3. Test environment: localhost vs Vercel
Flutter dev di `localhost:3000` cuma bisa diakses **browser laptop yang sama**. HP tidak bisa akses localhost. Kalau register di laptop lalu klik link konfirmasi email di HP, HP akan buka **Site URL Supabase** — kalau di-set ke Vercel, HP buka kode lama yang belum di-deploy. Selalu klarifikasi env saat debug.

### 4. Debugging Auth Logs
Saat dapat 500 dari `/auth/v1/signup`:
1. Supabase Dashboard → **Logs & Analytics** → **Postgres** → top bar **Severity** → pilih **Error**
2. Cari log dengan `user_name: supabase_auth_admin` — itu kasih error PostgreSQL persis dari trigger
3. Bedakan dari **Auth Logs** (separate tab) yang kasih error dari Auth service side

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

### Sudah selesai
- [x] Buat project di Supabase dashboard & jalankan migration SQL.
- [x] Set env vars `SUPABASE_URL` & `SUPABASE_ANON_KEY` di Vercel dashboard.
- [x] Implementasi auth nyata (login/register email+pw + Google OAuth + set/ubah password).
- [x] Profile screen baca data real dari Supabase (`UserService.getMyProfile`).
- [x] Farmer home greeting & tanggal dinamis (dari `profiles.name` & `DateTime.now`).
- [x] Auth state persistence (Supabase Flutter handle otomatis).

### Belum
- [ ] Update [README.md:51](README.md#L51) — ganti `cd satutani_mobile` jadi `cd frontend`.
- [ ] Deploy ulang ke Vercel supaya HP test juga pakai kode terbaru.
- [ ] Ganti data mock di Beranda/Pesanan/Profile dengan query Supabase (products, orders).
- [ ] Hubungkan tombol **Edit Profile** ke `UserService.updateProfile`.
- [ ] Implementasi flow **Forgot Password** (route `/forgot-password` sudah ada).
- [ ] Hapus 2 baris `debugPrint('[LoginScreen] ...')` di [login_screen.dart:49,55](frontend/lib/presentation/screens/auth/login_screen.dart#L49) sebelum push ke prod.
- [ ] Pakai `go_router` atau hapus dari pubspec (deadweight).
- [ ] Avatar di pojok kanan atas Farmer Home ([farmer_home_screen.dart:44-45](frontend/lib/presentation/screens/farmer/home/farmer_home_screen.dart#L44-L45)) masih placeholder — hubungkan ke `avatar_url` user.

---

## 📝 Log Update Memori

| Tanggal | Perubahan |
|---|---|
| 2026-05-28 | Initial memori — struktur project, stack, screens, deploy config. |
| 2026-05-28 | Backend setup: Supabase dipilih, schema PostgreSQL + RLS dibuat, Flutter integration (supabase_flutter), vercel-build.sh diupdate. |
| 2026-05-30 | Auth flow lengkap: register manual (role via metadata), login email+pw, Google OAuth (sudah ada), set/ubah password lewat Profile (bottom sheet). Fix trigger `handle_new_user` (migration 20260529): tambah `SET search_path` + schema-qualified `public.user_role` + null guard + grant ke `supabase_auth_admin`. Profile screen baca data real, farmer home greeting dinamis. Section "Auth Flow" & "Pitfall Penting" baru. |
