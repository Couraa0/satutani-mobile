# 🎨 Flutter Implementation Details

## Architecture & Patterns

### Service Layer Pattern

```dart
// Single responsibility - each service handles one domain
ProductService         // Product CRUD
AuthService           // Authentication
UserService           // User profile
```

### Service Implementation

**File**: `frontend/lib/core/services/product_service.dart`

```dart
class ProductService {
  // Static methods - no instance needed
  static const String baseUrl = 'http://localhost:3001/api';

  // Public methods - entry points
  static Future<List<ProductModel>> getAllProducts({...}) async { }
  static Future<ProductModel> getProductById(String id) async { }
  static Future<ProductModel> createProduct(Map<String, dynamic> data) async { }

  // Handle HTTP requests
  // Parse responses
  // Error handling
}
```

**Why Static Methods**?

- No service instantiation needed
- Global access from anywhere
- Simple singleton pattern
- Suitable for MVP

---

## State Management

### Current: FutureBuilder Pattern

```dart
class ExploreScreen extends StatefulWidget {
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late Future<List<ProductModel>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _loadProducts(); // Fetch on first build
  }

  void _loadProducts() {
    setState(() {
      _productsFuture = ProductService.getAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductModel>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final products = snapshot.data ?? [];
        return _buildProductsList(products);
      },
    );
  }
}
```

### Why FutureBuilder?

- Built-in Flutter widget
- No external dependencies
- Good for simple async operations
- Easy to understand

### When to Use FutureBuilder?

✅ Single async operation
✅ Screen-level data loading
✅ Simple loading/error states

### When NOT to Use FutureBuilder?

❌ Complex state management
❌ Multiple interconnected futures
❌ Frequent state updates
❌ Need for optimistic updates

---

## Error Handling Pattern

### Try-Catch with User Feedback

```dart
void _handleEdit() {
  try {
    // Attempt operation
    await ProductService.updateProduct(id, data);

    // Success feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Success message'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true); // Trigger refresh
    }
  } catch (e) {
    // Error feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

### Error Message Guidelines

- User-friendly messages
- Avoid technical jargon
- Suggest action if possible
- Show SnackBar for inline errors
- Show Dialog for critical errors

### Mounted Check Pattern

```dart
// Always check mounted before setState/Navigator in async context
if (mounted) {
  setState(() => _isLoading = false);
  Navigator.pop(context);
}
```

Why? Avoid errors when widget disposed before async completes.

---

## Responsive UI Patterns

### Flexible Layouts

```dart
Row(
  children: [
    Expanded(
      child: Column(
        children: [
          // Left side content
        ],
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: Column(
        children: [
          // Right side content
        ],
      ),
    ),
  ],
)
```

### Constrained Sizes

```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    minimumSize: const Size(double.infinity, 50), // Full width, 50 height
  ),
  onPressed: _saveProduct,
  child: const Text('Save'),
)
```

---

## Navigation Patterns

### Push dengan Return Value

```dart
// Parent screen
onPressed: () async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => EditProductScreen(...)),
  );

  if (result == true) {
    _loadProducts(); // Refresh if edited
  }
}

// Child screen (EditProductScreen)
Navigator.pop(context, true); // Return true to indicate change
```

### Named Routes (Future)

```dart
// Define routes di MaterialApp
routes: {
  '/': (context) => HomeScreen(),
  '/edit-product': (context) => EditProductScreen(),
},

