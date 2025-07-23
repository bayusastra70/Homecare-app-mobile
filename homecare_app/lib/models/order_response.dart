class OrderResponse {
  final int code;
  final String status;
  final Invoice invoice;
  final Pesanan pesanan;

  OrderResponse({
    required this.code,
    required this.status,
    required this.invoice,
    required this.pesanan,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return OrderResponse(
      code: json['code'],
      status: json['status'],
      invoice: Invoice.fromJson(data['invoice']),
      pesanan: Pesanan.fromJson(data['pesanan']),
    );
  }
}

class OrderListResponse {
  final int code;
  final String status;
  final List<Pesanan> data;

  OrderListResponse({
    required this.code,
    required this.status,
    required this.data,
  });

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    return OrderListResponse(
      code: json['code'],
      status: json['status'],
      data: List<Pesanan>.from(json['data'].map((x) => Pesanan.fromJson(x))),
    );
  }
}

class Invoice {
  final int idInvoice;
  final int idPengguna;
  final String status;
  final double biayaLain;
  final double biayaObat;
  final double total;

  Invoice({
    required this.idInvoice,
    required this.idPengguna,
    required this.status,
    required this.biayaLain,
    required this.biayaObat,
    required this.total,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      idInvoice: json['id_invoice'],
      idPengguna: json['id_pengguna'],
      status: json['status'],
      biayaLain: (json['biaya_lain'] as num).toDouble(),
      biayaObat: (json['biaya_obat'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }
}

class Pesanan {
  final int idPesanan;
  final int idInvoice;
  final int idLayanan;
  final String namaLayanan;
  final int jumlah;
  final double harga;

  Pesanan({
    required this.idPesanan,
    required this.idInvoice,
    required this.idLayanan,
    required this.namaLayanan,
    required this.jumlah,
    required this.harga,
  });

  factory Pesanan.fromJson(Map<String, dynamic> json) {
    return Pesanan(
      idPesanan: json['id_pesanan'],
      idInvoice: json['id_invoice'],
      idLayanan: json['id_layanan'],
      namaLayanan: json['nama_layanan'],
      jumlah: json['jumlah'],
      harga: (json['harga'] as num).toDouble(),
    );
  }
}
