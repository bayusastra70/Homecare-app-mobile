class Layanan {
  final int idLayanan;
  final String jenisLayanan;
  final String keterangan;
  final int harga;
  final String status;

  Layanan({
    required this.idLayanan,
    required this.jenisLayanan,
    required this.keterangan,
    required this.harga,
    required this.status,
  });

  factory Layanan.fromJson(Map<String, dynamic> json) {
    return Layanan(
      idLayanan: json['id_layanan'],
      jenisLayanan: json['jenis_layanan'],
      keterangan: json['keterangan'],
      harga: int.parse(json['harga'].toString()),
      status: json['status'],
    );
  }
}
