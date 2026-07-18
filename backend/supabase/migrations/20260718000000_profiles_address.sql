-- Alamat pengiriman di profil.
-- Dipakai: menu "Alamat Pengiriman" di halaman Profil, dan ditampilkan di
-- kartu alamat pada layar Checkout (menggantikan teks placeholder).
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS address TEXT NOT NULL DEFAULT '';
