import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/riwayat_provider.dart';

class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RiwayatProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Minum Obat'),
      ),
      body: provider.loading && provider.daftarRiwayat.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.daftarRiwayat.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada riwayat',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                )
              : _buildRiwayatList(context, provider),
    );
  }

  Widget _buildRiwayatList(BuildContext context, RiwayatProvider provider) {
    final riwayat = provider.semuaRiwayatTerurut;
    final grouped = <String, List<dynamic>>{};

    for (final r in riwayat) {
      grouped.putIfAbsent(r.tanggal, () => []).add(r);
    }

    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildRingkasan(provider),
        const SizedBox(height: 16),
        ...sortedDates.map((tanggal) {
          final items = grouped[tanggal]!;
          final dateStr = _formatTanggal(tanggal);
          final selesai = items.where((r) => r.status == 'diminum').length;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              title: Text(dateStr),
              subtitle: Text(
                '$selesai/${items.length} diminum',
                style: TextStyle(color: Colors.grey[600]),
              ),
              leading: Icon(
                selesai == items.length ? Icons.check_circle : Icons.pending,
                color: selesai == items.length ? Colors.green : Colors.orange,
              ),
              children: items.map<Widget>((r) {
                return ListTile(
                  leading: _statusIcon(r.status),
                  title: Text('${r.namaObat} ${r.dosis}'),
                  subtitle: Text('${r.waktu} ${_statusText(r.status)}'),
                  dense: true,
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRingkasan(RiwayatProvider provider) {
    final totalDiminum = provider.riwayatSelesai.length;
    final totalTerlewat = provider.riwayatTerlewat.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem(Icons.check_circle, Colors.green, 'Diminum', totalDiminum),
            Container(height: 40, width: 1, color: Colors.grey[300]),
            _statItem(Icons.warning, Colors.red, 'Terlewat', totalTerlewat),
            Container(height: 40, width: 1, color: Colors.grey[300]),
            _statItem(Icons.pending, Colors.orange, 'Pending',
                provider.jadwalPendingHariIni.length),
          ],
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, Color color, String label, int count) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _statusIcon(String status) {
    switch (status) {
      case 'diminum':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'terlewat':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.schedule, color: Colors.orange);
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'diminum':
        return '✓ Diminum';
      case 'terlewat':
        return '✗ Terlewat';
      default:
        return '⏳ Menunggu';
    }
  }

  String _formatTanggal(String tanggal) {
    try {
      final date = DateFormat('yyyy-MM-dd').parse(tanggal);
      final today = DateTime.now();
      final diff = date.difference(today).inDays;

      if (diff == 0) return 'Hari Ini - $tanggal';
      if (diff == -1) return 'Kemarin - $tanggal';
      return DateFormat('EEEE, dd MMM yyyy', 'id').format(date);
    } catch (_) {
      return tanggal;
    }
  }
}
