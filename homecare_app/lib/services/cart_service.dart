import '../models/cart_model.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;

  CartService._internal();

  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  void addToCart(CartItem item) {
    final index = _cartItems.indexWhere((e) => e.layanan.idLayanan == item.layanan.idLayanan);
    if (index != -1) {
      _cartItems[index].jumlah += item.jumlah;
    } else {
      _cartItems.add(item);
    }
  }

  void removeFromCart(int layananId) {
    _cartItems.removeWhere((item) => item.layanan.idLayanan == layananId);
  }

  void updateQuantity(int layananId, int newQuantity) {
    final index = _cartItems.indexWhere((item) => item.layanan.idLayanan == layananId);
    if (index != -1 && newQuantity >= 1) {
      _cartItems[index].jumlah = newQuantity;
    }
  }

  void clearCart() {
    _cartItems.clear();
  }

  double getTotalHarga() {
    return _cartItems.fold(
      0.0,
      (sum, item) => sum + item.layanan.harga * item.jumlah,
    );
  }
}
