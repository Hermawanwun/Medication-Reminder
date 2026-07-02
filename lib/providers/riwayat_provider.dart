import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/riwayat.dart';
import '../services/firebase_service.dart';

class RiwayatProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;

  List<Riwayat> _daftarRiwayat = [];
  StreamSubscription? _subscription;
  bool _loading = false;
  String? _error;

  RiwayatProvider(this._firebaseService) {
    _subscribe();
  }

  List<Riwayat> get daftarRiwayat => _daftarRiwayat;
  bool get loading => _loading;
  String? get error => _error;

  List<Riwayat> get riwayatHariIni {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _daftarRiwayat
        .where((r) => r.tanggal == today)
        .toList()
      ..sort((a, b) => a.waktu.compareTo(b.waktu));
  }

  List<Riwayat> get jadwalPendingHariIni {
    return riwayatHariIni.where((r) => r.status == 'pending').toList();
  }

  List<Riwayat> get riwayatSelesai {
    return _daftarRiwayat.where((r) => r.status == 'diminum').toList()
      ..sort((a, b) {
        final aDate = '${a.tanggal} ${a.waktu}';
        final bDate = '${b.tanggal} ${b.waktu}';
        return bDate.compareTo(aDate);
      });
  }

  List<Riwayat> get riwayatTerlewat {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final currentTime = DateFormat('HH:mm').format(now);

    return _daftarRiwayat.where((r) {
      if (r.tanggal == today && r.status == 'pending') {
        return r.waktu.compareTo(currentTime) < 0;
      }
      if (r.tanggal.compareTo(today) < 0 && r.status == 'pending') {
        return true;
      }
      return false;
    }).toList();
  }

  List<Riwayat> get semuaRiwayatTerurut {
    final sorted = List<Riwayat>.from(_daftarRiwayat);
    sorted.sort((a, b) {
      final aDate = '${b.tanggal} ${b.waktu}';
      final bDate = '${a.tanggal} ${a.waktu}';
      return aDate.compareTo(bDate);
    });
    return sorted;
  }

  void _subscribe() {
    _subscription = _firebaseService.streamRiwayat().listen(
      (data) {
        _daftarRiwayat = data;
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

  Future<bool> tandaiDiminum(Riwayat riwayat) async {
    try {
      final updated = riwayat.copyWith(
        status: 'diminum',
        diminumPada: DateFormat('HH:mm').format(DateTime.now()),
      );
      await _firebaseService.updateRiwayat(updated);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> tandaiTerlewat(Riwayat riwayat) async {
    try {
      final updated = riwayat.copyWith(status: 'terlewat');
      await _firebaseService.updateRiwayat(updated);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
