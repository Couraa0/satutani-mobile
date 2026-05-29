-- ============================================================
-- SatuTani — Initial Schema
-- ============================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─────────────────────────────────────────────────────────────
-- ENUM types
-- ─────────────────────────────────────────────────────────────
CREATE TYPE user_role       AS ENUM ('farmer', 'consumer');
CREATE TYPE order_status    AS ENUM ('pending', 'confirmed', 'harvesting', 'shipped', 'completed', 'cancelled');
CREATE TYPE delivery_method AS ENUM ('regular', 'cold_chain');
CREATE TYPE demand_level    AS ENUM ('Tinggi', 'Sedang', 'Rendah');

-- ─────────────────────────────────────────────────────────────
-- PROFILES (extends auth.users)
-- ─────────────────────────────────────────────────────────────
CREATE TABLE profiles (
  id              UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  role            user_role NOT NULL DEFAULT 'consumer',
  name            TEXT NOT NULL DEFAULT '',
  phone           TEXT,
  avatar_url      TEXT,
  city            TEXT DEFAULT 'Jakarta',
  province        TEXT DEFAULT 'DKI Jakarta',
  loyalty_points  INTEGER DEFAULT 0,
  total_orders    INTEGER DEFAULT 0,
  total_reviews   INTEGER DEFAULT 0,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Auto-create profile on new user signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.profiles (id, name, avatar_url)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
    COALESCE(NEW.raw_user_meta_data->>'avatar_url', '')
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION touch_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION touch_updated_at();

-- ─────────────────────────────────────────────────────────────
-- FARMER PROFILES (1:1 dengan profiles untuk role farmer)
-- ─────────────────────────────────────────────────────────────
CREATE TABLE farmer_profiles (
  id           UUID REFERENCES profiles(id) ON DELETE CASCADE PRIMARY KEY,
  location     TEXT NOT NULL DEFAULT '',
  province     TEXT NOT NULL DEFAULT '',
  specialty    TEXT,
  is_verified  BOOLEAN DEFAULT FALSE,
  rating       DECIMAL(3,2) DEFAULT 0.00,
  review_count INTEGER DEFAULT 0,
  distance_km  DECIMAL(6,2) DEFAULT 0.00,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE TRIGGER farmer_profiles_updated_at
  BEFORE UPDATE ON farmer_profiles
  FOR EACH ROW EXECUTE FUNCTION touch_updated_at();

-- ─────────────────────────────────────────────────────────────
-- CATEGORIES
-- ─────────────────────────────────────────────────────────────
CREATE TABLE categories (
  id         TEXT PRIMARY KEY,
  name       TEXT NOT NULL,
  icon_emoji TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO categories (id, name, icon_emoji) VALUES
  ('vegetable', 'Sayuran',  '🥬'),
  ('fruit',     'Buah',     '🍎'),
  ('grain',     'Biji-bijian', '🌾'),
  ('spice',     'Rempah',   '🌶️'),
  ('dairy',     'Susu & Telur', '🥚'),
  ('other',     'Lainnya',  '🛒');

-- ─────────────────────────────────────────────────────────────
-- PRODUCTS
-- ─────────────────────────────────────────────────────────────
CREATE TABLE products (
  id                    UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  farmer_id             UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  name                  TEXT NOT NULL,
  description           TEXT DEFAULT '',
  price                 DECIMAL(14,2) NOT NULL,
  unit                  TEXT DEFAULT 'kg',
  rating                DECIMAL(3,2) DEFAULT 0.00,
  review_count          INTEGER DEFAULT 0,
  stock                 DECIMAL(10,2) DEFAULT 0,
  category              TEXT REFERENCES categories(id),
  image_urls            TEXT[] DEFAULT '{}',
  is_available          BOOLEAN DEFAULT TRUE,
  is_ai_price           BOOLEAN DEFAULT FALSE,
  is_pre_order          BOOLEAN DEFAULT FALSE,
  estimated_harvest_date DATE,
  pre_order_target      DECIMAL(10,2),
  pre_order_filled      DECIMAL(10,2) DEFAULT 0,
  created_at            TIMESTAMPTZ DEFAULT NOW(),
  updated_at            TIMESTAMPTZ DEFAULT NOW()
);

CREATE TRIGGER products_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION touch_updated_at();

-- ─────────────────────────────────────────────────────────────
-- ORDERS
-- ─────────────────────────────────────────────────────────────
CREATE SEQUENCE order_seq START 1;

CREATE TABLE orders (
  id                  TEXT PRIMARY KEY DEFAULT 'ORD-' || LPAD(NEXTVAL('order_seq')::TEXT, 6, '0'),
  consumer_id         UUID REFERENCES profiles(id) ON DELETE SET NULL,
  product_id          UUID REFERENCES products(id) ON DELETE SET NULL,
  product_name        TEXT NOT NULL,
  product_image_url   TEXT DEFAULT '',
  farmer_name         TEXT DEFAULT '',
  farmer_id           UUID REFERENCES profiles(id) ON DELETE SET NULL,
  quantity            DECIMAL(10,2) NOT NULL,
  unit                TEXT DEFAULT 'kg',
  price_per_unit      DECIMAL(14,2) NOT NULL,
  shipping_cost       DECIMAL(14,2) DEFAULT 0,
  status              order_status DEFAULT 'pending',
  delivery_method     delivery_method DEFAULT 'regular',
  estimated_delivery  TIMESTAMPTZ,
  created_at          TIMESTAMPTZ DEFAULT NOW(),
  updated_at          TIMESTAMPTZ DEFAULT NOW()
);

CREATE TRIGGER orders_updated_at
  BEFORE UPDATE ON orders
  FOR EACH ROW EXECUTE FUNCTION touch_updated_at();

-- ─────────────────────────────────────────────────────────────
-- ORDER TRACKING STEPS
-- ─────────────────────────────────────────────────────────────
CREATE TABLE order_tracking_steps (
  id           UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id     TEXT REFERENCES orders(id) ON DELETE CASCADE NOT NULL,
  step_order   INTEGER NOT NULL,
  title        TEXT NOT NULL,
  is_completed BOOLEAN DEFAULT FALSE,
  is_active    BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMPTZ,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────────────────────────
-- REVIEWS
-- ─────────────────────────────────────────────────────────────
CREATE TABLE reviews (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  product_id  UUID REFERENCES products(id) ON DELETE CASCADE NOT NULL,
  consumer_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  order_id    TEXT REFERENCES orders(id) ON DELETE SET NULL,
  rating      SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment     TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Auto-update product rating & review_count setelah review
CREATE OR REPLACE FUNCTION update_product_rating()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  UPDATE products SET
    rating       = (SELECT AVG(rating)::DECIMAL(3,2) FROM reviews WHERE product_id = NEW.product_id),
    review_count = (SELECT COUNT(*) FROM reviews WHERE product_id = NEW.product_id)
  WHERE id = NEW.product_id;
  RETURN NEW;
END;
$$;

CREATE TRIGGER after_review_insert
  AFTER INSERT ON reviews
  FOR EACH ROW EXECUTE FUNCTION update_product_rating();

-- ─────────────────────────────────────────────────────────────
-- TRACEABILITY (jejak produk dari lahan ke konsumen)
-- ─────────────────────────────────────────────────────────────
CREATE TABLE traceability_steps (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  product_id  UUID REFERENCES products(id) ON DELETE CASCADE NOT NULL,
  step_order  INTEGER NOT NULL,
  label       TEXT NOT NULL,
  description TEXT,
  location    TEXT,
  timestamp   TIMESTAMPTZ DEFAULT NOW(),
  actor_name  TEXT,
  actor_role  TEXT
);

-- ─────────────────────────────────────────────────────────────
-- MARKET EVENTS (untuk Market Forecast screen)
-- ─────────────────────────────────────────────────────────────
CREATE TABLE market_events (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  emoji       TEXT,
  title       TEXT NOT NULL,
  description TEXT,
  impact      TEXT,
  event_date  DATE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────────────────────────
-- ROW LEVEL SECURITY
-- ─────────────────────────────────────────────────────────────
ALTER TABLE profiles               ENABLE ROW LEVEL SECURITY;
ALTER TABLE farmer_profiles        ENABLE ROW LEVEL SECURITY;
ALTER TABLE products               ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_tracking_steps   ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews                ENABLE ROW LEVEL SECURITY;
ALTER TABLE traceability_steps     ENABLE ROW LEVEL SECURITY;
ALTER TABLE market_events          ENABLE ROW LEVEL SECURITY;

-- profiles: bisa lihat semua, hanya edit milik sendiri
CREATE POLICY "profiles_select_all"  ON profiles FOR SELECT USING (TRUE);
CREATE POLICY "profiles_update_own"  ON profiles FOR UPDATE USING (auth.uid() = id);

-- farmer_profiles: publik bisa baca, farmer hanya bisa edit miliknya
CREATE POLICY "farmer_profiles_select_all" ON farmer_profiles FOR SELECT USING (TRUE);
CREATE POLICY "farmer_profiles_insert_own" ON farmer_profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "farmer_profiles_update_own" ON farmer_profiles FOR UPDATE USING (auth.uid() = id);

-- products: publik bisa baca, farmer hanya bisa CRUD produknya sendiri
CREATE POLICY "products_select_all"    ON products FOR SELECT USING (TRUE);
CREATE POLICY "products_insert_own"    ON products FOR INSERT WITH CHECK (auth.uid() = farmer_id);
CREATE POLICY "products_update_own"    ON products FOR UPDATE USING (auth.uid() = farmer_id);
CREATE POLICY "products_delete_own"    ON products FOR DELETE USING (auth.uid() = farmer_id);

-- orders: consumer lihat pesanannya, farmer lihat pesanan produknya
CREATE POLICY "orders_consumer_select" ON orders FOR SELECT USING (auth.uid() = consumer_id);
CREATE POLICY "orders_farmer_select"   ON orders FOR SELECT USING (auth.uid() = farmer_id);
CREATE POLICY "orders_consumer_insert" ON orders FOR INSERT WITH CHECK (auth.uid() = consumer_id);
CREATE POLICY "orders_farmer_update"   ON orders FOR UPDATE USING (auth.uid() = farmer_id);

-- tracking steps: ikuti akses order
CREATE POLICY "tracking_select" ON order_tracking_steps FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM orders o
    WHERE o.id = order_id
      AND (o.consumer_id = auth.uid() OR o.farmer_id = auth.uid())
  ));

-- reviews: publik bisa baca, authenticated bisa tulis
CREATE POLICY "reviews_select_all"  ON reviews FOR SELECT USING (TRUE);
CREATE POLICY "reviews_insert_auth" ON reviews FOR INSERT WITH CHECK (auth.uid() = consumer_id);

-- traceability: publik bisa baca
CREATE POLICY "traceability_select_all" ON traceability_steps FOR SELECT USING (TRUE);

-- market_events: publik bisa baca
CREATE POLICY "market_events_select_all" ON market_events FOR SELECT USING (TRUE);

-- categories: publik bisa baca
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "categories_select_all" ON categories FOR SELECT USING (TRUE);

-- ─────────────────────────────────────────────────────────────
-- INDEX untuk performa query umum
-- ─────────────────────────────────────────────────────────────
CREATE INDEX idx_products_farmer_id   ON products(farmer_id);
CREATE INDEX idx_products_category    ON products(category);
CREATE INDEX idx_products_is_available ON products(is_available);
CREATE INDEX idx_orders_consumer_id   ON orders(consumer_id);
CREATE INDEX idx_orders_farmer_id     ON orders(farmer_id);
CREATE INDEX idx_orders_status        ON orders(status);
CREATE INDEX idx_reviews_product_id   ON reviews(product_id);
CREATE INDEX idx_traceability_product ON traceability_steps(product_id);
