# 🔧 Troubleshooting & Debugging Guide

## Quick Diagnosis

### Step 1: Identify the Layer

```
Frontend (Flutter)
    ↓ API Call
Backend (NestJS)
    ↓ Database Query
Database (PostgreSQL)
```

**Question**: Where is the problem?

- [ ] UI not showing products → Frontend
- [ ] Backend returns 500 error → Backend
- [ ] Data not in database → Database

---

## Frontend Issues

### 1. Products Not Showing in UI

#### Problem: ExploreScreen shows loading spinner forever

**Causes**:

1. API call hanging
2. Network unreachable
3. Invalid response format

**Debug Steps**:

```dart
// Add print statements in product_service.dart
Future<List<ProductModel>> getAllProducts(...) async {
  try {
    final uri = Uri.parse('$baseUrl/products?...');
    debugPrint('Request URL: $uri'); // Check URL is correct

    final response = await http.get(uri, headers: headers)
      .timeout(Duration(seconds: 5)); // Add timeout

    debugPrint('Response code: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((j) => ProductModel.fromJson(j)).toList();
    } else {
      throw Exception('Status ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Error: $e');
    rethrow;
  }
}
```

**Solutions**:

- Check backend running: `curl http://localhost:3001/api/products`
- Check URL correct in ProductService baseUrl
- Check network timeout (should be 5-10 seconds)
- Check JSON response format matches ProductModel

#### Problem: Products show but missing images

**Causes**:

1. imageUrls empty or null
2. Image URL invalid
3. Image server unreachable

**Debug**:

```dart
// Check ProductModel.fromJson()
debugPrint('Image URLs: ${product.imageUrls}');
debugPrint('First image: ${product.imageUrls.isNotEmpty ? product.imageUrls[0] : 'empty'}');
```

**Solution**:

```dart
// Use placeholder if no images
Image.network(
  product.imageUrls.isNotEmpty
    ? product.imageUrls[0]
    : 'https://via.placeholder.com/300?text=No+Image',
  errorBuilder: (_, __, ___) =>
    Container(color: Colors.grey, child: Icon(Icons.image_not_supported)),
)
```

### 2. Add Product Fails

#### Problem: "Save product" button stuck on loading

**Causes**:

1. API request never completes
2. Validation error from backend
3. Network timeout

**Debug**:

```dart
void _saveProduct() async {
  debugPrint('Starting save...');
  setState(() => _isLoading = true);

  try {
    final data = {
      'name': _nameCtrl.text,
      'price': double.parse(_priceCtrl.text),
      'stock': _stock,
      'category': categoryMap[_selectedCategory],
    };

    debugPrint('Sending data: $data');
    final response = await ProductService.createProduct(data);
    debugPrint('Success response: $response');

    Navigator.pop(context, true);
  } catch (e) {
    debugPrint('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
```

**Solutions**:

- Check token valid: Print from `AuthService.currentUser?.id`
- Check data validation: Verify all required fields filled
- Check backend logs: See exact error message
- Check network: `flutter doctor` untuk diagnose

#### Problem: Product created but not in list

**Causes**:

1. Product saved but query doesn't include it
2. Filter hiding the product
3. Cache stale

**Debug**:

```dart
// Force refresh
void _refreshProducts() {
  setState(() {
    _productsFuture = ProductService.getFarmerProducts();
  });
  debugPrint('Products refreshed');
}

// Check filters
debugPrint('Current filter: ${_selectedFilter}');
debugPrint('Product isAvailable: ${product.isAvailable}');
```

**Solution**:

```dart
// Manual refresh after add
Navigator.pop(context, true); // Signal parent to refresh
// In parent:
if (result == true) {
  _loadProducts(); // Force fetch new data
}
```

### 3. Edit/Delete Menu Not Working

#### Problem: Menu items click but nothing happens

**Causes**:

1. onTap callback not wired
2. Callback doesn't trigger
3. Wrong context used

**Debug**:

```dart
PopupMenuButton(
  itemBuilder: (context) => [
    PopupMenuItem(
      child: Text('Edit'),
      onTap: () {
        debugPrint('Edit tapped');
        Future.delayed(Duration(milliseconds: 0), () {
          _handleEdit(); // Must be delayed
        });
      },
    ),
  ],
)
```

**Solution**: Always delay callback after PopupMenu closes

```dart
onTap: () {
  Future.delayed(Duration.zero, () => _handleEdit());
}
```

### 4. Authentication Token Missing

#### Problem: Backend returns 401 Unauthorized

**Causes**:

1. Token not extracted from AuthService
2. Token invalid/expired
3. Header format wrong

**Debug**:

```dart
// In ProductService
final token = AuthService.currentUser?.id;
debugPrint('Token: $token');
debugPrint('Token null: ${token == null}');

final headers = {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
};
debugPrint('Headers: $headers');

final response = await http.post(uri, headers: headers, ...);
debugPrint('Response code: ${response.statusCode}');
```

