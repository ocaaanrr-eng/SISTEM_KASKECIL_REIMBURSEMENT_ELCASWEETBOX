-- Database ELCA SWEETBOX untuk Supabase PostgreSQL
-- Jalankan seluruh file ini di SQL Editor Supabase.

create extension if not exists pgcrypto;

drop view if exists v_saldo_kas_kecil;
drop table if exists kas_kecil, pembayaran, approval, reimbursement, kategori_pengeluaran, karyawan, users cascade;

create table users (
  id_user uuid primary key default gen_random_uuid(),
  nama_user varchar(100) not null,
  email varchar(150) not null unique,
  password varchar(255),
  role varchar(20) not null check (role in ('Karyawan', 'Admin', 'Manager')),
  created_at timestamptz not null default now()
);

create table karyawan (
  id_karyawan uuid primary key default gen_random_uuid(),
  id_user uuid references users(id_user) on delete set null,
  kode_karyawan varchar(20) not null unique,
  nama_karyawan varchar(100) not null,
  jabatan varchar(80) not null,
  nomor_telepon varchar(30) not null,
  status_karyawan varchar(20) not null default 'Aktif' check (status_karyawan in ('Aktif', 'Nonaktif'))
);

create table kategori_pengeluaran (
  id_kategori uuid primary key default gen_random_uuid(),
  nama_kategori varchar(80) not null unique,
  keterangan text
);

create table reimbursement (
  id_reimbursement uuid primary key default gen_random_uuid(),
  id_karyawan uuid not null references karyawan(id_karyawan),
  id_kategori uuid not null references kategori_pengeluaran(id_kategori),
  tanggal_pengajuan date not null default current_date,
  tanggal_pengeluaran date not null,
  uraian_pengeluaran text not null,
  jumlah numeric(14,2) not null check (jumlah > 0),
  bukti_pengeluaran text not null,
  status varchar(30) not null default 'Menunggu Verifikasi' check (status in ('Menunggu Verifikasi', 'Ditolak', 'Menunggu Persetujuan', 'Disetujui', 'Sudah Dibayar'))
);

create table approval (
  id_approval uuid primary key default gen_random_uuid(),
  id_reimbursement uuid not null references reimbursement(id_reimbursement) on delete cascade,
  id_user uuid references users(id_user),
  keputusan varchar(15) not null check (keputusan in ('Disetujui', 'Ditolak')),
  catatan text,
  tanggal_approval timestamptz not null default now()
);

create table pembayaran (
  id_pembayaran uuid primary key default gen_random_uuid(),
  id_reimbursement uuid not null unique references reimbursement(id_reimbursement),
  id_user uuid references users(id_user),
  tanggal_pembayaran date not null default current_date,
  jumlah_dibayar numeric(14,2) not null check (jumlah_dibayar > 0),
  metode_pembayaran varchar(15) not null check (metode_pembayaran in ('Tunai', 'Transfer')),
  keterangan text
);

create table kas_kecil (
  id_kas uuid primary key default gen_random_uuid(),
  id_kategori uuid not null references kategori_pengeluaran(id_kategori),
  id_reimbursement uuid references reimbursement(id_reimbursement) on delete set null,
  id_user uuid references users(id_user),
  tanggal_transaksi date not null default current_date,
  jenis_transaksi varchar(15) not null check (jenis_transaksi in ('Pemasukan', 'Pengeluaran')),
  uraian text not null,
  jumlah numeric(14,2) not null check (jumlah > 0)
);

create index idx_reimbursement_status on reimbursement(status);
create index idx_kas_tanggal on kas_kecil(tanggal_transaksi desc);

create view v_saldo_kas_kecil as
select
  coalesce(sum(case when jenis_transaksi = 'Pemasukan' then jumlah else 0 end), 0) as total_pemasukan,
  coalesce(sum(case when jenis_transaksi = 'Pengeluaran' then jumlah else 0 end), 0) as total_pengeluaran,
  coalesce(sum(case when jenis_transaksi = 'Pemasukan' then jumlah else -jumlah end), 0) as saldo
from kas_kecil;

-- Data awal untuk demonstrasi.
insert into users (nama_user, email, role) values
  ('Admin ELCA', 'admin@elcasweetbox.id', 'Admin'),
  ('Maya Pratama', 'maya@elcasweetbox.id', 'Manager'),
  ('Rani Amalia', 'rani@elcasweetbox.id', 'Karyawan');

insert into karyawan (kode_karyawan, nama_karyawan, jabatan, nomor_telepon, status_karyawan)
values ('ELC-001', 'Rani Amalia', 'Staff Produksi', '081234567890', 'Aktif');

insert into kategori_pengeluaran (nama_kategori, keterangan) values
  ('Bahan kemasan', 'Box, paper bag, stiker, dan kebutuhan kemasan'),
  ('Gas', 'Gas LPG dan kebutuhan dapur'),
  ('Transportasi', 'Ongkos kirim dan perjalanan operasional'),
  ('Alat tulis', 'ATK dan perlengkapan administrasi'),
  ('Kebersihan', 'Sabun, tisu, dan perlengkapan kebersihan'),
  ('Perawatan peralatan', 'Servis oven, mixer, dan peralatan bakery'),
  ('Lain-lain', 'Pengeluaran operasional lainnya');

-- Catatan: RLS dan policy dapat ditambahkan setelah autentikasi Supabase diaktifkan.
