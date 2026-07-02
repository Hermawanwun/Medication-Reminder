import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/obat.dart';
import '../providers/obat_provider.dart';

class TambahObatScreen extends StatefulWidget {
  const TambahObatScreen({super.key});

  @override
  State<TambahObatScreen> createState() => _TambahObatScreenState();
}

class _TambahObatScreenState extends State<TambahObatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _dosisController = TextEditingController();
  final _durasiController = TextEditingController();

  DateTime _tanggalMulai = DateTime.now();
  String _frekuensi = 'Setiap hari';
  final List<String> _waktuMinum = [];
  bool _loading = false;

  final List<String> _frekuensiOptions = [
    'Setiap hari',
    'Setiap 12 jam',
    'Setiap 8 jam',
    'Setiap 6 jam',
    'Sesuai jadwal',
  ];

  @override
  void dispose() {
    _namaController.dispose();
    _dosisController.dispose();
    _durasiController.dispose();
    super.dispose();
  }

  void _tambahWaktu() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      final jam = picked.hour.toString().padLeft(2, '0');
      final menit = picked.minute.toString().padLeft(2, '0');
      setState(() {
        _waktuMinum.add('$jam:$menit');
        _waktuMinum.sort();
      });
    }
  }

  void _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalMulai,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _tanggalMulai = picked;
      });
    }
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    if (_waktuMinum.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal 1 waktu minum')),
      );
      return;
    }

    setState(() => _loading = true);

    final dateFormat = DateFormat('yyyy-MM-dd');
    final obat = Obat(
      nama: _namaController.text.trim(),
      dosis: _dosisController.text.trim(),
      frekuensi: _frekuensi,
      waktuMinum: List.from(_waktuMinum),
      durasiHari: int.parse(_durasiController.text.trim()),
      tanggalMulai: dateFormat.format(_tanggalMulai),
    );

    final provider = context.read<ObatProvider>();
    final success = await provider.tambahObat(obat);

    if (!mounted) return;

    setState(() => _loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Obat berhasil ditambahkan')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Gagal menyimpan obat')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Obat'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            TextFormField(
              controller: _namaController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nama Obat',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medication),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nama obat wajib diisi' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _dosisController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Dosis (contoh: 500mg, 1 tablet)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.science),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Dosis wajib diisi' : null,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _frekuensi,
              decoration: const InputDecoration(
                labelText: 'Frekuensi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.repeat),
              ),
              items: _frekuensiOptions.map((f) {
                return DropdownMenuItem(value: f, child: Text(f));
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _frekuensi = v);
              },
            ),
            const SizedBox(height: 16),

            InkWell(
              onTap: _pilihTanggal,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Tanggal Mulai',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(DateFormat('dd/MM/yyyy').format(_tanggalMulai)),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _durasiController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Durasi (hari)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Durasi wajib diisi';
                final n = int.tryParse(v);
                if (n == null || n < 1) return 'Masukkan angka minimal 1';
                return null;
              },
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Waktu Minum',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _tambahWaktu,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Waktu'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_waktuMinum.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Belum ada waktu minum',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              ..._waktuMinum.asMap().entries.map((entry) {
                final i = entry.key;
                final waktu = entry.value;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(waktu),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        setState(() => _waktuMinum.removeAt(i));
                      },
                    ),
                  ),
                );
              }),

            const SizedBox(height: 32),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _simpan,
                child: _loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
