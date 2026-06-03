# SatuTani Real-Time Product System - Implementation Guide

## 📋 Overview

Sistem ini mengintegrasikan produk dari petani (farmer) ke platform konsumen dengan real-time sync. Ketika petani menambahkan, mengubah, atau menghapus produk, perubahan tersebut langsung terlihat di aplikasi konsumen.

## 🏗️ Architecture

### Tech Stack

- **Frontend**: Flutter
- **Backend**: NestJS
- **Database**: PostgreSQL (via Supabase)
- **ORM**: Prisma
- **API Protocol**: REST

### Component Breakdown

#### 1. Backend (NestJS)

**File**: `backend/api/src/products/`

**Struktur**:

- `products.controller.ts` - Handle HTTP requests
- `products.service.ts` - Business logic
- `products.module.ts` - Module configuration

**Endpoints**:

```
GET    /api/products                 - Get all products (public)
GET    /api/products/:id             - Get product by ID (public)
GET    /api/products/farmer/me       - Get farmer's products (auth required)
POST   /api/products                 - Create product (auth required)
PATCH  /api/products/:id             - Update product (auth required)
DELETE /api/products/:id             - Delete product (auth required)
```

#### 2. Frontend (Flutter)

**Service Layer**: `frontend/lib/core/services/product_service.dart`

- Menangani semua API calls ke backend
- Menyediakan methods untuk CRUD operations
- Error handling dan response parsing

**Screens**:

1. **ExploreScreen** (`frontend/lib/presentation/screens/explore/explore_screen.dart`)
   - Display produk real-time dari API
   - Search dan filter functionality
   - Consumer dapat melihat produk dari semua petani

2. **FarmerProductsScreen** (`frontend/lib/presentation/screens/farmer/products/farmer_products_screen.dart`)
   - Display produk milik petani yang login
   - Filter: Semua, Aktif, Habis, Pre-Order
   - Menu untuk: Edit, Duplikat, Hapus

3. **AddProductScreen** (`frontend/lib/presentation/screens/farmer/products/add_product_screen.dart`)
   - Form untuk tambah produk baru
   - Terintegrasi dengan ProductService untuk POST

4. **EditProductScreen** (baru di farmer_products_screen.dart)
   - Form untuk edit produk existing
   - Terintegrasi dengan ProductService untuk PATCH

## 🚀 Getting Started

### Prerequisites

1. Node.js & npm (untuk NestJS backend)
2. Flutter SDK (untuk frontend)
3. Supabase project yang sudah siap
4. PostgreSQL database

### Backend Setup

1. **Install dependencies**:

```bash
cd backend/api
npm install
```

2. **Setup database dengan Prisma**:

```bash
# Generate Prisma client
npx prisma generate

# Run migrations
npx prisma migrate dev

# (Optional) Seed data
npx prisma db seed
```

3. **Setup environment variables** (`.env` file):

```env
DATABASE_URL="postgresql://user:password@localhost:5432/satutani"
JWT_SECRET="your-secret-key"
PORT=3001
```

4. **Start backend server**:

```bash
npm run start:dev
```

Server akan berjalan di `http://localhost:3001`

### Frontend Setup

1. **Update ProductService base URL** jika berbeda:

```dart
// frontend/lib/core/services/product_service.dart
static const String baseUrl = 'http://localhost:3001/api';
```

2. **Install dependencies**:

```bash
cd frontend
flutter pub get
```

3. **Run Flutter app**:

```bash
flutter run
```

## 📱 Features

### Untuk Konsumen (Consumer)

#### Explore Screen

- **Real-time Product Discovery**: Lihat semua produk dari petani
- **Search**: Cari produk berdasarkan nama
- **Filter**: Filter berdasarkan kategori (ke depan bisa ditambah)
- **View Details**: Tap produk untuk detail lebih lanjut
- **Add to Cart**: Tap tombol + untuk tambah ke keranjang (bisa dikembangkan)

### Untuk Petani (Farmer)

#### Farmer Products Screen

1. **View My Products**: Lihat semua produk yang sudah ditambahkan
2. **Filter Products**:
   - Semua: Tampil semua produk
   - Aktif: Hanya produk yang tersedia
   - Habis: Produk dengan stok 0
   - Pre-Order: Produk dengan pre-order enabled

3. **Toggle Product Status**: Gunakan switch untuk aktivasi/deaktivasi produk

4. **Product Actions** (Menu tiga titik):
   - **Edit**: Ubah detail produk (nama, harga, deskripsi, stok, satuan)
   - **Duplicate**: Clone produk dengan nama berubah jadi "(Copy)"
   - **Delete**: Hapus produk (dengan confirmation dialog)

