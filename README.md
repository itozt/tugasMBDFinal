# tugasMBDFinal

## Prosedur 1 : ProsesPermohonanSurat 📫
- **Tujuan** : Memproses permohonan surat warga.
- **Query** : [Link Procedure 1](https://github.com/itozt/tugasMBDFinal/blob/main/procedure1.sql)
- **Input** : `ID_Permohonan, Status_Baru ('Diproses'/'Selesai'/'Ditolak'), ID_Staff, Catatan_Respon, URL_File_Surat`.
- **Alur** :
  1. Validasi: Periksa keberadaan ID_Permohonan dan ID_Staff di database, serta validasi Status_Baru. Jika tidak valid, hentikan dan berikan error.
  2. Mulai Transaksi: Pastikan semua operasi selanjutnya bersifat atomik (berhasil semua atau gagal semua).
  3. Update Status Permohonan: Ubah kolom status di tabel permohonan_surat sesuai Status_Baru.
  4. Catat Respons: Buat entri baru di tabel respon_permohonan. Ini adalah langkah krusial karena id_respon yang baru dibuat akan digunakan jika surat perlu dicetak.
  5. Cetak Surat (Kondisional):
     - Jika Status_Baru = 'Selesai':
       - Generate Nomor_Surat yang unik.
       - Buat entri baru di tabel surat, mengisi respon_permohonan_id_respon dengan id_respon yang baru saja dibuat di langkah sebelumnya.
  6. Selesai Transaksi: Komit transaksi jika berhasil, atau rollback otomatis jika ada kesalahan.
  7. Pesan Notifikasi: Berikan pesan sukses atau error ke pengguna.
- **Contoh** :
  - Memproses permohonan dari **'menunggu'** menjadi **'Diproses'** : <br>
    ``` sql
    CALL ProsesPermohonanSurat('PRMHN000006KDLWI', 'Diproses', 'STAFF23YLQSFBKJJ', 'Permohonan diterima, sedang verifikasi dokumen.', NULL);
    ```
    Hasil : <br>
    <img src="https://github.com/user-attachments/assets/44455b29-132a-436b-9f80-0eed35eda94d" width="300" height="200">
    <img src="https://github.com/user-attachments/assets/1ab6890c-11ac-4914-8166-e9e7c8a85a45" height="70">


## Prosedur 2: UpdateStatusEkonomiPendudukOtomatis (Manajemen Pendataan Penduduk - B)
- Tujuan : Mengotomatisasi pembaruan status ekonomi warga.
- Input : (Tidak ada, berjalan otomatis atau dipicu).
- Alur :
  1. `START TRANSACTION`.
  2. Iterasi setiap warga:
     - Ambil `gaji_per_bulan` (dari tabel `pekerjaan`) dan hitung `jumlah_anggota_keluarga`.
     - Hitung pendapatan per kapita keluarga.
     - Tentukan `status_ekonomi` (misal: `'Tidak Mampu', 'Menengah', 'Mampu'`) berdasarkan ambang batas.
     - Perbarui `status_ekonomi` warga di tabel warga.
  3. `COMMIT/ROLLBACK` transaksi.

## Prosedur 3: TanggapiDanPerbaruiStatusPengaduan (Pengaduan Masyarakat - E)
- Tujuan: Memberikan tanggapan dan memperbarui status pengaduan.
- Input: `ID Pengaduan, Isi Tanggapan, ID Staff, Status Baru`.
- Alur:
  1. Validasi input dan keberadaan data terkait.
  2. `START TRANSACTION`.
  3. Rekam tanggapan baru di `tanggapan_pengaduan`.
  4. Perbarui status di pengaduan.
  5. `COMMIT/ROLLBACK` transaksi.
  6. Berikan pesan hasil.
