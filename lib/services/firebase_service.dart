import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../models/obat.dart';
import '../models/riwayat.dart';

class FirebaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<void> init() async {
    await _db.child('obat').keepSynced(true);
    await _db.child('riwayat').keepSynced(true);
  }

  Stream<List<Obat>> streamObat() {
    return _db.child('obat').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((e) {
        return Obat.fromJson(e.key, e.value as Map<dynamic, dynamic>);
      }).toList();
    });
  }

  Future<void> simpanObat(Obat obat) async {
    final ref = _db.child('obat').push();
    obat.id = ref.key!;
    await ref.set(obat.toJson());
  }

  Future<void> updateObat(Obat obat) async {
    await _db.child('obat/${obat.id}').update(obat.toJson());
  }

  Future<void> hapusObat(String id) async {
    await _db.child('obat/$id').remove();
  }

  Stream<List<Riwayat>> streamRiwayat() {
    return _db.child('riwayat').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((e) {
        return Riwayat.fromJson(e.key, e.value as Map<dynamic, dynamic>);
      }).toList();
    });
  }

  Stream<List<Riwayat>> streamRiwayatByObatId(String obatId) {
    return _db
        .child('riwayat')
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
    final ref = _db.child('riwayat').push();
    riwayat.id = ref.key!;
    await ref.set(riwayat.toJson());
  }

  Future<void> updateRiwayat(Riwayat riwayat) async {
    await _db.child('riwayat/${riwayat.id}').update(riwayat.toJson());
  }

  Future<void> hapusRiwayatByObatId(String obatId) async {
    final snapshot = await _db
        .child('riwayat')
        .orderByChild('obatId')
        .equalTo(obatId)
        .get();
    if (snapshot.value != null) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      for (final key in data.keys) {
        await _db.child('riwayat/$key').remove();
      }
    }
  }
}
