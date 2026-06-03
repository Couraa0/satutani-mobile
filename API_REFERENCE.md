# 🔌 API Reference & Quick Guide

## Base URL

```
http://localhost:3001/api
```

Change URL di `frontend/lib/core/services/product_service.dart` jika berbeda.

---

## 📡 Endpoints

### 1. GET All Products (Public)

**Endpoint**: `GET /products`

**Parameters**:

```
query:
  - limit: number (default: 20)
  - offset: number (default: 0)
  - category: string (optional)
  - search: string (optional)
```

**Example**:

```
GET /products?limit=20&offset=0&search=bayam
```

**Response** (200 OK):

```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Bayam Segar",
    "description": "Bayam hijau organik",
    "price": "5000.00",
    "unit": "ikat",
    "rating": "4.9",
    "reviewCount": 89,
    "stock": "80.00",
    "category": "vegetable",
    "imageUrls": ["https://..."],
    "isAvailable": true,
    "isAiPrice": false,
    "isPreOrder": false,
    "farmer": {
      "id": "farmer-uuid",
      "name": "Budi Santoso",
      "avatarUrl": "https://..."
    },
    "createdAt": "2026-05-30T00:00:00Z",
    "updatedAt": "2026-05-30T00:00:00Z"
  }
]
```

**Error** (400/500):

```json
{
  "statusCode": 400,
  "message": "Invalid query parameters",
  "error": "Bad Request"
}
```

---

### 2. GET Product by ID (Public)

**Endpoint**: `GET /products/:id`

**Parameters**:

```
path:
  - id: string (UUID)
```

**Example**:

```
GET /products/550e8400-e29b-41d4-a716-446655440000
```

**Response** (200 OK):

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Bayam Segar",
  "description": "Bayam hijau organik",
  "price": "5000.00",
  "unit": "ikat",
  "rating": "4.9",
  "reviewCount": 89,
  "stock": "80.00",
  "category": "vegetable",
  "imageUrls": ["https://..."],
  "isAvailable": true,
  "isAiPrice": false,
  "isPreOrder": false,
  "estimatedHarvestDate": "2026-06-05",
  "preOrderTarget": "100.00",
  "preOrderFilled": "50.00",
  "farmer": {
    "id": "farmer-uuid",
    "name": "Budi Santoso",
    "avatarUrl": "https://...",
    "farmerProfile": {
      "location": "Lembang, Bandung",
      "province": "Jawa Barat",
      "isVerified": true,
      "rating": "4.8",
      "reviewCount": 150
    }
  },
  "reviews": [
    {
      "id": "review-uuid",
      "rating": 5,
      "text": "Produk segar dan berkualitas",
      "consumer": {
        "id": "consumer-uuid",
        "name": "Adi Pratama",
        "avatarUrl": "https://..."
      }
    }
  ],
  "createdAt": "2026-05-30T00:00:00Z",
  "updatedAt": "2026-05-30T00:00:00Z"
}
```

**Error** (404):

```json
{
  "statusCode": 404,
  "message": "Produk tidak ditemukan",
  "error": "Not Found"
}
```

---

### 3. GET Farmer's Products (Authenticated)

**Endpoint**: `GET /products/farmer/me`

**Headers**:

```
Authorization: Bearer {jwt_token}
```

**Response** (200 OK):

```json
[
  {
    "id": "product-uuid",
    "name": "Bayam Segar",
    "price": "5000.00",
    "stock": "80.00",
    ...
  },
  {
    "id": "product-uuid-2",
    "name": "Wortel Organik",
    "price": "8000.00",
    "stock": "60.00",
    ...
  }
]
```

**Error** (401):

```json
{
  "statusCode": 401,
  "message": "Unauthorized",
  "error": "Unauthorized"
}
```

---

### 4. POST Create Product (Authenticated)

**Endpoint**: `POST /products`

**Headers**:

```
Authorization: Bearer {jwt_token}
Content-Type: application/json
```

**Body**:

```json
{
  "name": "Bayam Segar",
  "description": "Bayam hijau organik dari Lembang",
  "price": 5000,
  "unit": "ikat",
  "stock": 80,
  "category": "vegetable",
  "imageUrls": ["https://...image1.jpg", "https://...image2.jpg"],
  "isAvailable": true,
  "isAiPrice": false,
  "isPreOrder": false,
  "estimatedHarvestDate": "2026-06-05",
  "preOrderTarget": 100
}
```

**Response** (201 Created):

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "farmerId": "farmer-uuid",
  "name": "Bayam Segar",
  "price": "5000.00",
  "stock": "80.00",
  ...
}
```

**Error** (400):

