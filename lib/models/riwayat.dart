class Riwayat {
  String id;
  String obatId;
  String namaObat;
  String dosis;
  String tanggal;
  String waktu;
  String status; // pending, diminum, terlewat
  String? diminumPada;

  Riwayat({
    this.id = '',
    required this.obatId,
    required this.namaObat,
    required this.dosis,
    required this.tanggal,
    required this.waktu,
    this.status = 'pending',
    this.diminumPada,
  });

  Map<String, dynamic> toJson() {
    return {
      'obatId': obatId,
      'namaObat': namaObat,
      'dosis': dosis,
      'tanggal': tanggal,
      'waktu': waktu,
      'status': status,
      'diminumPada': diminumPada,
    };
  }

  factory Riwayat.fromJson(String id, Map<dynamic, dynamic> json) {
    return Riwayat(
      id: id,
      obatId: json['obatId'] as String? ?? '',
      namaObat: json['namaObat'] as String? ?? '',
      dosis: json['dosis'] as String? ?? '',
      tanggal: json['tanggal'] as String? ?? '',
      waktu: json['waktu'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      diminumPada: json['diminumPada'] as String?,
    );
  }

  Riwayat copyWith({
    String? status,
    String? diminumPada,
  }) {
    return Riwayat(
      id: id,
      obatId: obatId,
      namaObat: namaObat,
      dosis: dosis,
      tanggal: tanggal,
      waktu: waktu,
      status: status ?? this.status,
      diminumPada: diminumPada ?? this.diminumPada,
    );
  }
}