**Solution**:

```dart
// Ensure token from right place
final user = AuthService.currentUser;
if (user == null) {
  throw Exception('Not authenticated');
}
final token = user.id; // Use UUID as token
```

---

## Backend Issues

### 1. API Endpoint Returns 500

#### Problem: POST /products returns 500 Internal Server Error

**Solution**: Check backend logs

```bash
# Terminal where backend running
cd backend/api
npm run start:dev

# Look for error trace in console
# Example:
# [Nest] 12345 - 05/30/2026, 2:34:56 PM   ERROR [ExceptionHandler] Validation failed
```

**Common Causes**:

| Error                                        | Solution                                   |
| -------------------------------------------- | ------------------------------------------ |
| `Cannot read property 'userId' of undefined` | User not in request (missing auth guard)   |
| `Decimal value invalid`                      | Price string, convert to number            |
| `Category not valid enum`                    | Category value not in enum (check mapping) |
| `Unique constraint failed`                   | Duplicate email/name                       |
| `Foreign key constraint failed`              | Referenced record not exist                |

### 2. CORS Error

#### Problem: `Access to XMLHttpRequest blocked by CORS policy`

**Solution**: Enable CORS in NestJS

```typescript
// main.ts
const app = await NestFactory.create(AppModule);

app.enableCors({
  origin: ["http://localhost:3000", "http://localhost:3001"],
  credentials: true,
});
```

**Alternative**: Use proxy

```bash
# In Flutter, use proxy for development
flutter run --dart-define=PROXY_URL=http://proxy:8080
```

### 3. Database Query Fails

#### Problem: Backend returns error about database

**Debug**: Use Prisma Studio

```bash
cd backend/api
npx prisma studio

# Opens http://localhost:5555
# Browse database, see actual data
```

**Check**:

1. Products table exists
2. Columns match schema
3. Data types correct
4. Foreign keys valid

### 4. Product Endpoint Returns Empty

#### Problem: GET /products returns empty array always

**Causes**:

1. Database empty (no products)
2. Query filtering all out
3. User doesn't have products (farmer endpoint)

**Debug**:

```bash
# Check database directly
cd backend/api
npx prisma studio

# Click Products table
# Should see list of products
```

**Solution**:

1. Add product via API
2. Or seed database
3. Or check filter logic

---

## Database Issues

### 1. Connection Failed

#### Problem: `Error: P1000 Authentication failed`

**Causes**:

1. DATABASE_URL wrong
2. Credentials incorrect
3. Database server down

**Solution**:

```bash
# Check connection string
echo $DATABASE_URL

# Format: postgresql://user:password@host:port/database

# Test connection
psql $DATABASE_URL -c "SELECT 1"

# Should return: 1 (one)
```

### 2. Schema Out of Sync

#### Problem: Table doesn't have column defined

**Causes**:

1. Migration not run
2. Schema not updated

**Solution**:

```bash
cd backend/api

# Check migrations
npx prisma migrate status

# Run pending migrations
npx prisma migrate deploy

# Reset database (DEV ONLY!)
npx prisma migrate reset
```

### 3. Data Lost After Restart

#### Problem: Products created but disappear after backend restart

**Causes**:

1. Database not persistent
2. Using in-memory database
3. Wrong DATABASE_URL

**Solution**: Ensure DATABASE_URL points to persistent database

```
postgresql://user:password@localhost:5432/satutani
```

NOT:

```
file:./dev.db  # SQLite - not suitable for production
```

---

## Testing Manually

### Using cURL

#### Test 1: Get all products

```bash
curl -X GET http://localhost:3001/api/products

# Should return: [] or [{"id": "...", "name": "...", ...}]
```

#### Test 2: Get farmer products (with auth)

```bash
# First get token from auth
TOKEN="550e8400-e29b-41d4-a716-446655440000"

curl -X GET http://localhost:3001/api/products/farmer/me \
  -H "Authorization: Bearer $TOKEN"

# Should return: 200 with products list
# OR: 401 if token invalid
```

#### Test 3: Create product

```bash
TOKEN="550e8400-e29b-41d4-a716-446655440000"

curl -X POST http://localhost:3001/api/products \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Bayam",
    "price": 5000,
    "stock": 80,
    "unit": "ikat",
    "category": "vegetable"
  }'

# Should return: 201 with created product
```

### Using Postman

1. **Create Collection**: Test API
2. **Add Request**: GET /products
3. **Send**: Check response
4. **Add Auth**: Bearer token
5. **Test Protected**: POST /products

---

## Performance Issues

### 1. App Slow When Loading Products

#### Problem: Takes 5+ seconds to load products

**Causes**:

1. Network slow (check WiFi)
2. Database query slow (no index)
3. App doing too much work

**Debug**:

```dart
// Measure load time
final start = DateTime.now();
final products = await ProductService.getAllProducts();
final duration = DateTime.now().difference(start);
debugPrint('Load took: ${duration.inMilliseconds}ms');
```