// Navigate
Navigator.pushNamed(context, '/edit-product');
```

---

## Form Validation

### TextFormField Validation

```dart
TextFormField(
  controller: _nameCtrl,
  validator: (v) => (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
  decoration: InputDecoration(
    hintText: 'Nama produk',
    errorText: _formKey.currentState?.fields['name']?.errorText,
  ),
)
```

### Form Submission

```dart
final _formKey = GlobalKey<FormState>();

ElevatedButton(
  onPressed: () {
    if (_formKey.currentState!.validate()) {
      // All fields valid - proceed
      _submitForm();
    }
  },
  child: Text('Submit'),
)
```

### Custom Validation

```dart
String? _validatePrice(String? value) {
  if (value == null || value.isEmpty) {
    return 'Harga wajib diisi';
  }

  final price = double.tryParse(value);
  if (price == null) {
    return 'Harga harus angka';
  }

  if (price <= 0) {
    return 'Harga harus positif';
  }

  return null; // Valid
}

TextFormField(
  validator: _validatePrice,
)
```

---

## Loading States

### Loading Indicator

```dart
// Simple circular
CircularProgressIndicator()

// With message
Column(
  children: [
    CircularProgressIndicator(),
    SizedBox(height: 16),
    Text('Loading...'),
  ],
)

// In button
ElevatedButton(
  onPressed: _isLoading ? null : _saveProduct,
  child: _isLoading
    ? SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
    : Text('Save'),
)
```

### Disabled State

```dart
ElevatedButton(
  onPressed: _isLoading ? null : _handleAction,
  // Null onPressed = disabled button
)
```

---

## Model Conversion

### JSON to Dart Object

```dart
factory ProductModel.fromJson(Map<String, dynamic> json) {
  // Handle both naming conventions
  final name = json['name'] ?? json['Name'];

  // Handle nested objects
  final farmer = json['farmer'] as Map<String, dynamic>?;
  final farmerName = farmer?['name'] ?? '';

  // Type conversion with fallback
  final price = _parseDouble(json['price']);

  // Optional fields
  final harvest = json['estimatedHarvestDate'] != null
    ? DateTime.tryParse(json['estimatedHarvestDate'])
    : null;

  return ProductModel(
    name: name,
    farmerName: farmerName,
    price: price,
    estimatedHarvestDate: harvest,
  );
}

static double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
```

### Dart Object to JSON

```dart
Map<String, dynamic> toJson() => {
  'name': name,
  'price': price,
  'stock': stock,
  'category': category,
  'imageUrls': imageUrls,
};
```

---

## List Rendering

### ListView.builder (Efficient)

```dart
ListView.builder(
  itemCount: products.length,
  itemBuilder: (context, index) {
    final product = products[index];
    return ProductCard(product: product);
  },
)
```

### ListView.separated (With Divider)

```dart
ListView.separated(
  itemCount: products.length,
  separatorBuilder: (_, __) => Divider(height: 1),
  itemBuilder: (context, index) {
    return ProductCard(products: products[index]);
  },
)
```

### Filtered List

```dart
List<ProductModel> get _filtered {
  return products.where((p) {
    if (_filter == 'Aktif') return p.isAvailable;
    if (_filter == 'Habis') return !p.isAvailable;
    return true;
  }).toList();
}

ListView.builder(
  itemCount: _filtered.length,
  itemBuilder: (_, i) => ProductCard(_filtered[i]),
)
```

---

## Text Formatting

### Number Formatting

```dart
// Format harga dengan separator
String formatPrice(double price) {
  return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  )}';
}

// Usage
Text('${formatPrice(product.price)}/kg')
```

### Date Formatting

```dart
// Format tanggal
final date = DateTime(2026, 6, 5);
final formatted = '${date.day} ${_monthName(date.month)} ${date.year}';
// Output: 5 Juni 2026

String _monthName(int month) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
  return months[month - 1];
}
```

---

## Dialog & Confirmation

### Confirmation Dialog

```dart
void _showDeleteConfirm() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete?'),
      content: Text('Confirm delete "${product.name}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _handleDelete();
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
```

### Bottom Sheet

```dart
showModalBottomSheet(
  context: context,
  builder: (context) => Container(
    padding: EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text('Edit'),
          onTap: () {
            Navigator.pop(context);
            _handleEdit();
          },
        ),
        ListTile(
          title: Text('Delete', style: TextStyle(color: Colors.red)),
          onTap: () {
            Navigator.pop(context);
            _handleDelete();
          },
        ),
      ],
    ),
  ),
);
```

---

## Performance Optimization

### Const Constructors

```dart
// Good - reuse const across rebuilds
const AppColors.primary

