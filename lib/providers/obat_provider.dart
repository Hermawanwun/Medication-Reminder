import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/obat.dart';
import '../models/riwayat.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';

class ObatProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  final NotificationService _notificationService;

  List<Obat> _daftarObat = [];
  StreamSubscription? _subscription;
  StreamSubscription? _authSubscription;
  bool _loading = false;
  String? _error;

  ObatProvider(this._firebaseService, this._notificationService) {
    _authSubscription = _firebaseService.userIdChanges.listen((_) {
      _subscription?.cancel();
      _daftarObat = [];
      _subscribe();
    });
    _subscribe();
  }

  List<Obat> get daftarObat => _daftarObat;
  bool get loading => _loading;
  String? get error => _error;

  List<Obat> get obatAktif {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _daftarObat
        .where((o) => o.aktif && o.tanggalSelesai.compareTo(today) >= 0)
        .toList();
  }

  void _subscribe() {
    _subscription = _firebaseService.streamObat().listen(
      (data) {
        _daftarObat = data;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (err) {
        _error = err.toString();
        _loading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> tambahObat(Obat obat) async {
    try {
      _loading = true;
      notifyListeners();

      final dateFormat = DateFormat('yyyy-MM-dd');
      final mulai = dateFormat.parse(obat.tanggalMulai);
      final selesai = mulai.add(Duration(days: obat.durasiHari - 1));
      obat.tanggalSelesai = dateFormat.format(selesai);

      await _firebaseService.simpanObat(obat);

      for (int i = 0; i < obat.waktuMinum.length; i++) {
        final waktu = obat.waktuMinum[i];
        final parts = waktu.split(':');
        final jam = int.parse(parts[0]);
        final menit = int.parse(parts[1]);

        await _notificationService.jadwalkanNotifikasi(
          id: '${obat.id}_$i',
          title: '💊 Pengingat Minum Obat',
          body: 'Waktunya minum ${obat.nama} ${obat.dosis}',
          jam: jam,
          menit: menit,
        );
      }

      await _generateRiwayat(obat);

      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> editObat(Obat obat) async {
    try {
      _loading = true;
      notifyListeners();

      final dateFormat = DateFormat('yyyy-MM-dd');
      final mulai = dateFormat.parse(obat.tanggalMulai);
      final selesai = mulai.add(Duration(days: obat.durasiHari - 1));
      obat.tanggalSelesai = dateFormat.format(selesai);

      await _firebaseService.updateObat(obat);

      for (int i = 0; i < obat.waktuMinum.length; i++) {
        final waktu = obat.waktuMinum[i];
        final parts = waktu.split(':');
        final jam = int.parse(parts[0]);
        final menit = int.parse(parts[1]);

        await _notificationService.cancelNotifikasi(
          int.parse('${obat.id}_$i'.replaceAll(RegExp(r'[^0-9]'), '')),
        );
        await _notificationService.jadwalkanNotifikasi(
          id: '${obat.id}_$i',
          title: '💊 Pengingat Minum Obat',
          body: 'Waktunya minum ${obat.nama} ${obat.dosis}',
          jam: jam,
          menit: menit,
        );
      }

      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> hapusObat(Obat obat) async {
    try {
      await _firebaseService.hapusRiwayatByObatId(obat.id);

      for (int i = 0; i < obat.waktuMinum.length; i++) {
        await _notificationService.cancelNotifikasi(
          int.parse('${obat.id}_$i'.replaceAll(RegExp(r'[^0-9]'), '')),
        );
      }

      await _firebaseService.hapusObat(obat.id);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> _generateRiwayat(Obat obat) async {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final mulai = dateFormat.parse(obat.tanggalMulai);
    final selesai = dateFormat.parse(obat.tanggalSelesai);

    var current = mulai;
    while (!current.isAfter(selesai)) {
      final tanggalStr = dateFormat.format(current);
      for (final waktu in obat.waktuMinum) {
        final riwayat = Riwayat(
          obatId: obat.id,
          namaObat: obat.nama,
          dosis: obat.dosis,
          tanggal: tanggalStr,
          waktu: waktu,
          status: 'pending',
        );
        await _firebaseService.simpanRiwayat(riwayat);
      }
      current = current.add(const Duration(days: 1));
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
