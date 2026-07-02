import 'package:flutter/material.dart';
import '../models/riwayat.dart';

class JadwalTodayCard extends StatelessWidget {
  final Riwayat riwayat;
  final bool sudahTerlewat;
  final VoidCallback onTandaiDiminum;
  final VoidCallback onTandaiTerlewat;

  const JadwalTodayCard({
    super.key,
    required this.riwayat,
    required this.sudahTerlewat,
    required this.onTandaiDiminum,
    required this.onTandaiTerlewat,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = riwayat.status == 'pending';

    Color bgColor;
    IconData icon;
    Color iconColor;

    switch (riwayat.status) {
      case 'diminum':
        bgColor = Colors.green[50]!;
        icon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case 'terlewat':
        bgColor = Colors.red[50]!;
        icon = Icons.cancel;
        iconColor = Colors.red;
        break;
      default:
        if (sudahTerlewat) {
          bgColor = Colors.orange[50]!;
          icon = Icons.warning_amber_rounded;
          iconColor = Colors.orange;
        } else {
          bgColor = Colors.blue[50]!;
          icon = Icons.schedule;
          iconColor = Colors.blue;
        }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: bgColor,
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 32),
        title: Text(
          '${riwayat.namaObat} ${riwayat.dosis}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(riwayat.waktu),
        trailing: isPending
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    tooltip: 'Tandai diminum',
                    onPressed: onTandaiDiminum,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    tooltip: 'Tandai terlewat',
                    onPressed: onTandaiTerlewat,
                  ),
                ],
              )
            : Text(
                riwayat.status == 'diminum' ? 'Diminum' : 'Terlewat',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: riwayat.status == 'diminum'
                      ? Colors.green[700]
                      : Colors.red[700],
                ),
              ),
      ),
    );
  }
}
