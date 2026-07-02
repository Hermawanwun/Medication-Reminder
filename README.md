# PRD: Medication Reminder App

## 1. Ringkasan Produk

**Nama Produk:** Medication Reminder
**Platform:** Flutter (Android & WEB)
**Backend:** Firebase (Authentication + Realtime Database)

**Tujuan:** Membantu pengguna mengingat jadwal minum obat secara konsisten, mencatat riwayat konsumsi, dan (opsional) memungkinkan keluarga/pengasuh memantau kepatuhan pengguna.

**Target Pengguna:** Individu yang rutin mengonsumsi obat (lansia, pasien penyakit kronis) serta keluarga/pengasuh yang membantu memantau.

---

## 2. Tujuan & Metrik Sukses

| Tujuan | Metrik |
|---|---|
| Pengguna tidak lupa minum obat | % reminder yang direspons (diklik "sudah minum") |
| Kemudahan pencatatan obat baru | Waktu rata-rata untuk menambah 1 jadwal obat |
| Retensi penggunaan aplikasi | Jumlah pengguna aktif harian/mingguan |

---

## 3. Ruang Lingkup (Scope)

### In-Scope (MVP)
- Registrasi & login pengguna
- CRUD data obat (nama, dosis, jadwal, catatan)
- Notifikasi pengingat sesuai jadwal
- Tandai obat sebagai "sudah diminum" / "dilewati"
- Riwayat konsumsi obat (log harian)
- Sinkronisasi data real-time antar perangkat via Firebase Realtime Database

### Out-of-Scope (Fase Berikutnya)
- Fitur berbagi data dengan keluarga/pengasuh (multi-user monitoring)
- Integrasi dengan apotek/resep digital
- Analitik kepatuhan minum obat berbasis grafik lanjutan
- Mode offline penuh dengan konflik-resolusi kompleks

---

## 4. User Roles

1. **User (Pengguna Utama)** — mengelola obat pribadi, menerima reminder.
2. *(Opsional fase 2)* **Caregiver** — memantau kepatuhan user lain yang terhubung.

---

## 5. Fitur Utama & Alur Tingkat Tinggi

### 5.1 Autentikasi
- Login/Register menggunakan Firebase Authentication (Email/Password, opsional Google Sign-In).
- Halaman lupa password.
- Sesi login tetap tersimpan (auto-login) selama token valid.

### 5.2 Manajemen Data Obat
- Tambah obat baru: nama, dosis, bentuk (tablet/sirup/dll), waktu konsumsi, frekuensi (harian/mingguan/kondisional), durasi pengobatan.
- Edit & hapus data obat.
- Daftar semua obat aktif dalam satu halaman utama (Home/Dashboard).

### 5.3 Reminder / Notifikasi
- Sistem menjadwalkan notifikasi lokal berdasarkan jadwal obat yang tersimpan.
- Saat notifikasi muncul, user dapat memilih: "Sudah Minum", "Lewati", atau "Tunda (snooze)".
- Setiap aksi tercatat ke riwayat.

### 5.4 Riwayat & Kepatuhan
- Halaman riwayat menampilkan log konsumsi obat per hari/minggu.
- Indikator sederhana status kepatuhan (misal: dilakukan vs dilewati).

### 5.5 Profil Pengguna
- Lihat & edit data profil dasar (nama, foto opsional).
- Logout.

---

## 6. Arsitektur Data (High-Level)

Gunakan **Firebase Realtime Database** sebagai jembatan sinkronisasi data antara perangkat dan sebagai sumber data utama aplikasi. Struktur data disusun per-user (menggunakan UID dari Firebase Authentication) agar data setiap pengguna terisolasi.

Gambaran umum struktur (tidak perlu detail skema penuh, cukup jadi acuan):
- Data pengguna → identitas dasar & preferensi.
- Data obat → daftar obat milik masing-masing user, terhubung dengan UID.
- Data log konsumsi → riwayat aksi per obat per waktu, juga terhubung dengan UID.

Prinsip:
- Semua akses baca/tulis harus melalui UID pengguna yang sedang login (gunakan Firebase Security Rules agar user hanya bisa akses datanya sendiri).
- Gunakan pendekatan real-time listener agar perubahan data (tambah/edit/hapus obat) langsung tercermin di UI tanpa perlu refresh manual.

---

## 7. Kebutuhan Non-Fungsional

- **Keamanan:** Firebase Security Rules wajib membatasi akses data hanya untuk pemilik data (berdasarkan UID).
- **Reliabilitas Notifikasi:** Reminder harus tetap muncul meskipun aplikasi di-background atau ditutup (gunakan local notification scheduler, bukan bergantung penuh pada koneksi internet).
- **Performa:** Daftar obat dan riwayat harus tetap responsif meski data bertambah banyak.
- **Usability:** UI sederhana, ramah untuk pengguna lansia (ukuran teks cukup besar, alur minim langkah).

---

## 8. Alur Pengguna Utama (User Flow Ringkas)

1. User membuka app → login/register.
2. User menambahkan obat baru beserta jadwalnya.
3. Sistem menjadwalkan notifikasi otomatis sesuai jadwal.
4. Saat waktunya tiba, notifikasi muncul → user menandai status.
5. Data status tersimpan ke riwayat & tersinkron ke Realtime Database.
6. User dapat meninjau riwayat kapan saja dari menu riwayat.

---

## 9. Tech Stack Rekomendasi

- **Frontend:** Flutter (state management bebas dipilih tim, misal Provider/Riverpod/Bloc — pilih yang paling familiar agar development cepat).
- **Backend/Data:** Firebase Realtime Database.
- **Auth:** Firebase Authentication.
- **Notifikasi Lokal:** package notifikasi lokal Flutter (untuk penjadwalan reminder di perangkat).

---

## 10. Milestone Pengembangan (High-Level)

| Fase | Deliverable |
|---|---|
| 1 | Setup project Flutter + Firebase (Auth & Realtime DB) |
| 2 | Fitur login/register & struktur navigasi dasar |
| 3 | CRUD data obat + sinkronisasi ke Realtime Database |
| 4 | Sistem notifikasi & penandaan status konsumsi |
| 5 | Halaman riwayat & profil |
| 6 | Testing, perbaikan UX, dan polish UI |

---

## 11. Catatan untuk Tim Implementasi

Dokumen ini bersifat high-level. Detail teknis seperti struktur JSON pasti, nama field, desain UI pixel-perfect, dan pemilihan package spesifik diserahkan ke tim/model AI yang mengimplementasikan, selama tetap mengacu pada prinsip dan alur yang dijelaskan di atas.