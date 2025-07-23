class InvoiceModel {
  final int idInvoice;
  final String status;
  final double biayaObat;
  final double biayaLain;
  final double biayaJalan;
  final double total;
  final String? namaMedis;

  InvoiceModel({
    required this.idInvoice,
    required this.status,
    required this.biayaObat,
    required this.biayaLain,
    required this.biayaJalan,
    required this.total,
    this.namaMedis,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      idInvoice: int.tryParse(json['id_invoice'].toString()) ?? 0,
      status: json['status'].toString(),
      biayaObat: double.tryParse(json['biaya_obat'].toString()) ?? 0.0,
      biayaLain: double.tryParse(json['biaya_lain'].toString()) ?? 0.0,
      biayaJalan: double.tryParse(json['biaya_jalan'].toString()) ?? 0.0,
      total: double.tryParse(json['total'].toString()) ?? 0.0,
      namaMedis: json['nama_medis']?.toString(),
    );
  }
}
