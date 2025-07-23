import 'package:homecare_app/models/layanan_model.dart';

class CartItem {
  final int? idCart;
  int jumlah;
  final Layanan layanan;

  CartItem({required this.idCart, required this.jumlah, required this.layanan});

  CartItem copyWith({int? jumlah}) {
    return CartItem(
      idCart: idCart,
      jumlah: jumlah ?? this.jumlah,
      layanan: layanan,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      idCart: json['id_cart'],
      jumlah: json['jumlah'],
      layanan: Layanan.fromJson(json['layanan']),
    );
  }
}
