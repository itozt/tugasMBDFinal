CREATE OR REPLACE PROCEDURE UpdateStatusEkonomiPendudukOtomatis()
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
    v_gaji_per_bulan INT;
    v_jumlah_anggota_keluarga INT;
    v_pendapatan_per_kapita NUMERIC;
    v_new_status_ekonomi VARCHAR(20);

    -- Definisikan ambang batas ekonomi 
    THRESHOLD_TIDAK_MAMPU NUMERIC := 500000; -- Pendapatan per kapita di bawah 500ribu
    THRESHOLD_RENTAN NUMERIC := 1000000;      -- Pendapatan per kapita di bawah 1juta
    THRESHOLD_MENENGAH NUMERIC := 2500000;    -- Pendapatan per kapita di bawah 2.5juta
    -- Di atas THRESHOLD_MENENGAH bisa dianggap 'Mampu'
BEGIN
    RAISE NOTICE 'Memulai prosedur UpdateStatusEkonomiPendudukOtomatis...';

    -- Loop melalui setiap warga
    FOR r IN SELECT nik, keluarga_no_kk, pekerjaan_id_pekerjaan FROM warga LOOP
        -- 1. Ambil Gaji Per Bulan warga
        SELECT COALESCE(p.gaji_per_bulan, 0) INTO v_gaji_per_bulan
        FROM pekerjaan p
        WHERE p.id_pekerjaan = r.pekerjaan_id_pekerjaan;

        -- 2. Hitung Jumlah Anggota Keluarga untuk KK warga tersebut
        SELECT COUNT(w.nik) INTO v_jumlah_anggota_keluarga
        FROM warga w
        WHERE w.keluarga_no_kk = r.keluarga_no_kk;

        -- Pastikan jumlah anggota tidak nol untuk menghindari pembagian dengan nol
        IF v_jumlah_anggota_keluarga = 0 THEN
            v_pendapatan_per_kapita := 0;
        ELSE
            v_pendapatan_per_kapita := v_gaji_per_bulan / v_jumlah_anggota_keluarga;
        END IF;

        -- 3. Tentukan Status Ekonomi Baru berdasarkan ambang batas
        IF v_pendapatan_per_kapita <= THRESHOLD_TIDAK_MAMPU THEN
            v_new_status_ekonomi := 'Tidak Mampu';
        ELSIF v_pendapatan_per_kapita <= THRESHOLD_RENTAN THEN
            v_new_status_ekonomi := 'Rentan';
        ELSIF v_pendapatan_per_kapita <= THRESHOLD_MENENGAH THEN
            v_new_status_ekonomi := 'Menengah';
        ELSE
            v_new_status_ekonomi := 'Mampu';
        END IF;

        -- 4. Perbarui Status Ekonomi Warga
        UPDATE warga
        SET status_ekonomi = v_new_status_ekonomi
        WHERE nik = r.nik AND COALESCE(status_ekonomi, '') != v_new_status_ekonomi;

    END LOOP;

    RAISE NOTICE 'Proses pembaruan status ekonomi penduduk selesai.';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Transaksi dibatalkan karena kesalahan: %', SQLERRM;
END;
$$;
