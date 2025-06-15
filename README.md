# tugasMBDFinal

## Prosedur 1: ProsesPermohonanSurat (Manajemen Pelayanan Warga - A)
- Tujuan : Memproses permohonan surat warga.
- Input : `ID Permohonan, Status Baru, ID Staff, Catatan, URL File Surat` (opsional).
- Alur :
  1. Validasi input dan keberadaan data terkait.
  2. `START TRANSACTION`.
  3. Perbarui status di permohonan_surat.
  4. Rekam respons baru di respon_permohonan.
  5. JIKA Status Baru adalah `'Selesai'`:
     - Buat entri baru di tabel surat (dengan nomor & tanggal otomatis, URL).
     - Perbarui entri respons yang tadi dibuat dengan ID surat ini.
  6. `COMMIT/ROLLBACK` transaksi.
  7. Berikan pesan hasil.
     
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