```json
{
  "statusCode": 400,
  "message": "Validation failed: price must be positive number",
  "error": "Bad Request"
}
```

**Error** (401):

```json
{
  "statusCode": 401,
  "message": "Unauthorized",
  "error": "Unauthorized"
}
```

---

### 5. PATCH Update Product (Authenticated)

**Endpoint**: `PATCH /products/:id`

**Headers**:

```
Authorization: Bearer {jwt_token}
Content-Type: application/json
```

**Body** (partial, hanya field yang mau diubah):

```json
{
  "price": 6000,
  "stock": 100,
  "isAvailable": true
}
```

**Response** (200 OK):

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Bayam Segar",
  "price": "6000.00",
  "stock": "100.00",
  ...
}
```

**Error** (403):

```json
{
  "statusCode": 403,
  "message": "Forbidden - Anda hanya bisa edit produk milik Anda",
  "error": "Forbidden"
}
```

**Error** (404):

```json
{
  "statusCode": 404,
  "message": "Produk tidak ditemukan",
  "error": "Not Found"
}
```

---

### 6. DELETE Product (Authenticated)

**Endpoint**: `DELETE /products/:id`

**Headers**:

```
Authorization: Bearer {jwt_token}
```

**Response** (200 OK):

```json
{
  "message": "Product deleted successfully"
}
```

**Error** (403):

```json
{
  "statusCode": 403,
  "message": "Forbidden - Anda hanya bisa hapus produk milik Anda",
  "error": "Forbidden"
}
```

**Error** (404):

```json
{
  "statusCode": 404,
  "message": "Produk tidak ditemukan",
  "error": "Not Found"
}
```

---

## 🔐 Authentication

### How to Get JWT Token

1. **Login via Supabase Auth**:

   ```dart
   // In Flutter - auth_service.dart
   final session = await auth.signInWithPassword(
     email: 'user@example.com',
     password: 'password'
   );
   final token = session.user?.id;
   ```

2. **Send Token in Header**:
   ```dart
   final headers = {
     'Authorization': 'Bearer $token',
     'Content-Type': 'application/json',
   };
   ```

### Token Format

```
Authorization: Bearer {uuid}
```

---

## 📝 Request Examples

### Using cURL

**Get all products**:

```bash
curl -X GET "http://localhost:3001/api/products?limit=10"
```

**Get farmer's products**:

```bash
curl -X GET "http://localhost:3001/api/products/farmer/me" \
  -H "Authorization: Bearer 550e8400-e29b-41d4-a716-446655440000"
```

**Create product**:

```bash
curl -X POST "http://localhost:3001/api/products" \
  -H "Authorization: Bearer 550e8400-e29b-41d4-a716-446655440000" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Bayam Segar",
    "price": 5000,
    "stock": 80,
    "unit": "ikat",
    "category": "vegetable"
  }'
```

**Update product**:

```bash
curl -X PATCH "http://localhost:3001/api/products/product-uuid" \
  -H "Authorization: Bearer 550e8400-e29b-41d4-a716-446655440000" \
  -H "Content-Type: application/json" \
  -d '{
    "price": 6000,
    "stock": 100
  }'
```

**Delete product**:

```bash
curl -X DELETE "http://localhost:3001/api/products/product-uuid" \
  -H "Authorization: Bearer 550e8400-e29b-41d4-a716-446655440000"
