-- Username (nama panggilan pendek) untuk tampilan ringkas di UI,
-- mis. greeting di Beranda. Nama lengkap tetap di kolom name.
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS username TEXT NOT NULL DEFAULT '';
