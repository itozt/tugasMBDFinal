# tugasMBDFinal

## Prosedur 1 : ProsesPermohonanSurat (A) 📫
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
    <img src="https://github.com/user-attachments/assets/44455b29-132a-436b-9f80-0eed35eda94d" width="300" height="200"><br>
    Sebelum : <br>
    <img src="https://github.com/user-attachments/assets/89920db8-4835-4a7a-99eb-9895df4e3269" height="70"> <br>
    Sesudah : <br>
    <img src="https://github.com/user-attachments/assets/1ab6890c-11ac-4914-8166-e9e7c8a85a45" height="70">


## Prosedur 2: UpdateStatusEkonomiPendudukOtomatis (B) 💸
- **Tujuan** : Mengotomatisasi pembaruan status_ekonomi setiap warga berdasarkan gaji dan jumlah anggota keluarga.
- **Query** : [Link Procedure 2](https://github.com/itozt/tugasMBDFinal/blob/main/procedure2.sql)
- **Input** : (Tidak ada, berjalan otomatis).
- **Alur** :
  0. Buat kolom atribut `status_ekonomi` di tabel warga.
  1. Iterasi Warga : Prosedur akan memproses setiap warga satu per satu.
  2. Ambil Data Relevan : Untuk setiap warga, ambil gaji_per_bulan dari pekerjaannya dan hitung jumlah_anggota_keluarga dari KK-nya.
  3. Hitung Pendapatan Per Kapita : Hitung gaji_per_bulan dibagi jumlah_anggota_keluarga.
  4. Tentukan Status Ekonomi : Bandingkan pendapatan_per_kapita dengan ambang batas yang telah ditentukan (misal: 500 ribu untuk 'Tidak Mampu', 1 juta untuk 'Rentan', dst.) untuk menentukan status_ekonomi yang sesuai.
  5. Perbarui Status (jika berubah) : Update kolom status_ekonomi di tabel warga jika ada perubahan dari nilai sebelumnya.
  6. Transaksi : Seluruh proses berjalan dalam satu transaksi otomatis; jika ada error, semua perubahan dibatalkan.
  7. Notifikasi : Berikan pesan keberhasilan atau error.
- **Contoh** :
  - Memulai proses analisis dan pembaruan status_ekonomi untuk seluruh data penduduk di database :
    ``` sql
    CALL UpdateStatusEkonomiPendudukOtomatis();
    ```
    Hasil : <br>
    Sebelum : <br>
    <img src="https://github.com/user-attachments/assets/a0f08407-5600-4044-8070-54b5fc6e6405" height="200"> <br>
    Sesudah : <br>
    <img src="https://github.com/user-attachments/assets/a19bf705-8dd4-4414-a388-859987d53eda" height="200">


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