```

---

## 🎯 Common Response Codes

| Code | Meaning      | Action                                |
| ---- | ------------ | ------------------------------------- |
| 200  | OK           | Request successful                    |
| 201  | Created      | Resource created successfully         |
| 400  | Bad Request  | Check request format & validation     |
| 401  | Unauthorized | Check token validity                  |
| 403  | Forbidden    | User not authorized for this resource |
| 404  | Not Found    | Resource doesn't exist                |
| 500  | Server Error | Backend error - check server logs     |

---

## 🚨 Error Handling

### Response Format

All errors follow this format:

```json
{
  "statusCode": 400,
  "message": "Deskripsi error yang jelas",
  "error": "Error Type"
}
```

### Common Errors

**Missing Token**:

```json
{
  "statusCode": 401,
  "message": "Unauthorized",
  "error": "Unauthorized"
}
```

**Invalid Token**:

```json
{
  "statusCode": 401,
  "message": "Invalid token",
  "error": "Unauthorized"
}
```

**Validation Error**:

```json
{
  "statusCode": 400,
  "message": "Price must be a positive number",
  "error": "Bad Request"
}
```

**Resource Not Found**:

```json
{
  "statusCode": 404,
  "message": "Produk tidak ditemukan",
  "error": "Not Found"
}
```

**Permission Denied**:

```json
{
  "statusCode": 403,
  "message": "Anda hanya bisa edit produk milik Anda",
  "error": "Forbidden"
}
```

---

## 💡 Field Types & Validation

### Product Fields

| Field                | Type    | Required | Validation                          |
| -------------------- | ------- | -------- | ----------------------------------- |
| name                 | string  | ✅       | Min 3, Max 255 chars                |
| description          | string  | ❌       | Max 1000 chars                      |
| price                | number  | ✅       | Positive, max 14 digits             |
| unit                 | string  | ✅       | kg, gram, ikat, buah, liter, karung |
| stock                | number  | ✅       | Non-negative, max 10 digits         |
| category             | string  | ❌       | vegetable, fruit, grain, spice, etc |
| imageUrls            | array   | ❌       | Valid URLs, max 5 items             |
| isAvailable          | boolean | ❌       | Default: true                       |
| isAiPrice            | boolean | ❌       | Default: false                      |
| isPreOrder           | boolean | ❌       | Default: false                      |
| estimatedHarvestDate | date    | ❌       | Format: YYYY-MM-DD                  |
| preOrderTarget       | number  | ❌       | Positive if preorder                |

---

## 🧪 Testing API

### Using Postman

1. **Create Collection**: Products API
2. **Set Base URL**: `http://localhost:3001/api`
3. **Create Requests**:
   - GET /products
   - GET /products/:id
   - POST /products (with Bearer token)
   - PATCH /products/:id (with Bearer token)
   - DELETE /products/:id (with Bearer token)

4. **Set Authorization**:
   - Type: Bearer Token
   - Token: `{JWT token dari login}`

### Using Insomnia

Similar to Postman, setup requests dengan base URL dan auth header.

---

## 📊 Data Type Reference

### Decimal Fields

Fields seperti `price`, `stock`, `rating` return sebagai string dari database:

```json
{
  "price": "5000.00",
  "stock": "80.00",
  "rating": "4.9"
}
```

Parse di Flutter:

```dart
double price = double.parse(json['price']); // 5000.0
```

### Date Fields

Format ISO 8601:

```json
{
  "createdAt": "2026-05-30T12:34:56.789Z",
  "estimatedHarvestDate": "2026-06-05"
}
```

Parse di Flutter:

```dart
DateTime created = DateTime.parse(json['createdAt']);
DateTime harvest = DateTime.parse(json['estimatedHarvestDate']);
```

### Array Fields

```json
{
  "imageUrls": ["https://example.com/img1.jpg", "https://example.com/img2.jpg"]
}
```

Parse di Flutter:

```dart
List<String> images = List<String>.from(json['imageUrls'] ?? []);
```

---

## 🔄 Real-Time Considerations

### Current Behavior

- **No WebSocket**: HTTP REST only
- **Manual Refresh**: Pull-to-refresh atau navigate away & back
- **Eventual Consistency**: Changes visible saat screen reload

### Checking for Updates

```dart
// Manual refresh approach
void _refreshProducts() {
  setState(() {
    _productsFuture = ProductService.getFarmerProducts();
  });
}

// Or use FutureBuilder with refetch
onPressed: () {
  _refreshProducts();
}
```

### Future: Real-Time Updates

Implementasi WebSocket atau Firebase untuk live updates:

```dart
// Example (future)
ProductService.watchProducts().listen((products) {
  setState(() => _products = products);
});
```

---

## 🛠️ Debugging Tips

### Enable Request Logging

```dart
// Add di ProductService untuk debug
print('Request: $uri');
print('Headers: $headers');
print('Response: ${response.statusCode}');
print('Body: ${response.body}');
```

### Check Network Tab

- Use Chrome DevTools (web platform)
- Use Android Studio Network Inspector
- Use Xcode Network tab (iOS)

### Common Issues & Solutions

**Issue**: `Connection refused`

```
✓ Check backend running: curl http://localhost:3001
✓ Check port correct
✓ Check firewall
```

**Issue**: `CORS error`

```
✓ Check CORS enabled di NestJS
✓ Check whitelist origin
```

**Issue**: `401 Unauthorized`

```
✓ Check token di localStorage/prefs
✓ Check token format correct
✓ Check token not expired
```

**Issue**: `Product not updated`

```
✓ Check network request sent
✓ Check response code 200
✓ Check database actually updated
✓ Check cache not stale
```

---

## 📚 Additional Resources

- **NestJS Docs**: https://docs.nestjs.com
- **Prisma Docs**: https://www.prisma.io/docs
- **REST API Best Practices**: https://restfulapi.net
- **HTTP Status Codes**: https://httpwg.org/specs/rfc7231.html

---

**Last Updated**: May 30, 2026