**Solutions**:

- Check network: Use faster WiFi
- Add pagination: Load 20 instead of 1000
- Add database index on frequently searched fields
- Use caching

### 2. UI Freezes During Search

**Causes**:

1. Search triggers rebuild
2. Too many products rendered
3. Image loading blocks UI

**Solutions**:

```dart
// Add debounce
Timer? _searchDebounce;

void _onSearchChanged(String query) {
  _searchDebounce?.cancel();
  _searchDebounce = Timer(Duration(milliseconds: 300), () {
    setState(() {
      _productsFuture = ProductService.getAllProducts(search: query);
    });
  });
}

// Use ListView.builder instead of ListView
ListView.builder(
  itemCount: products.length,
  itemBuilder: (_, i) => ProductCard(products[i]),
)
```

---

## Common Error Messages

### Frontend Errors

| Error                                      | Meaning             | Fix                          |
| ------------------------------------------ | ------------------- | ---------------------------- |
| `Connection refused`                       | Backend not running | Start: `npm run start:dev`   |
| `Timeout of 5000ms exceeded`               | Network too slow    | Check WiFi, increase timeout |
| `FormatException: Invalid radix-10 number` | JSON parsing failed | Check API returns valid JSON |
| `NoSuchMethodError: null check`            | Null value accessed | Add null checks              |

### Backend Errors

| Error                             | Meaning                      | Fix                      |
| --------------------------------- | ---------------------------- | ------------------------ |
| `P1000 Authentication failed`     | DB credentials wrong         | Check DATABASE_URL       |
| `P2002: Unique constraint failed` | Duplicate value              | Check data doesn't exist |
| `P2025: Record not found`         | DELETE/UPDATE missing record | Check ID correct         |
| `CORS policy: blocked`            | Frontend domain not allowed  | Enable CORS              |

### Database Errors

| Error                            | Meaning         | Fix                |
| -------------------------------- | --------------- | ------------------ |
| `FATAL: database does not exist` | DB not created  | Create database    |
| `Connection timeout`             | DB unreachable  | Check host/port    |
| `Syntax error in SQL`            | Query malformed | Check Prisma query |

---

## Debugging Checklist

When something breaks:

- [ ] **1. Check Backend**
  - [ ] Is it running? `curl http://localhost:3001/api/health`
  - [ ] Any errors in console?
  - [ ] Database connected? Check logs

- [ ] **2. Check Database**
  - [ ] Is it running? Can you connect?
  - [ ] Has data? Check with `psql` or Prisma Studio
  - [ ] Schema correct? Compare with schema.prisma

- [ ] **3. Check Frontend**
  - [ ] Any error in console?
  - [ ] Network tab shows request?
  - [ ] Response looks correct?

- [ ] **4. Check Network**
  - [ ] Can ping localhost:3001?
  - [ ] Firewall blocking?
  - [ ] VPN interfering?

- [ ] **5. Check Code**
  - [ ] All required fields filled?
  - [ ] Validation passing?
  - [ ] Token valid?

---

## Getting Help

### Information to Collect

When reporting a bug:

```
**Environment**:
- Flutter version: `flutter --version`
- Dart version: `dart --version`
- Backend: NestJS v11.0.1
- Database: PostgreSQL via Supabase
- OS: Windows/macOS/Linux

**Error Message**:
[Full error stack trace]

**Steps to Reproduce**:
1. ...
2. ...
3. ...

**Expected Behavior**:
[What should happen]

**Actual Behavior**:
[What actually happened]

**Screenshots**:
[If UI issue]

**Logs**:
[Backend logs when error occurs]
```

### Resources

- **Flutter Docs**: https://flutter.dev/docs
- **NestJS Docs**: https://docs.nestjs.com
- **Prisma Docs**: https://www.prisma.io/docs
- **Stack Overflow**: Tag with `flutter`, `nestjs`
- **GitHub Issues**: Check repo issues

---

## Quick Recovery

### Everything Broken - Start Fresh

```bash
# 1. Stop everything
# Ctrl+C in terminals

# 2. Clean frontend
cd frontend
flutter clean
rm pubspec.lock
flutter pub get

# 3. Clean backend
cd ../backend/api
rm -rf node_modules package-lock.json
npm install

# 4. Reset database
npx prisma migrate reset  # WARNING: Deletes all data!

# 5. Start fresh
npm run start:dev  # Backend
# In new terminal:
flutter run  # Frontend
```

### Specific Issue - Quick Fixes

| Issue               | Command                                           |
| ------------------- | ------------------------------------------------- |
| Flutter build error | `flutter clean && flutter pub get && flutter run` |
| Backend won't start | `npm install && npm run start:dev`                |
| Database locked     | `npx prisma db push --force-reset`                |
| Port already in use | `lsof -i :3001` (find process, kill it)           |
| Old data showing    | Pull screen down to refresh, `flutter run`        |

---

**Last Updated**: May 30, 2026
**Status**: Ready for Reference