#### Add Product Screen

- Fill form dengan detail produk
- Upload gambar (up to 5 photos)
- Set kategori, harga, satuan, stok
- Enable pre-order dengan harvest date
- **Save**: Produk langsung muncul di explore screen

## 📊 Data Flow

```
┌─────────────┐
│   Petani    │
│  (Farmer)   │
└──────┬──────┘
       │
       ├─ Tambah Produk
       ├─ Edit Produk
       └─ Hapus Produk
       │
    ┌──v──┐
    │POST │ → NestJS Backend
    │PATCH│
    │DEL  │
    └─────┘
       │
       ├─ Validasi
       ├─ Save ke DB
       └─ Return Response
       │
    ┌──v──────────────┐
    │ PostgreSQL DB   │
    │ (Products Table)│
    └─────────────────┘
       │
       │
┌──────────────┐
│  Konsumen    │
│  (Consumer)  │
└──────┬───────┘
       │
    ┌──v──┐
    │GET  │ ← NestJS Backend
    └─────┘
       │
       ├─ Query dari DB
       └─ Return JSON
       │
    ┌──v───────────┐
    │ Flutter App  │
    │ ExploreScreen│
    └──────────────┘
       │
       └─ Display Products Real-time
```

## 🔐 Authentication & Authorization

- **Auth Guard**: Routes POST, PATCH, DELETE memerlukan `AuthGuard`
- **User Identification**: `req.user.id` dari JWT token
- **Authorization Check**:
  - Petani hanya bisa edit/delete produk miliknya
  - Konsumen bisa baca semua produk

## 🔄 Real-time Sync

**Current Implementation**: Fetch on demand

- ExploreScreen fetch saat screen muncul
- FarmerProductsScreen fetch saat screen muncul
- Refresh dengan pull-to-refresh atau navigation

**Future Enhancements** (Optional):

- WebSocket untuk live updates
- Firebase Realtime Database
- GraphQL subscriptions

## 🛠️ Database Schema

### Products Table

```sql
CREATE TABLE products (
  id                    UUID PRIMARY KEY,
  farmer_id             UUID (FK to profiles),
  name                  TEXT NOT NULL,
  description           TEXT,
  price                 DECIMAL(14,2),
  unit                  TEXT,
  stock                 DECIMAL(10,2),
  category              TEXT (FK to categories),
  image_urls            TEXT[] (array of URLs),
  is_available          BOOLEAN,
  is_ai_price           BOOLEAN,
  is_pre_order          BOOLEAN,
  estimated_harvest_date DATE,
  pre_order_target      DECIMAL(10,2),
  pre_order_filled      DECIMAL(10,2),
  created_at            TIMESTAMPTZ,
  updated_at            TIMESTAMPTZ
);
```

## 📝 API Response Format

### Success Response

```json
{
  "id": "uuid",
  "name": "Bayam Segar",
  "price": 5000,
  "stock": 80,
  "farmer": {
    "id": "farmer-uuid",
    "name": "Budi Santoso",
    "avatarUrl": "url"
  }
}
```

### Error Response

```json
{
  "statusCode": 400,
  "message": "Validation failed",
  "error": "Bad Request"
}
```

## 🐛 Troubleshooting

### Issue: Products tidak muncul di Explore Screen

**Solution**:

1. Check backend running di `http://localhost:3001`
2. Verify database connection
3. Check ProductService base URL

### Issue: Add/Edit produk error 401

**Solution**:

1. Check authentication token valid
2. Verify AuthGuard implemented
3. Check JWT secret matches

### Issue: Image not loading

**Solution**:

1. Verify image URLs valid
2. Check CORS settings di backend
3. Update placeholder image URL

## 📦 Dependencies

### Backend

- `@nestjs/common`, `@nestjs/core`
- `@prisma/client`
- `class-validator`, `class-transformer`
- `passport`, `@nestjs/jwt`

### Frontend

- `http` package untuk API calls
- `flutter/material` untuk UI

## 🎯 Next Steps

1. **Image Upload**: Implementasikan upload image ke cloud storage (Firebase, Cloudinary, S3)
2. **Product Categories**: Sync kategori dari database
3. **Reviews & Ratings**: Tambah review system untuk products
4. **Real-time Updates**: Implementasikan WebSocket/GraphQL
5. **Search Advanced**: Full-text search, filter by price range, rating
6. **Inventory Management**: Track sold quantity, restock alerts

## 📞 Support

Untuk questions atau issues, check:

- NestJS Documentation: https://docs.nestjs.com
- Prisma Documentation: https://www.prisma.io/docs
- Flutter Documentation: https://flutter.dev/docs
