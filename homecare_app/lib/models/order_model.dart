import 'invoice_model.dart';

class OrderModel {
  final int idPesanan;
  final int idInvoice;
  final int idLayanan;
  final String namaLayanan;
  final int jumlah;
  final double harga;
  final String? buktiPembayaran;
  final String? status;
  final InvoiceModel? invoice;

  OrderModel({
    required this.idPesanan,
    required this.idInvoice,
    required this.idLayanan,
    required this.namaLayanan,
    required this.jumlah,
    required this.harga,
    this.buktiPembayaran,
    this.status,
    this.invoice,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final invoiceJson = json['invoice'];
    return OrderModel(
      idPesanan: int.tryParse(json['id_pesanan'].toString()) ?? 0,
      idInvoice: int.tryParse(json['id_invoice'].toString()) ?? 0,
      idLayanan: int.tryParse(json['id_layanan'].toString()) ?? 0,
      namaLayanan: json['nama_layanan'].toString(),
      jumlah: int.tryParse(json['jumlah'].toString()) ?? 0,
      harga: double.tryParse(json['harga'].toString()) ?? 0.0,
      buktiPembayaran: json['bukti_pembayaran']?.toString(),
      status: invoiceJson != null ? invoiceJson['status'].toString() : null,
      invoice: invoiceJson != null ? InvoiceModel.fromJson(invoiceJson) : null,
    );
  }
}
