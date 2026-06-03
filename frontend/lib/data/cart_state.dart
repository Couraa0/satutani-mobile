import 'package:flutter/foundation.dart';
import 'models/product_model.dart';

/// Item di keranjang: satu produk (model asli dari API) + jumlah.
class CartItem {
  final ProductModel product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}

/// Keranjang global (in-memory). Diisi dari layar produk (mis. explore).
final List<CartItem> globalCart = [];

/// Notifier agar UI yang menampilkan keranjang ikut update walau dibangun di
/// dalam IndexedStack (mis. tab Keranjang yang tidak otomatis rebuild).
/// Nilainya hanya counter perubahan.
final ValueNotifier<int> cartNotifier = ValueNotifier<int>(0);

void _notify() => cartNotifier.value++;

/// Tambah produk ke keranjang; jika sudah ada, tambahkan jumlahnya.
void addToCart(ProductModel product, {int quantity = 1}) {
  final existing = globalCart.where((c) => c.product.id == product.id);
  if (existing.isNotEmpty) {
    existing.first.quantity += quantity;
  } else {
    globalCart.add(CartItem(product: product, quantity: quantity));
  }
  _notify();
}

void incrementQty(int index) {
  globalCart[index].quantity++;
  _notify();
}

/// Kurangi jumlah; jika tinggal 1, item dihapus dari keranjang.
void decrementQty(int index) {
  if (globalCart[index].quantity > 1) {
    globalCart[index].quantity--;
  } else {
    globalCart.removeAt(index);
  }
  _notify();
}

void removeFromCart(int index) {
  globalCart.removeAt(index);
  _notify();
}

void clearCart() {
  globalCart.clear();
  _notify();
}