// Bad - creates new instance each time
Color(0xFF6B8E23)
```

### RepaintBoundary

```dart
// Isolate expensive repaints
RepaintBoundary(
  child: ExpensiveWidget(),
)
```

### Debouncing Search

```dart
Timer? _searchDebounce;

void _onSearchChanged(String query) {
  _searchDebounce?.cancel();
  _searchDebounce = Timer(Duration(milliseconds: 500), () {
    _loadProducts(search: query);
  });
}

@override
void dispose() {
  _searchDebounce?.cancel();
  super.dispose();
}
```

---

## Color & Theme Constants

**File**: `frontend/lib/core/constants/colors.dart`

```dart
abstract class AppColors {
  // Primary
  static const Color primary = Color(0xFF6B8E23); // Olive Green
  static const Color primaryLight = Color(0xFFF0F4E6);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color danger = Color(0xFFF44336);

  // Text
  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF888888);

  // Background
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFEEEEEE);
}
```

---

## HTTP Package Usage

### Get Request

```dart
final response = await http.get(
  Uri.parse(url),
  headers: {'Authorization': 'Bearer $token'},
);

if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
} else {
  throw Exception('Failed: ${response.statusCode}');
}
```

### Post Request

```dart
final response = await http.post(
  Uri.parse(url),
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  },
  body: jsonEncode({'name': 'Bayam', 'price': 5000}),
);
```

### Error Handling

```dart
try {
  final response = await http.get(url).timeout(
    Duration(seconds: 10),
    onTimeout: () => throw TimeoutException(),
  );
} on SocketException {
  // Network error
} on TimeoutException {
  // Timeout error
} on FormatException {
  // JSON parsing error
} catch (e) {
  // Other error
}
```

---

## Best Practices

### 1. Dispose Resources

```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
  }

  @override
  void dispose() {
    _ctrl.dispose(); // Always dispose
    super.dispose();
  }
}
```

### 2. Avoid Memory Leaks

```dart
// Bad - leak if dispose not called
late Future _future;

// Good - call only when needed
late Future? _future;

@override
void dispose() {
  _future = null;
  super.dispose();
}
```

### 3. Use Const

```dart
// Good
const Text('Product')

// Bad
Text('Product') // Creates new each build
```

### 4. Handle Null Safety

```dart
// Handle nullable fields
final name = product?.name ?? 'Unknown';
final images = product?.imageUrls ?? [];
```

### 5. Validate Before Use

```dart
if (products.isEmpty) {
  return Center(child: Text('No products'));
}

return ListView.builder(
  itemCount: products.length,
  itemBuilder: (_, i) => ProductCard(products[i]),
);
```

---

## Testing Widgets

### Widget Test Example

```dart
testWidgets('ProductCard displays product name', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ProductCard(
          product: ProductModel(
            id: '1',
            name: 'Test Product',
            price: 5000,
          ),
        ),
      ),
    ),
  );

  expect(find.text('Test Product'), findsOneWidget);
  expect(find.text('Rp 5000'), findsOneWidget);
});
```

---

## Debugging

### Debug Prints

```dart
// Add for temporary debugging
debugPrint('Product: ${product.name}');
debugPrint('Loading: $_isLoading');

// Use logger for production
import 'package:logger/logger.dart';
final logger = Logger();
logger.i('Info message');
logger.e('Error message');
```

### Hot Reload

```bash
# Save file while running
flutter run

# Hot reload
r (in terminal)

# Full restart
R (in terminal)
```

---

**Best Practices Applied in SatuTani**:
✅ Service layer separation
✅ FutureBuilder for async
✅ Error handling with SnackBar
✅ Form validation
✅ Responsive layouts
✅ Model conversion with null safety
✅ Resource disposal
✅ User feedback patterns

---

**Last Updated**: May 30, 2026
