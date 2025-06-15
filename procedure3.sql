CREATE OR REPLACE PROCEDURE TanggapiDanPerbaruiStatusPengaduan(
    p_id_pengaduan VARCHAR(16),
    p_isi_tanggapan TEXT,
    p_id_staff VARCHAR(16),
    p_status_baru VARCHAR(20) -- 'Diproses' atau 'Selesai'
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_status VARCHAR(20);
    v_new_tanggapan_id VARCHAR(16);
BEGIN
    -- 1. Validasi Input Awal dan Keberadaan Data
    SELECT status INTO v_current_status
    FROM pengaduan
    WHERE id_pengaduan = p_id_pengaduan;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Error: Pengaduan dengan ID % tidak ditemukan.', p_id_pengaduan;
    END IF;

    IF p_status_baru NOT IN ('Diproses', 'Selesai') THEN
        RAISE EXCEPTION 'Error: Status baru "%" tidak valid. Status yang diizinkan: Diproses, Selesai.', p_status_baru;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM staff WHERE id_staff = p_id_staff) THEN
        RAISE EXCEPTION 'Error: Staff dengan ID % tidak ditemukan.', p_id_staff;
    END IF;

    -- 2. Mulai Transaksi (ditangani otomatis oleh PL/pgSQL)

    -- 3. Generate ID Tanggapan Baru
    -- Menggunakan kombinasi 'TNGPN' + 6 digit angka random + 5 karakter MD5 untuk simulasi unik ID
    SELECT 'TNGPN' || LPAD(FLOOR(RANDOM() * 999999)::TEXT, 6, '0') || SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 5)
    INTO v_new_tanggapan_id;

    -- 4. Catat Tanggapan Pengaduan
    INSERT INTO tanggapan_pengaduan (id_tanggapan, tanggal_tanggapan, isi_tanggapan, pengaduan_id_pengaduan, staff_id_staff)
    VALUES (
        v_new_tanggapan_id,
        CURRENT_DATE,
        p_isi_tanggapan,
        p_id_pengaduan,
        p_id_staff
    );

    -- 5. Perbarui Status Pengaduan
    UPDATE pengaduan
    SET status = p_status_baru
    WHERE id_pengaduan = p_id_pengaduan;

    RAISE NOTICE 'Pengaduan % berhasil ditanggapi dan status diubah menjadi "%".', p_id_pengaduan, p_status_baru;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Transaksi dibatalkan karena kesalahan: %', SQLERRM;
END;
$$;
