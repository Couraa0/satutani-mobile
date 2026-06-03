-- ─────────────────────────────────────────────────────────────
-- STORAGE: bucket untuk foto produk
-- ─────────────────────────────────────────────────────────────

-- Bucket publik (agar public URL gambar bisa ditampilkan tanpa token).
INSERT INTO storage.buckets (id, name, public)
VALUES ('product-images', 'product-images', TRUE)
ON CONFLICT (id) DO NOTHING;

-- Policy idempotent: hapus dulu kalau sudah ada.
DROP POLICY IF EXISTS "product_images_public_read"   ON storage.objects;
DROP POLICY IF EXISTS "product_images_auth_insert"   ON storage.objects;
DROP POLICY IF EXISTS "product_images_auth_update"   ON storage.objects;
DROP POLICY IF EXISTS "product_images_auth_delete"   ON storage.objects;

-- Siapa pun boleh membaca objek di bucket ini (gambar publik).
CREATE POLICY "product_images_public_read"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'product-images');

-- User terautentikasi boleh upload.
CREATE POLICY "product_images_auth_insert"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'product-images');

-- User terautentikasi boleh update objek di bucket ini.
CREATE POLICY "product_images_auth_update"
  ON storage.objects FOR UPDATE TO authenticated
  USING (bucket_id = 'product-images');

-- User terautentikasi boleh menghapus objek di bucket ini.
CREATE POLICY "product_images_auth_delete"
  ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'product-images');
