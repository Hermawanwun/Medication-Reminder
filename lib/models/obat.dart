class Obat {
  String id;
  String nama;
  String dosis;
  String frekuensi;
  List<String> waktuMinum;
  int durasiHari;
  String tanggalMulai;
  String tanggalSelesai;
  bool aktif;
  String createdAt;

  Obat({
    this.id = '',
    required this.nama,
    required this.dosis,
    required this.frekuensi,
    required this.waktuMinum,
    required this.durasiHari,
    required this.tanggalMulai,
    this.tanggalSelesai = '',
    this.aktif = true,
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'dosis': dosis,
      'frekuensi': frekuensi,
      'waktuMinum': waktuMinum,
      'durasiHari': durasiHari,
      'tanggalMulai': tanggalMulai,
      'tanggalSelesai': tanggalSelesai,
      'aktif': aktif,
      'createdAt': createdAt,
    };
  }

  factory Obat.fromJson(String id, Map<dynamic, dynamic> json) {
    return Obat(
      id: id,
      nama: json['nama'] as String? ?? '',
      dosis: json['dosis'] as String? ?? '',
      frekuensi: json['frekuensi'] as String? ?? '',
      waktuMinum: (json['waktuMinum'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      durasiHari: (json['durasiHari'] as num?)?.toInt() ?? 0,
      tanggalMulai: json['tanggalMulai'] as String? ?? '',
      tanggalSelesai: json['tanggalSelesai'] as String? ?? '',
      aktif: json['aktif'] as bool? ?? true,
      createdAt: json['createdAt'] as String?,
    );
  }

  Obat copyWith({
    String? id,
    String? nama,
    String? dosis,
    String? frekuensi,
    List<String>? waktuMinum,
    int? durasiHari,
    String? tanggalMulai,
    String? tanggalSelesai,
    bool? aktif,
  }) {
    return Obat(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      dosis: dosis ?? this.dosis,
      frekuensi: frekuensi ?? this.frekuensi,
      waktuMinum: waktuMinum ?? this.waktuMinum,
      durasiHari: durasiHari ?? this.durasiHari,
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
      tanggalSelesai: tanggalSelesai ?? this.tanggalSelesai,
      aktif: aktif ?? this.aktif,
      createdAt: createdAt,
    );
  }
}
