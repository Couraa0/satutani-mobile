# 🚀 SatuTani Setup Checklist

Checklist ini memastikan semua komponen berjalan dengan baik untuk sistem real-time product.

## ✅ Database Setup

### Step 1: Initialize Database

- [ ] Supabase project sudah dibuat
- [ ] PostgreSQL database sudah connected
- [ ] Database URL tersedia di `.env`

### Step 2: Run Migrations

```bash
cd backend/api
npx prisma migrate deploy  # Atau migrate dev jika development
```

- [ ] Migration untuk Products table sudah berjalan
- [ ] Tables: `products`, `profiles`, `categories` sudah ada
- [ ] Foreign keys dan indexes sudah dibuat

### Step 3: Verify Database

```bash
npx prisma studio  # Buka Prisma Studio untuk inspect
```

- [ ] Bisa connect ke database
- [ ] Schema sesuai dengan design

---

## ✅ Backend Setup (NestJS)

### Step 1: Install Dependencies

```bash
cd backend/api
npm install
```

- [ ] All npm packages installed
- [ ] node_modules folder created
- [ ] No dependency conflicts

### Step 2: Environment Configuration

Create `.env` file di `backend/api/`:

```env
DATABASE_URL="postgresql://user:password@localhost:5432/satutani"
JWT_SECRET="your-secret-key-min-32-chars"
PORT=3001
```

- [ ] `.env` file created
- [ ] All required variables set
- [ ] DATABASE_URL pointing ke correct database

### Step 3: Build Backend

```bash
npm run build
```

- [ ] Compilation berhasil tanpa errors
- [ ] dist/ folder created

### Step 4: Start Backend Server

```bash
npm run start:dev  # Development dengan hot-reload
# atau
npm run start:prod  # Production
```

- [ ] Server running di port 3001
- [ ] Logs showing "NestJS server started"
- [ ] No connection errors

### Step 5: Test Backend Endpoints

```bash
# Test public endpoint (tanpa auth)
curl http://localhost:3001/api/products

# Response harus 200 dengan empty array atau list products
```

- [ ] GET /api/products returns 200
- [ ] Response format valid JSON
- [ ] CORS setup jika needed

---

## ✅ Frontend Setup (Flutter)

### Step 1: Install Flutter Dependencies

```bash
cd frontend
flutter pub get
```

- [ ] All packages installed
- [ ] pubspec.lock created
- [ ] No dependency conflicts

### Step 2: Update API Configuration

**File**: `frontend/lib/core/services/product_service.dart`

Verify atau update base URL:

```dart
static const String baseUrl = 'http://localhost:3001/api';
```

- [ ] Base URL correct sesuai backend address
- [ ] Port number sesuai (default 3001)

### Step 3: Verify Models

**File**: `frontend/lib/data/models/product_model.dart`

Check that ProductModel.fromJson() support semua field:

- [ ] Handle camelCase (JavaScript naming)
- [ ] Handle snake_case (Database naming)
- [ ] Handle nested objects (farmer)
- [ ] Type conversions (price, stock, rating)

### Step 4: Compile Flutter App

```bash
flutter pub get
flutter run
```

- [ ] App compile berhasil
- [ ] Emulator atau device running
- [ ] No build errors

### Step 5: Test Flutter Screens

**Explore Screen** (Konsumen):

- [ ] Products loading dari API
- [ ] Search functionality working
- [ ] Filter working (jika implemented)
- [ ] Loading state showing

**Farmer Products Screen**:

- [ ] Login sebagai farmer first
- [ ] My products loading dari API
- [ ] Filter chips working (Semua, Aktif, Habis, Pre-Order)
- [ ] Switch untuk toggle product status working

**Add Product Screen**:

- [ ] Form fields accessible
- [ ] Can fill form
- [ ] Submit button working
- [ ] Product muncul di my products dan explore screen

**Edit Product Screen**:

- [ ] Can open edit screen dari menu
- [ ] Form pre-filled dengan product data
- [ ] Update working
- [ ] Changes reflect di explore screen

---

## ✅ Integration Testing

### Scenario 1: Add New Product

```
1. Login sebagai farmer
2. Go to "Produk Saya"
3. Click "Tambah Produk"
4. Fill form dengan valid data
5. Click "Simpan Produk"
✓ Product muncul di "Produk Saya"
✓ Product muncul di "Explore" (consumer view)
```

Checklist:

- [ ] Form validation working
- [ ] API POST request sent
- [ ] Product saved ke database
- [ ] UI updated after save
- [ ] Real-time visible di explore screen

### Scenario 2: Edit Product

```
1. Di "Produk Saya", find product
2. Click menu (tiga titik) → Edit
3. Change product details
4. Click "Update Produk"
✓ Changes visible immediately
✓ Changes reflect di Explore screen
```

Checklist:

- [ ] Edit screen loading dengan correct data
- [ ] Form fields editable
- [ ] API PATCH request sent
- [ ] Database updated
- [ ] Both screens refresh

### Scenario 3: Duplicate Product

