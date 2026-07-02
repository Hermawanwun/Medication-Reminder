import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/obat_provider.dart';
import '../providers/riwayat_provider.dart';
import '../widgets/obat_card.dart';
import '../widgets/jadwal_today_card.dart';
import 'tambah_obat_screen.dart';
import 'edit_obat_screen.dart';
import 'riwayat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final obatProvider = context.watch<ObatProvider>();
    final riwayatProvider = context.watch<RiwayatProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('💊 Pengingat Obat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RiwayatScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahObatScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          obatProvider.clearError();
          riwayatProvider.clearError();
        },
        child: _buildBody(context, obatProvider, riwayatProvider),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ObatProvider obatProvider,
    RiwayatProvider riwayatProvider,
  ) {
    if (obatProvider.loading && obatProvider.daftarObat.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (obatProvider.error != null && obatProvider.daftarObat.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Terjadi kesalahan', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(obatProvider.error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => obatProvider.clearError(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    final obatAktif = obatProvider.obatAktif;
    final jadwalHariIni = riwayatProvider.riwayatHariIni;
    final terlewat = riwayatProvider.riwayatTerlewat;

    if (obatAktif.isEmpty && jadwalHariIni.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          Center(
            child: Column(
              children: [
                Icon(Icons.medication, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Belum ada obat',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tekan tombol + untuk menambahkan obat',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (terlewat.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${terlewat.length} jadwal terlewat',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

        Text(
          'Jadwal Hari Ini',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        if (jadwalHariIni.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Tidak ada jadwal minum obat hari ini',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          ...jadwalHariIni.map((jadwal) {
            final sudahTerlewat = terlewat.any((t) => t.id == jadwal.id);
            return JadwalTodayCard(
              riwayat: jadwal,
              sudahTerlewat: sudahTerlewat,
              onTandaiDiminum: () {
                riwayatProvider.tandaiDiminum(jadwal);
              },
              onTandaiTerlewat: () {
                riwayatProvider.tandaiTerlewat(jadwal);
              },
            );
          }),

        const SizedBox(height: 24),
        Text(
          'Daftar Obat',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        if (obatAktif.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Belum ada obat aktif',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          ...obatAktif.map((obat) {
            return ObatCard(
              obat: obat,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditObatScreen(obat: obat),
                  ),
                );
              },
              onHapus: () => _konfirmasiHapus(context, obatProvider, obat),
            );
          }),
      ],
    );
  }

  void _konfirmasiHapus(
    BuildContext context,
    ObatProvider provider,
    obat,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Obat'),
        content: Text('Yakin ingin menghapus ${obat.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              provider.hapusObat(obat);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${obat.nama} berhasil dihapus')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
