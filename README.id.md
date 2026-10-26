# Jebleskon

[![Go](https://img.shields.io/badge/Go-1.26%2B-00ADD8?logo=go&logoColor=white)](https://go.dev/dl/)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux-lightgrey)](#instalasi-cepat)
[![Lisensi: MIT](https://img.shields.io/badge/Lisensi-MIT-yellow.svg)](LICENSE)
[![CI](https://img.shields.io/badge/pengujian-lulus-brightgreen)](#pengembangan)

**Jebleskon** adalah utilitas CLI lintas platform (Windows & Linux) untuk memproses berkas PDF dan
dokumen secara lokal. Alat ini dirancang untuk dipanggil dari **menu konteks OS** (klik kanan di
Windows Explorer atau pengelola berkas Linux), bukan dijalankan langsung dari terminal.

Jebleskon **tidak memiliki antarmuka grafis (GUI)**. Seluruh umpan balik — berhasil maupun gagal —
disampaikan melalui **notifikasi desktop OS (toast)**, sehingga pengguna tidak perlu membuka
jendela terminal sama sekali.

> 🌐 **English?** Read the documentation in English:
> **[README.md](README.md)**

> 📖 **Baru memakai Jebleskon?** Mulai dari panduan langkah demi langkah:
> **[PANDUAN-PENGGUNA.md](PANDUAN-PENGGUNA.md)**

---

## Daftar Isi

- [Fitur](#fitur)
- [Instalasi Cepat](#instalasi-cepat)
- [Prasyarat](#prasyarat)
- [Instalasi Manual](#instalasi-manual)
- [Penggunaan](#penggunaan)
- [Cara Kerja](#cara-kerja)
- [Struktur Proyek](#struktur-proyek)
- [Pengembangan](#pengembangan)
- [Batasan yang Diketahui](#batasan-yang-diketahui)
- [Berkontribusi](#berkontribusi)
- [Lisensi](#lisensi)

---

## Fitur

| Aksi | Nilai `--action` | Mesin | Keterangan |
| --- | --- | --- | --- |
| Gabung PDF | `merge` | pdfcpu (Go) | Menggabungkan beberapa PDF menjadi satu, sesuai urutan masukan |
| Pisah PDF | `split` | pdfcpu (Go) | Memecah satu PDF menjadi berkas satu-halaman |
| Gambar ke PDF | `img2pdf` | pdfcpu (Go) | Mengubah gambar JPG/PNG menjadi PDF multi-halaman |
| Kompres PDF | `compress` | Ghostscript | Mengecilkan ukuran PDF menggunakan preset `/screen` |
| Konversi Dokumen | `convert-doc` | LibreOffice | Mengonversi DOC/DOCX/ODT ⇄ PDF secara headless |

Seluruh proses berjalan **secara lokal** — tidak ada berkas yang diunggah ke mana pun.

---

## Instalasi Cepat

> Tidak perlu mengedit berkas apa pun secara manual. Skrip installer menangani semuanya.

### Linux

```bash
git clone https://github.com/MochAzmilUmur/jebleskon.git
cd jebleskon
chmod +x install.sh
./install.sh
```

Installer akan secara otomatis:
- Mendeteksi distro dan memasang Go jika belum tersedia
- Menawarkan pemasangan Ghostscript dan LibreOffice
- Membangun binary dan memasangnya ke `~/.local/bin`
- Mendeteksi pengelola berkas (Dolphin, Nautilus, Nemo, Thunar) dan mendaftarkan menu konteks

Untuk menghapus instalasi:

```bash
./install.sh --uninstall
```

### Windows

Buka PowerShell sebagai Administrator (klik kanan → **Run as administrator**), lalu jalankan:

```powershell
git clone https://github.com/MochAzmilUmur/jebleskon.git
cd jebleskon
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\install.ps1
```

Installer akan secara otomatis:
- Memasang Go melalui `winget` jika belum tersedia
- Membangun `jebleskon.exe` dan memasangnya ke `C:\Tools\jebleskon\`
- Menambahkan folder tersebut ke `PATH`
- Mendaftarkan menu konteks Windows Explorer tanpa perlu mengedit registry secara manual

Untuk menghapus instalasi:

```powershell
.\install.ps1 -Uninstall
```

---

## Prasyarat

| Dependensi | Versi | Wajib? | Digunakan untuk |
| --- | --- | --- | --- |
| [Go](https://go.dev/dl/) | **1.26 atau lebih baru** | Ya (hanya saat build) | Kompilasi proyek |
| [Ghostscript](https://www.ghostscript.com/) (`gs`) | Terbaru | Hanya aksi `compress` | Kompresi PDF |
| [LibreOffice](https://www.libreoffice.org/) (`soffice`) | Terbaru | Hanya aksi `convert-doc` | Konversi dokumen |

> Installer Linux akan menawarkan pemasangan Ghostscript dan LibreOffice secara otomatis.
> Di Windows, installer memeriksa keberadaannya dan menampilkan tautan unduhan jika belum ada.
> Jika Anda hanya menggunakan sebagian aksi, dependensi yang tidak dipakai dapat dilewati —
> Jebleskon akan menampilkan notifikasi galat yang jelas apabila `gs` atau `soffice` tidak ditemukan.

---

## Instalasi Manual

Bagian ini ditujukan bagi pengguna yang ingin mengontrol setiap langkah secara manual, atau yang
tidak dapat menjalankan skrip installer.

### 1. Kloning repositori

```bash
git clone https://github.com/MochAzmilUmur/jebleskon.git
cd jebleskon
```

### 2. Build binary

**Linux**

```bash
go mod download
go build -trimpath -ldflags "-s -w" -o jebleskon ./cmd/jebleskon
```

**Windows (PowerShell)**

```powershell
go mod download
go build -trimpath -ldflags "-s -w" -o jebleskon.exe ./cmd/jebleskon
```

**Cross-compile dari Linux ke Windows**

```bash
GOOS=windows GOARCH=amd64 go build -trimpath -ldflags "-s -w" -o jebleskon.exe ./cmd/jebleskon
```

### 3. Pasang binary ke PATH

**Linux**

```bash
install -m 0755 jebleskon ~/.local/bin/jebleskon
# Pastikan ~/.local/bin ada di PATH (umumnya sudah ada di distro modern)
```

**Windows**

Pindahkan `jebleskon.exe` ke folder tetap, lalu tambahkan ke `PATH`:

```powershell
[Environment]::SetEnvironmentVariable(
  "Path",
  [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\Tools\jebleskon",
  "User"
)
```

### 4. Daftarkan menu konteks OS

#### Windows — Registry

Gunakan `install.ps1` — skrip ini menangani pendaftaran secara otomatis. Jika ingin dilakukan
secara manual, buka `os-integrator/windows/jebleskon_menu.reg`, ganti setiap kemunculan
`JEBLESKON_EXE` dengan path lengkap `jebleskon.exe` (gunakan `\\` sebagai pemisah direktori),
kemudian jalankan:

```powershell
reg import os-integrator\windows\jebleskon_menu.reg
```

#### Linux — KDE Dolphin (Plasma 6)

```bash
mkdir -p ~/.local/share/kio/servicemenus
cp os-integrator/linux/dolphin.desktop ~/.local/share/kio/servicemenus/jebleskon.desktop
chmod +x ~/.local/share/kio/servicemenus/jebleskon.desktop
kbuildsycoca6 --noincremental
```

> Untuk **Plasma 5**, gunakan folder `~/.local/share/kservices5/ServiceMenus/` dan jalankan
> `kbuildsycoca5`.

#### Linux — GNOME Nautilus / Nemo

```bash
# Nautilus
cp os-integrator/linux/nautilus-scripts/Jebleskon* ~/.local/share/nautilus/scripts/
chmod +x ~/.local/share/nautilus/scripts/Jebleskon*

# Nemo
cp os-integrator/linux/nautilus-scripts/Jebleskon* ~/.local/share/nemo/scripts/
chmod +x ~/.local/share/nemo/scripts/Jebleskon*
```

Klik kanan berkas → **Scripts** → **Jebleskon - ...**

#### Linux — Thunar (XFCE)

Gunakan `install.sh`, yang secara otomatis menyuntikkan entri yang diperlukan ke
`~/.config/Thunar/uca.xml`.

### 5. Verifikasi instalasi

```bash
jebleskon --version
jebleskon --help
```

---

## Penggunaan

```
jebleskon --action <aksi> --files <berkas1,berkas2,...> [--out <keluaran>]
```

### Flag

| Flag | Wajib | Default | Keterangan |
| --- | --- | --- | --- |
| `--action` | Ya | — | Aksi yang dijalankan (lihat tabel di bawah) |
| `--files` | Ya | — | Daftar path berkas masukan, dipisahkan koma |
| `--out` | Tidak | Dibuat otomatis | Path berkas keluaran, atau **direktori** untuk aksi `split` |
| `--version` / `-v` | Tidak | — | Menampilkan versi dan keluar |
| `--help` | Tidak | — | Menampilkan panduan penggunaan dan keluar |

### Aksi dan nama keluaran default

| `--action` | Masukan | Keluaran default bila `--out` tidak diisi |
| --- | --- | --- |
| `merge` | ≥ 2 berkas PDF | `merged.pdf` di folder berkas masukan pertama |
| `split` | 1 berkas PDF | Halaman individual ditulis ke folder yang sama dengan berkas masukan |
| `img2pdf` | ≥ 1 berkas JPG/PNG | `images.pdf` di folder gambar pertama |
| `compress` | 1 berkas PDF | `<nama>_compressed.pdf` di folder yang sama |
| `convert-doc` | 1 berkas dokumen | `<nama>.pdf`; jika masukan berupa PDF: `<nama>.docx` |

### Contoh

```bash
# Gabungkan dua PDF
jebleskon --action merge --files "laporan-q1.pdf,laporan-q2.pdf"

# Gabungkan dengan nama keluaran khusus
jebleskon --action merge --files "a.pdf,b.pdf,c.pdf" --out tahunan.pdf

# Pisahkan PDF menjadi berkas per halaman
jebleskon --action split --files presentasi.pdf --out ./halaman/

# Kompres PDF
jebleskon --action compress --files buku.pdf

# Ubah hasil scan menjadi satu PDF multi-halaman
jebleskon --action img2pdf --files "scan-01.jpg,scan-02.jpg,scan-03.png"

# Konversi dokumen Word ke PDF
jebleskon --action convert-doc --files nota.docx

# Konversi PDF ke DOCX
jebleskon --action convert-doc --files laporan.pdf
```

### Kode keluar

| Kode | Arti |
| --- | --- |
| `0` | Berhasil |
| `1` | Gagal (masukan tidak valid, dependensi tidak ditemukan, atau galat pada mesin pemrosesan) |

---

## Cara Kerja

1. Menu konteks OS memanggil `jebleskon` dengan `--action`, `--files`, dan opsional `--out`.
2. `cmd/jebleskon/main.go` memvalidasi flag lalu meneruskan panggilan ke paket `internal/pdfengine`.
3. Aksi `merge`, `split`, dan `img2pdf` diproses **sepenuhnya di dalam proses Go** melalui pustaka
   pdfcpu. Aksi `compress` dan `convert-doc` menjalankan proses eksternal (`gs` dan `soffice`)
   melalui `os/exec`.
4. Hasil akhir dilaporkan melalui paket `internal/notifier` (pustaka beeep) sebagai notifikasi
   toast desktop OS.

---

## Struktur Proyek

```
jebleskon/
├── cmd/jebleskon/            # Titik masuk, parsing flag, dan perutean aksi
├── internal/pdfengine/       # Mesin pemrosesan (merge, split, img2pdf, compress, convert-doc)
├── internal/notifier/        # Pembungkus notifikasi desktop lintas platform
├── os-integrator/
│   ├── windows/              # Berkas registry untuk menu konteks Explorer
│   └── linux/
│       ├── dolphin.desktop   # Service menu KDE Dolphin
│       ├── nautilus-scripts/ # Skrip untuk Nautilus dan Nemo
│       └── thunar-uca.xml    # Custom actions untuk Thunar
├── install.sh                # Installer otomatis Linux
├── install.ps1               # Installer otomatis Windows
├── LICENSE                   # Lisensi MIT
└── PANDUAN-PENGGUNA.md       # Panduan lengkap untuk pengguna akhir
```

---

## Pengembangan

```bash
go build ./...   # Kompilasi semua paket
go test ./...    # Jalankan pengujian (termasuk uji putar-balik: img2pdf → merge → split)
go vet ./...     # Analisis statis
gofmt -l .       # Periksa format kode (keluaran kosong = semua rapi)
```

Pengujian **tidak memerlukan** Ghostscript maupun LibreOffice. Kedua mesin eksternal tersebut hanya
dipanggil saat aksi terkait dijalankan pada waktu runtime.

---

## Batasan yang Diketahui

- **Penggabungan multi-berkas tidak tersedia dari Windows Explorer.** Verb registry didaftarkan pada
  kunci `*`, yang hanya meneruskan **satu** berkas (`%1`). Aksi Compress, Split, dan Convert tetap
  berfungsi per berkas. Penggabungan multi-berkas dari menu konteks hanya tersedia di Linux (Dolphin
  menggunakan `%F`; Nautilus/Nemo menggunakan `$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS`), atau dengan
  memanggil CLI secara manual.
- **`compress` dan `convert-doc` bergantung pada program eksternal.** Jika `gs` atau `soffice`
  tidak ada di `PATH`, aksi tersebut gagal dengan notifikasi yang menyebutkan dependensi yang hilang.
- **Konversi dokumen hanya menggunakan LibreOffice.** COM automation Microsoft Word sengaja tidak
  diimplementasikan — fitur tersebut hanya berjalan di Windows dan menambah dependensi berat untuk
  pekerjaan yang sudah dicakup LibreOffice di kedua platform.
- **Notifikasi memerlukan sesi desktop.** D-Bus di Linux dan Windows Notification Platform di
  Windows harus berjalan. Di lingkungan tanpa sesi desktop (misalnya SSH murni), notifikasi tidak
  akan muncul, tetapi pesan galat tetap dicetak ke `stderr`.
- **`--action split` menulis ke direktori.** Saat menggunakan `--out`, arahkan ke sebuah direktori,
  bukan path berkas.
- **Installer Linux memerlukan koneksi internet** hanya jika Go belum terpasang (untuk mengunduh
  tarball Go dari go.dev). Jika Go sudah ada, proses build berjalan sepenuhnya secara offline.

---

## Berkontribusi

Kontribusi sangat disambut. Ikuti langkah-langkah berikut:

1. Fork repositori ini dan buat branch fitur (`git checkout -b feat/nama-fitur`).
2. Buat perubahan Anda. Usahakan diff seminimal mungkin — lihat `.amazonq/rules/AGENTS.md` untuk
   filosofi pengkodean yang diikuti proyek ini.
3. Pastikan semua pengujian lulus: `go test ./...`
4. Buka pull request dengan deskripsi yang jelas mengenai masalah dan solusinya.

Harap buka issue terlebih dahulu sebelum mengerjakan perubahan besar, untuk menghindari duplikasi
pekerjaan.

---

## Lisensi

Hak Cipta (c) 2025 Mochammad Azmil Umur

Dirilis di bawah [Lisensi MIT](LICENSE). Lihat berkas `LICENSE` untuk teks lengkapnya.

Dependensi pihak ketiga tercantum dalam `go.mod` dan memiliki lisensinya masing-masing.