```
1. Di "Produk Saya", find product
2. Click menu (tiga titik) → Duplikat
✓ New product created dengan nama "(Copy)"
✓ Copy punya same data sebagai original
```

Checklist:

- [ ] Duplicate API call successful
- [ ] New product created
- [ ] Name suffix "(Copy)" added
- [ ] All fields copied

### Scenario 4: Delete Product

```
1. Di "Produk Saya", find product
2. Click menu (tiga titik) → Hapus
3. Confirm delete
✓ Product removed dari database
✓ Product disappear dari both screens
```

Checklist:

- [ ] Confirmation dialog shown
- [ ] API DELETE request sent
- [ ] Product removed dari database
- [ ] UI updated both screens

### Scenario 5: Toggle Product Status

```
1. Di "Produk Saya", find product
2. Toggle switch untuk aktif/tidak aktif
✓ Status updated
✓ Product disappear dari "Aktif" filter jika deactivate
```

Checklist:

- [ ] Switch responsive
- [ ] API PATCH request sent
- [ ] Database updated
- [ ] Filter reflects new status

---

## ✅ API Verification

### Test dengan Postman/curl

```bash
# 1. Get All Products
curl -X GET http://localhost:3001/api/products

# 2. Get Product by ID
curl -X GET http://localhost:3001/api/products/{id}

# 3. Get Farmer Products (requires auth)
curl -X GET http://localhost:3001/api/products/farmer/me \
  -H "Authorization: Bearer {token}"

# 4. Create Product
curl -X POST http://localhost:3001/api/products \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Product",
    "price": 10000,
    "stock": 50
  }'

# 5. Update Product
curl -X PATCH http://localhost:3001/api/products/{id} \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"price": 12000}'

# 6. Delete Product
curl -X DELETE http://localhost:3001/api/products/{id} \
  -H "Authorization: Bearer {token}"
```

- [ ] All endpoints returning correct status codes
- [ ] Response format valid JSON
- [ ] Error handling working
- [ ] Authentication working

---

## ✅ Error Handling

### Common Errors & Solutions

#### 1. Backend Connection Error

**Error**: `Connection refused` atau `Network error`

```
✓ Verify backend running: curl http://localhost:3001
✓ Check port correct (default 3001)
✓ Check firewall not blocking
✓ Check DATABASE_URL correct
```

#### 2. CORS Error

**Error**: `No 'Access-Control-Allow-Origin' header`

```
✓ Check CORS enabled di NestJS
✓ Add CORS middleware if needed
✓ Whitelist frontend URL
```

#### 3. Authentication Error

**Error**: `401 Unauthorized`

```
✓ Check token valid
✓ Check JWT_SECRET same di backend & frontend
✓ Check user logged in
✓ Check AuthGuard implemented
```

#### 4. Database Error

**Error**: `Connection timeout` atau `Query error`

```
✓ Verify DATABASE_URL correct
✓ Check database running
✓ Check migrations applied
✓ Check user permissions
```

- [ ] Errors documented
- [ ] Solutions tested
- [ ] Error messages clear

---

## ✅ Performance Checks

- [ ] Products loading dalam < 2 detik
- [ ] Search response dalam < 500ms
- [ ] Add/Edit/Delete dalam < 1 detik
- [ ] No memory leaks di Flutter
- [ ] No N+1 query issues

---

## ✅ Security Checks

- [ ] JWT tokens secured
- [ ] Passwords hashed (dari Supabase)
- [ ] API validation enabled
- [ ] SQL injection prevention (Prisma)
- [ ] Rate limiting (optional, untuk production)

---

## 📋 Final Verification

### All Features Working

- [ ] Konsumen bisa melihat semua produk
- [ ] Petani bisa tambah produk
- [ ] Petani bisa edit produk
- [ ] Petani bisa hapus produk
- [ ] Petani bisa duplicate produk
- [ ] Petani bisa toggle status produk
- [ ] Search working
- [ ] Filter working
- [ ] Real-time sync working

### No Critical Bugs

- [ ] App tidak crash saat normal usage
- [ ] API errors handled gracefully
- [ ] Loading states showing
- [ ] Success messages showing
- [ ] Error messages clear

### Production Ready

- [ ] Code review completed
- [ ] Documentation updated
- [ ] Test coverage adequate
- [ ] Performance acceptable
- [ ] Security checklist completed

---

## 🎉 Ready to Deploy!

Jika semua checklist selesai, sistem siap untuk:

1. Beta testing dengan real users
2. Deployment ke production
3. Monitoring & maintenance

---

## 📞 Support & Debugging

If something doesn't work:

1. **Check logs**:
   - Backend: `npm run start:dev` (watch console)
   - Frontend: `flutter run` (watch console)

2. **Debug network**:
   - Check if backend running: `curl http://localhost:3001`
   - Check API endpoints dengan Postman

3. **Check database**:
   - Use `npx prisma studio` untuk inspect
   - Verify tables exist dan data correct

4. **Clear cache**:
   - Flutter: `flutter clean && flutter pub get`
   - Backend: `rm -rf node_modules && npm install`
