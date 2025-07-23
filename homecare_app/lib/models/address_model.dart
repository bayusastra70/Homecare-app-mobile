class AddressModel {
  final String alamat;
  final String desa;
  final String kecamatan;
  final String kabupaten;

  AddressModel({
    required this.alamat,
    required this.desa,
    required this.kecamatan,
    required this.kabupaten,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      alamat: json['alamat'] ?? '',
      desa: json['desa'] ?? '',
      kecamatan: json['kecamatan'] ?? '',
      kabupaten: json['kabupaten'] ?? '',
    );
  }
}
