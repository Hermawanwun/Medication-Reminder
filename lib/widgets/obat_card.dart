import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/obat.dart';

class ObatCard extends StatelessWidget {
  final Obat obat;
  final VoidCallback onTap;
  final VoidCallback onHapus;

  const ObatCard({
    super.key,
    required this.obat,
    required this.onTap,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final selesai = DateTime.now().isAfter(
      DateFormat('yyyy-MM-dd').parse(obat.tanggalSelesai),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor:
              selesai ? Colors.grey[300] : Colors.blue[100],
          child: Icon(
            Icons.medication,
            color: selesai ? Colors.grey : Colors.blue[700],
          ),
        ),
        title: Text(
          obat.nama,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selesai ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${obat.dosis} - ${obat.frekuensi}'),
            Text(
              '${dateFormat.format(DateFormat('yyyy-MM-dd').parse(obat.tanggalMulai))} - '
              '${dateFormat.format(DateFormat('yyyy-MM-dd').parse(obat.tanggalSelesai))}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            Text(
              obat.waktuMinum.join(', '),
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onHapus,
        ),
      ),
    );
  }
}
