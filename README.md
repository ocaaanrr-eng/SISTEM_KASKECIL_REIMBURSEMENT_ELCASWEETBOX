# ELCA SWEETBOX

Aplikasi sederhana untuk mencatat kas kecil dan mengelola reimbursement karyawan pada usaha bakery ELCA SWEETBOX.

## Struktur folder

```text
SISTEM_ELCASWEETBOX/
├── frontend/
│   ├── index.html
│   ├── style.css
│   └── script.js
├── backend/
│   └── App.js
├── database/
│   └── database.sql
└── README.md
```

## Teknologi

- HTML, CSS, dan JavaScript murni
- Node.js built-in `http` untuk server lokal
- Supabase PostgreSQL
- SQL
- GitHub

Tidak ada `package.json` karena server menggunakan modul bawaan Node.js. Tidak ada `env.example` karena konfigurasi Supabase dimasukkan melalui halaman Pengaturan dan disimpan di browser.

## Menjalankan versi demo

1. Pastikan Node.js sudah terpasang.
2. Buka terminal di folder proyek.
3. Jalankan:

   ```bash
   node backend/App.js
   ```

4. Buka `http://localhost:3000`.

Tanpa koneksi Supabase, aplikasi otomatis memakai `localStorage` browser. Data demo dapat di-reset dari DevTools browser dengan menghapus key `elca-sweetbox-data`.

## Menghubungkan Supabase

1. Buat project baru di [Supabase](https://supabase.com/).
2. Buka **SQL Editor**.
3. Salin seluruh isi `database/database.sql`, lalu tekan **Run**.
4. Buka **Project Settings > API**.
5. Salin **Project URL** dan **anon public key**.
6. Di aplikasi, buka menu **Pengaturan Sederhana**.
7. Masukkan URL dan anon key, lalu tekan **Simpan koneksi**.

Gunakan hanya anon public key di frontend. Jangan pernah menaruh service role key di `script.js` atau membagikannya ke GitHub. Untuk pemakaian produksi, aktifkan RLS dan policy Supabase sesuai role pengguna.

## Cara menghubungkan project ke GitHub

```bash
git init
git add .
git commit -m "Buat sistem kas kecil ELCA SWEETBOX"
git branch -M main
git remote add origin https://github.com/USERNAME/NAMA-REPOSITORY.git
git push -u origin main
```

Ganti URL remote dengan repository GitHub milik Anda.

## Pengujian fitur

- **Dashboard:** pastikan saldo, pemasukan, pengeluaran, dan jumlah reimbursement berubah setelah transaksi dibuat.
- **Data Karyawan:** buka menu, tambah karyawan, lalu pastikan data masuk ke tabel.
- **Kategori Pengeluaran:** tambah kategori baru dan pastikan muncul sebagai kartu serta pilihan pada form.
- **Pengajuan Reimbursement:** isi semua kolom termasuk bukti pengeluaran. Pengajuan baru berstatus `Menunggu Verifikasi`.
- **Verifikasi:** pada menu Pengajuan, tekan `Verifikasi` untuk mengubah status menjadi `Menunggu Persetujuan`.
- **Persetujuan:** pada menu Persetujuan, tekan `Setujui` atau `Tolak`.
- **Pembayaran:** setelah disetujui, tekan `Bayar`. Sistem membuat data pembayaran dan transaksi pengeluaran kas kecil otomatis.
- **Kas Kecil:** catat pemasukan atau pengeluaran manual, lalu lihat saldo yang diperbarui.
- **Laporan:** lihat rincian per kategori dan gunakan tombol `Unduh CSV`.
- **Role tampilan:** gunakan dropdown di header untuk mencoba mode Admin, Manager, dan Karyawan. Ini adalah simulasi role tanpa login.

## Catatan implementasi

`frontend/script.js` pertama-tama mencoba membaca konfigurasi Supabase dari `localStorage`. Jika tersedia, operasi data menggunakan Supabase JavaScript client melalui CDN. Jika belum tersedia atau gagal tersambung, aplikasi menggunakan penyimpanan lokal agar tetap dapat dipelajari dan diuji tanpa backend tambahan.

`backend/App.js` hanya bertugas menyajikan file frontend. Seluruh logika bisnis versi sederhana berada di `script.js`, sedangkan struktur data resmi berada di SQL Supabase.
