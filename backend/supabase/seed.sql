-- ============================================================
-- SatuTani — Seed Data (development only)
-- Jalankan setelah migration: supabase db reset
-- ============================================================

-- Market events
INSERT INTO market_events (emoji, title, description, impact, event_date) VALUES
  ('🌙', 'Ramadan (Apr 2026)', 'Permintaan sayuran naik signifikan selama bulan puasa', '+45% demand sayuran', '2026-04-01'),
  ('🎊', 'Lebaran (Mei 2026)', 'Lonjakan kebutuhan beras dan bahan masakan rumahan', '+60% demand beras & rempah', '2026-05-01'),
  ('🌧️', 'Musim Hujan (Mar-Mei)', 'Produksi cabai turun karena curah hujan tinggi', '+30% harga cabai', '2026-03-01');
