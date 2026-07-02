import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../models/obat.dart';
import '../models/riwayat.dart';

class FirebaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final _userIdController = StreamController<String?>.broadcast();
  String? _userId;

  String get _basePath => _userId != null ? 'users/$_userId' : '';

  Stream<String?> get userIdChanges => _userIdController.stream;

  set userId(String? uid) {
    _userId = uid;
    _userIdController.add(uid);
  }

  Future<void> init() async {
    if (_userId != null) {
      await _db.child('$_basePath/obat').keepSynced(true);
      await _db.child('$_basePath/riwayat').keepSynced(true);
    }
  }

  bool get _hasUser => _userId != null;

  Stream<List<Obat>> streamObat() {
    if (!_hasUser) return Stream.value([]);
    return _db.child('$_basePath/obat').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((e) {
        return Obat.fromJson(e.key, e.value as Map<dynamic, dynamic>);
      }).toList();
    });
  }

  Future<void> simpanObat(Obat obat) async {
    if (!_hasUser) return;
    final ref = _db.child('$_basePath/obat').push();
    obat.id = ref.key!;
    await ref.set(obat.toJson());
  }

  Future<void> updateObat(Obat obat) async {
    if (!_hasUser) return;
    await _db.child('$_basePath/obat/${obat.id}').update(obat.toJson());
  }

  Future<void> hapusObat(String id) async {
    if (!_hasUser) return;
    await _db.child('$_basePath/obat/$id').remove();
  }

  Stream<List<Riwayat>> streamRiwayat() {
    if (!_hasUser) return Stream.value([]);
    return _db.child('$_basePath/riwayat').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((e) {
        return Riwayat.fromJson(e.key, e.value as Map<dynamic, dynamic>);
      }).toList();
    });
  }

  Stream<List<Riwayat>> streamRiwayatByObatId(String obatId) {
    if (!_hasUser) return Stream.value([]);
    return _db
        .child('$_basePath/riwayat')
        .orderByChild('obatId')
        .equalTo(obatId)
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((e) {
        return Riwayat.fromJson(e.key, e.value as Map<dynamic, dynamic>);
      }).toList();
    });
  }

  Future<void> simpanRiwayat(Riwayat riwayat) async {
    if (!_hasUser) return;
    final ref = _db.child('$_basePath/riwayat').push();
    riwayat.id = ref.key!;
    await ref.set(riwayat.toJson());
  }

  Future<void> updateRiwayat(Riwayat riwayat) async {
    if (!_hasUser) return;
    await _db.child('$_basePath/riwayat/${riwayat.id}').update(riwayat.toJson());
  }

  Future<void> hapusRiwayat(String id) async {
    if (!_hasUser) return;
    await _db.child('$_basePath/riwayat/$id').remove();
  }

  Future<void> hapusRiwayatByObatId(String obatId) async {
    if (!_hasUser) return;
    final snapshot = await _db
        .child('$_basePath/riwayat')
        .orderByChild('obatId')
        .equalTo(obatId)
        .get();
    if (snapshot.value != null) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      for (final key in data.keys) {
        await _db.child('$_basePath/riwayat/$key').remove();
      }
    }
  }
}
