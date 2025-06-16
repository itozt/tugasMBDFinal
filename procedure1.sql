CREATE OR REPLACE PROCEDURE ProsesPermohonanSurat(
    p_id_permohonan VARCHAR(16),
    p_status_baru VARCHAR(20),
    p_id_staff VARCHAR(16),
    p_catatan_respon TEXT,
    p_url_file_surat TEXT DEFAULT NULL 
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_status VARCHAR(20);
    v_new_respon_id VARCHAR(16);
    v_next_surat_num INT;
BEGIN
    -- 1. Validasi Input Awal dan Keberadaan Data
    SELECT status INTO v_current_status
    FROM permohonan_surat
    WHERE id_permohonan = p_id_permohonan;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Error: Permohonan dengan ID % tidak ditemukan.', p_id_permohonan;
    END IF;

    IF p_status_baru NOT IN ('Diproses', 'Selesai', 'Ditolak') THEN
        RAISE EXCEPTION 'Error: Status baru "%" tidak valid. Status yang diizinkan: Diproses, Selesai, Ditolak.', p_status_baru;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM staff WHERE id_staff = p_id_staff) THEN
        RAISE EXCEPTION 'Error: Staff dengan ID % tidak ditemukan.', p_id_staff;
    END IF;

    -- 2. Perbarui Status Permohonan
    UPDATE permohonan_surat
    SET status = p_status_baru
    WHERE id_permohonan = p_id_permohonan;

    -- 3. Generate ID Respon Baru
    -- Menggunakan kombinasi 'RSPNP' + 6 digit angka random + 5 karakter MD5 untuk simulasi unik ID
    SELECT 'RSPNP' || LPAD(FLOOR(RANDOM() * 999999)::TEXT, 6, '0') || SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 5)
    INTO v_new_respon_id;

    -- 4. Catat Respons Permohonan (Ini harus dilakukan pertama agar ID respon_permohonan tersedia untuk tabel surat)
    INSERT INTO respon_permohonan (id_respon, tanggal_respon, status, catatan, permohonan_surat_id_permohonan, staff_id_staff)
    VALUES (
        v_new_respon_id,
        CURRENT_DATE,
        p_status_baru,
        p_catatan_respon,
        p_id_permohonan,
        p_id_staff
    );

    -- 5. Kondisional: Jika Status Baru Adalah 'Selesai', maka buat entri surat
    IF p_status_baru = 'Selesai' THEN
        -- Generate Nomor Surat Otomatis (contoh: SRT/YYYY/MM/NomorUrut)
        -- Mencari nomor urut terakhir untuk bulan dan tahun ini
        SELECT COALESCE(MAX(SUBSTRING(nomor_surat FROM '[0-9]+')::INT), 0) + 1
        INTO v_next_surat_num
        FROM surat
        WHERE nomor_surat LIKE 'SRT/' || TO_CHAR(CURRENT_DATE, 'YYYY/MM') || '%';

        -- Insert ke tabel surat, merujuk id_respon yang baru saja dibuat
        INSERT INTO surat (
            id_surat,
            nomor_surat,
            tanggal_cetak,
            url_file,
            respon_permohonan_id_respon -- Kolom FK di tabel surat
        )
        VALUES (
            'SRT' || LPAD(FLOOR(RANDOM() * 99999999)::TEXT, 8, '0') || SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 5), -- ID Surat
            'SRT/' || TO_CHAR(CURRENT_DATE, 'YYYY/MM') || '/' || LPAD(v_next_surat_num::TEXT, 5, '0'), -- Nomor Surat
            CURRENT_DATE,
            p_url_file_surat,
            v_new_respon_id -- Merujuk ID respon yang baru dibuat
        );
    END IF;

    RAISE NOTICE 'Proses permohonan surat % berhasil diubah menjadi status "%". Respons dicatat.', p_id_permohonan, p_status_baru;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Transaksi dibatalkan karena kesalahan: %', SQLERRM;
END;
$$;
