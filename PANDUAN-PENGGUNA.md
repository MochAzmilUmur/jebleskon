# Panduan Pengguna Jebleskon

Panduan ini menjelaskan cara memakai **Jebleskon** dari awal: dari klik kanan sebuah berkas sampai
membaca notifikasi hasilnya. Ditulis untuk pengguna biasa yang **tidak perlu membuka terminal** —
setiap fitur bisa dijalankan dari menu konteks OS.

> Baru pertama kali memasang? Ikuti dulu langkah di [README](../README.md#instalasi-cepat), lalu kembali ke
> sini untuk memakainya sehari-hari.

---

## Daftar Isi

1. [Apa yang bisa dilakukan Jebleskon](#1-apa-yang-bisa-dilakukan-jebleskon)
2. [Pola dasar pemakaian](#2-pola-dasar-pemakaian)
3. [Sebelum mulai](#3-sebelum-mulai)
4. [Memakai lewat menu konteks](#4-memakai-lewat-menu-konteks)
5. [Skenario langkah demi langkah](#5-skenario-langkah-demi-langkah)
6. [Di mana hasil disimpan](#6-di-mana-hasil-disimpan)
7. [Memakai lewat terminal](#7-memakai-lewat-terminal)
8. [Membaca notifikasi](#8-membaca-notifikasi)
9. [Tips & kebiasaan baik](#9-tips--kebiasaan-baik)
10. [Pemecahan masalah](#10-pemecahan-masalah)
11. [Pertanyaan yang sering diajukan](#11-pertanyaan-yang-sering-diajukan)
12. [Menghapus Jebleskon](#12-menghapus-jebleskon)
13. [Glosarium](#13-glosarium)

---

## 1. Apa yang bisa dilakukan Jebleskon

Jebleskon adalah alat bantu yang bekerja di latar belakang. Ia tidak punya jendela aplikasi; Anda
memanggilnya dari **klik kanan** pada berkas, lalu hasilnya diberitahukan lewat **notifikasi**.

| Ingin melakukan ini | Pilih aksi | Ikon menu (Windows) | Ikon menu (KDE) |
| --- | --- | --- | --- |
| Menggabungkan beberapa PDF jadi satu | `merge` | *tidak tersedia* ¹ | **Merge PDFs** |
| Memecah PDF jadi berkas per halaman | `split` | **Split PDF into pages** | **Split PDF into pages** |
| Menjadikan foto/scan sebagai PDF | `img2pdf` ² | *tidak tersedia* ² | **Images to PDF** |
| Memperkecil ukuran berkas PDF | `compress` | **Compress PDF** | **Compress PDF** |
| Mengubah Word/ODT ⇄ PDF | `convert-doc` | **Convert to PDF / DOCX** | **Convert to PDF / DOCX** |

¹ Windows Explorer hanya mengirim satu berkas ke menu klik kanan, jadi penggabungan dari klik kanan
tidak tersedia di Windows. Gunakan cara di [bagian 7](#7-memakai-lewat-terminal).
² Aksi `img2pdf` tidak ada di menu Windows bawaan; jalankan lewat terminal.

---

## 2. Pola dasar pemakaian

Tiga langkah, sama untuk semua aksi:

1. **Klik kanan** berkas yang ingin diolah.
2. Pilih menu **Jebleskon** → pilih aksinya.
3. Tunggu **notifikasi** muncul di sudut layar.

Jebleskon bekerja seketika; untuk berkas besar atau konversi dokumen, tunggu beberapa detik sampai
notifikasi muncul. Jangan menutup berkas yang sedang diolah.

**Jebleskon tidak pernah mengubah berkas asli Anda.** Hasil selalu ditulis sebagai berkas baru dengan
nama yang berbeda. Satu pengecualian penting: bila berkas hasil dengan nama yang sama **sudah ada**,
berkas itu akan **ditimpa tanpa peringatan** (lihat [bagian 9](#9-tips--kebiasaan-baik)).

---

## 3. Sebelum mulai

- Jebleskon sudah terpasang dan `jebleskon` dapat dipanggil (lihat README).
- Menu konteks sudah terpasang (registry Windows / ServiceMenu KDE).
- Untuk aksi tertentu, program pendukung harus ada:
  - `compress` → **Ghostscript**
  - `convert-doc` → **LibreOffice**

Bila program pendukung tidak ada, aksi tersebut akan gagal dengan notifikasi yang menyebut namanya.
Aksi lain tetap berfungsi normal.

---

## 4. Memakai lewat menu konteks

### 4.1 Windows Explorer

1. Buka File Explorer dan cari berkas yang ingin diolah.
2. **Klik kanan** berkas tersebut.
3. Pilih **Jebleskon** (menu bertingkat) → pilih aksi, misalnya **Compress PDF**.
4. Notifikasi muncul.

Bila menu **Jebleskon** tidak terlihat:

- Klik kanan → **Show more options** (Windows 11 memindahkan menu lama ke sini).
- Bila tetap tidak ada, impor ulang berkas registry (lihat [bagian 12](#12-menghapus-integrasi-menu)),
  lalu tutup dan buka ulang File Explorer.

### 4.2 Linux — KDE Dolphin

1. Buka **Dolphin** dan pilih satu atau beberapa berkas.
2. **Klik kanan** → **Actions** (atau langsung cari **Jebleskon**).
3. Pilih aksinya, misalnya **Merge PDFs**.
4. Notifikasi toast muncul di sudut layar.

Keunggulan di KDE: Anda bisa **memilih beberapa berkas sekaligus** (Ctrl+klik), lalu memakai
**Merge PDFs** — aksi ini menggabungkan seluruh berkas terpilih, sesuai urutan yang tampil di folder.

> Bila menu tidak muncul, jalankan `kbuildsycoca6 --noincremental` (Plasma 5: `kbuildsycoca5`), lalu
> buka ulang Dolphin.

### 4.3 Linux — GNOME Nautilus / Nemo

1. Buka **Nautilus** (Files) atau **Nemo** dan pilih berkas.
2. **Klik kanan** → **Scripts** → pilih aksi **Jebleskon - ...**
3. Notifikasi muncul di sudut layar.

Untuk merge, pilih beberapa berkas (Ctrl+klik) sebelum klik kanan.

> Bila submenu **Scripts** tidak muncul, pastikan skrip sudah `chmod +x` dan Nautilus/Nemo sudah
> di-restart.

### 4.4 Linux — Thunar (XFCE)

1. Buka **Thunar** dan pilih berkas.
2. **Klik kanan** → pilih aksi **Jebleskon - ...**
3. Notifikasi muncul.

> Bila menu tidak muncul, jalankan `thunar -q && thunar` untuk me-restart Thunar.

---

## 5. Skenario langkah demi langkah

### 5.1 Menggabungkan beberapa PDF (`merge`)

**Tujuan:** menyatukan beberapa PDF menjadi satu berkas.

**Di Linux (KDE):**

1. Pilih dua PDF atau lebih di Dolphin (Ctrl+klik), **urutkan dengan klik kolom Nama** agar urutan
   hasil sesuai keinginan.
2. Klik kanan → **Jebleskon** → **Merge PDFs**.
3. Notifikasi *"Merge successful!"* muncul dan terbentuk `merged.pdf` di folder yang sama.

**Di Windows:** jalankan lewat terminal (lihat [bagian 7](#7-memakai-lewat-terminal)), karena klik
kanan Windows hanya mengirim satu berkas.

**Hasil yang diharapkan:** satu berkas `merged.pdf` berisi semua halaman dari tiap masukan, berurutan.
Masukan berurutan diambil dari urutan yang Anda berikan/urutkan.

---

### 5.2 Memecah PDF (`split`)

**Tujuan:** memecah satu PDF menjadi berkas terpisah per halaman.

1. Klik kanan **satu** berkas PDF.
2. Pilih **Jebleskon** → **Split PDF into pages**.
3. Notifikasi *"Split successful!"* muncul.

**Hasil yang diharapkan:** berkas baru di folder yang sama, diberi nomor berdasarkan nama asli:

```
laporan ku.pdf   →   laporan ku_1.pdf
                     laporan ku_2.pdf
                     laporan ku_3.pdf
```

Bila Anda ingin hasilnya masuk ke folder lain, gunakan terminal dengan `--out` (lihat bagian 7).

---

### 5.3 Mengubah gambar menjadi PDF (`img2pdf`)

**Tujuan:** mengubah kumpulan foto atau hasil scan menjadi satu PDF multi-halaman (berguna untuk
mengirim arsip atau mencetak).

1. Pilih satu atau beberapa gambar JPG/PNG. **Urutan pemilihan menentukan urutan halaman**, jadi
   beri nama berkas dengan penomoran (`scan-01.jpg`, `scan-02.jpg`, …) agar rapi.
2. Jalankan aksi `img2pdf` (di KDE: **Images to PDF**; di Windows lewat terminal).
3. Notifikasi *"Images converted to PDF!"* muncul.

**Hasil yang diharapkan:** satu berkas `images.pdf` di folder gambar pertama. **Satu gambar = satu
halaman penuh.**

---

### 5.4 Memperkecil ukuran PDF (`compress`)

**Tujuan:** mengecilkan ukuran PDF agar mudah dilampirkan lewat surel.

1. Klik kanan satu berkas PDF.
2. Pilih **Jebleskon** → **Compress PDF**.
3. Notifikasi *"Compression successful!"* muncul.

**Hasil yang diharapkan:** `<nama>_compressed.pdf` di folder yang sama.

**Yang perlu diketahui:** kompresi memakai preset **paling agresif** (`/screen`, sekitar 72 dpi).
Ukuran turun banyak, **tetapi kualitas gambar ikut turun** dan teks yang sangat kecil bisa kurang
tajam. Cocok untuk lampiran surel, kurang cocok untuk dokumen cetak berkualitas. Bila isi PDF murni
teks/vektor, ukurannya bisa tidak banyak berubah, bahkan sedikit membesar — itu normal.

---

### 5.5 Mengubah dokumen ke/dari PDF (`convert-doc`)

**Tujuan:** membuat PDF dari dokumen Word/ODT, atau sebaliknya.

1. Klik kanan satu berkas dokumen (`.docx`, `.doc`, `.odt`, …) atau satu berkas PDF.
2. Pilih **Jebleskon** → **Convert to PDF / DOCX**.
3. Notifikasi *"Conversion successful!"* muncul.

**Arah konversi ditentukan otomatis:**

| Berkas masukan | Hasil |
| --- | --- |
| `.docx`, `.doc`, `.odt`, dll. | `<nama>.pdf` |
| `.pdf` | `<nama>.docx` |

**Hasil yang diharapkan:** berkas baru di folder yang sama. Pada konversi pertama di sebuah komputer,
LibreOffice kadang perlu waktu lebih lama (menyiapkan profil), jadi tunggu sampai notifikasi muncul.

> Konversi memakai LibreOffice, bukan Microsoft Word. Tata letak rumit (kolom majalah, kotak teks,
> font khusus) bisa bergeser sedikit pada beberapa dokumen.

---

## 6. Di mana hasil disimpan

Bila Anda memakai menu konteks (tanpa menentukan folder), hasil **selalu** diletakkan di folder yang
sama dengan berkas masukan:

| Aksi | Nama berkas hasil |
| --- | --- |
| `merge` | `merged.pdf` |
| `split` | `<nama>_1.pdf`, `<nama>_2.pdf`, … |
| `img2pdf` | `images.pdf` |
| `compress` | `<nama>_compressed.pdf` |
| `convert-doc` | `<nama>.pdf` atau `<nama>.docx` |

⚠️ **Bila berkas dengan nama itu sudah ada di folder tersebut, isinya akan ditimpa tanpa
konfirmasi.** Untuk `merge`, `img2pdf`, dan `convert-doc` risiko ini nyata: lakukan merge lebih dari
sekali di folder yang sama akan menimpa `merged.pdf` sebelumnya. Pindahkan atau ganti nama hasil lama
bila masih diperlukan.

---

## 7. Memakai lewat terminal

Menu konteks cukup untuk sebagian besar pekerjaan. Terminal diperlukan untuk kasus yang tidak bisa
dilakukan lewat klik kanan — terutama **merge di Windows**, atau bila ingin **menentukan sendiri nama
dan folder hasil**.

### Bentuk perintah

```
jebleskon --action <aksi> --files <berkas1,berkas2,...> [--out <keluaran>]
```

### Flag

| Flag | Wajib | Isi |
| --- | --- | --- |
| `--action` | Ya | Salah satu dari: `merge`, `split`, `img2pdf`, `compress`, `convert-doc` |
| `--files` | Ya | Daftar path, **dipisah koma**. Untuk `split`/`compress`/`convert-doc`, hanya berkas pertama yang dipakai |
| `--out` | Tidak | Berkas hasil, atau **folder** khusus untuk `split` |

### Contoh siap pakai

**Windows (PowerShell)** — gabungkan PDF di folder saat ini:

```powershell
jebleskon --action merge --files "laporan1.pdf,laporan2.pdf" --out gabungan.pdf
```

**Windows (PowerShell)** — gabungkan seluruh PDF di folder, urut nama:

```powershell
$daftar = (Get-ChildItem *.pdf | Sort-Object Name | ForEach-Object { $_.FullName }) -join ","
jebleskon --action merge --files $daftar --out gabungan.pdf
```

**Linux** — pisah PDF ke folder khusus:

```bash
jebleskon --action split --files "laporan ku.pdf" --out ./halaman/
```

**Linux** — kompres dengan nama hasil sendiri:

```bash
jebleskon --action compress --files buku.pdf --out buku-ringan.pdf
```

**Linux** — ubah semua scan jadi satu PDF:

```bash
jebleskon --action img2pdf --files "scan-01.jpg,scan-02.jpg,scan-03.png" --out arsip.pdf
```

### Catatan penting untuk terminal

- Jalur berkas sebaiknya ditulis dengan **path absolut** (contoh: `C:\Docs\a.pdf` atau `/home/andi/a.pdf`)
  agar tidak bergantung pada folder terminal saat itu.
- **Berkas dengan koma pada namanya tidak didukung**, karena `--files` memakai koma sebagai pemisah.
  Ganti nama berkas tersebut terlebih dahulu.
- Di Linux, bila berkas berisi spasi, bungkus dengan tanda kutip.
- **Kode keluar:** `0` = berhasil, `1` = gagal. Berguna bila Jebleskon dipakai di dalam skrip.

---

## 8. Membaca notifikasi

Jebleskon hanya berkomunikasi lewat notifikasi, jadi penting untuk mengenali artinya.

| Notifikasi | Arti |
| --- | --- |
| *Jebleskon — Merge successful!* | Berhasil; berkas hasil sudah dibuat |
| *Jebleskon — Split successful!* | Berhasil |
| *Jebleskon — Images converted to PDF!* | Berhasil |
| *Jebleskon — Compression successful!* | Berhasil |
| *Jebleskon — Conversion successful!* | Berhasil |
| *Jebleskon — ghostscript (gs) not found on PATH* | Ghostscript belum dipasang / belum ada di PATH |
| *Jebleskon — libreoffice (soffice) not found on PATH* | LibreOffice belum dipasang / belum ada di PATH |
| *Jebleskon — no input files given* | Tidak ada berkas yang terkirim ke Jebleskon |
| *Jebleskon — merge needs at least two PDFs* | Aksi merge dipanggil dengan kurang dari dua berkas |

Notifikasi galat juga **tercetak ke `stderr`** di terminal. Bila Anda memanggil Jebleskon dari
terminal, pesan lengkapnya tampak di sana — inilah sumber terbaik saat mencari masalah.

> Di lingkungan tanpa sesi desktop (misalnya SSH), notifikasi toast tidak dapat muncul, tetapi
> Jebleskon tetap bekerja dan mencetak hasilnya ke terminal.

---

## 9. Tips & kebiasaan baik

1. **Backup sebelum mengolah berkas penting.** Hasil ditulis ke nama baru, tetapi hasil lama dengan
   nama yang sama akan ditimpa (lihat bagian 6).
2. **Uji dengan satu berkas dulu** sebelum mengolah tumpukan dokumen besar.
3. **Beri nama berkas yang terurut** (`01-`, `02-`, …) untuk `merge` dan `img2pdf`, agar urutan
   halaman pasti benar.
4. **Hindari koma** pada nama berkas bila akan dipakai lewat terminal.
5. **Proses besar memakan waktu.** PDF ratusan halaman atau konversi dokumen berat bisa berjalan
   beberapa detik sampai menit; tunggu notifikasi, jangan mengulang klik.
6. **Perhatikan kualitas setelah kompresi.** Buka hasilnya sekali untuk memastikan teks/gambar masih
   cukup jelas.

---

## 10. Pemecahan masalah

| Gejala | Kemungkinan penyebab | Solusi |
| --- | --- | --- |
| Menu **Jebleskon** tidak muncul di klik kanan Windows | Registry belum diimpor, atau path `JEBLESKON_EXE` belum diganti | Impor ulang setelah mengganti `JEBLESKON_EXE` dengan path lengkap `jebleskon.exe`, lalu buka ulang File Explorer |
| Menu tidak muncul di Dolphin | ServiceMenu belum terpasang / cache belum diperbarui | Salin `dolphin.desktop` ke folder ServiceMenu, `chmod +x`, lalu `kbuildsycoca6 --noincremental` |
| Tidak ada notifikasi apa pun | Layanan desktop (D-Bus / Windows Notification) tidak jalan, atau fokus tidak terganggu | Uji lewat terminal dan periksa teks di `stderr`; hasil kerja kemungkinan tetap berhasil |
| *"ghostscript (gs) not found on PATH"* | Ghostscript belum dipasang atau folder `bin`-nya belum masuk `PATH` | Pasang Ghostscript; tambahkan folder `bin` ke `PATH`; uji dengan `gs --version` |
| *"libreoffice (soffice) not found on PATH"* | LibreOffice belum dipasang atau `soffice` belum ada di `PATH` | Pasang LibreOffice; tambahkan foldernya ke `PATH`; uji dengan `soffice --version` |
| `convert-doc` gagal pada percobaan pertama | LibreOffice menyiapkan profilnya untuk pertama kali | Jalankan ulang aksi setelah beberapa saat |
| `convert-doc` berhenti tanpa hasil | Format masukan tidak dikenali LibreOffice | Buka berkas di LibreOffice untuk memastikan bisa dibaca, lalu coba lagi |
| Ukuran hasil kompresi tidak berubah / malah membesar | PDF sudah optimal, atau isinya teks/vektor | Normal; preset `/screen` paling berpengaruh pada PDF berisi gambar/scan |
| Merge gagal pada PDF tertentu | PDF terkunci kata sandi atau rusak | Buka dengan kata sandi di pembaca PDF dan simpan ulang sebagai PDF biasa, lalu merge kembali |
| Berkas hasil berisi data lama | Berkas hasil dengan nama sama sudah ada dan ditimpa | Pindahkan/ganti nama hasil lama, atau gunakan `--out` untuk nama baru |

---

## 11. Pertanyaan yang sering diajukan

**Apakah berkas saya diunggah ke internet?**
Tidak. Semua proses berjalan lokal di komputer Anda, memakai pustaka Go dan program yang sudah
terpasang (Ghostscript, LibreOffice).

**Bisakah memakai Jebleskon tanpa membuka terminal selamanya?**
Ya di KDE (termasuk merge multi-berkas). Di Windows, hampir semua aksi bisa dari klik kanan, kecuali
merge multi-berkas.

**Bagaimana menggabungkan PDF di Windows tanpa terminal?**
Tidak bisa lewat menu klik kanan karena batasan Explorer. Jalankan perintah `merge` di PowerShell
(lihat [bagian 7](#7-memakai-lewat-terminal)).

**Apakah berkas asli saya akan terhapus atau berubah?**
Tidak. Berkas asli dibiarkan utuh; hasil adalah berkas baru. Yang perlu diwaspadai hanya penimpaan
berkas hasil bernama sama yang sudah ada sebelumnya.

**Bisakah memilih folder tujuan?**
Ya, dengan `--out` lewat terminal. Untuk `split`, `--out` adalah folder; untuk aksi lain, `--out`
adalah nama berkas hasil.

**Apakah hasil kompresi tetap bisa dibuka dan dicari teksnya?**
Ya. Kompresi hanya mengubah resolusi/pengaturan gambar; struktur PDF tetap standar dan bisa dibuka
di pembaca PDF mana pun.

**Format gambar apa saja yang didukung `img2pdf`?**
JPG dan PNG. Untuk format lain, ubah dulu ke JPG/PNG.

---

## 12. Menghapus Jebleskon

**Linux — otomatis (direkomendasikan):**

```bash
./install.sh --uninstall
```

Ini menghapus binary, semua entri menu konteks (Dolphin, Nautilus, Nemo, Thunar), dan entri
aplikasi `.desktop`.

**Windows — otomatis (direkomendasikan):**

```powershell
.\install.ps1 -Uninstall
```

Ini menghapus registry, binary di `C:\Tools\jebleskon\`, dan entri PATH.

**Manual (jika installer tidak tersedia):**

```powershell
# Windows
reg delete "HKEY_CLASSES_ROOT\*\shell\Jebleskon" /f
reg delete "HKEY_CLASSES_ROOT\SystemFileAssociations\.pdf\shell\Jebleskon" /f
```

```bash
# Linux (KDE)
rm ~/.local/share/kio/servicemenus/jebleskon.desktop
kbuildsycoca6 --noincremental

# Linux (Nautilus)
rm ~/.local/share/nautilus/scripts/Jebleskon*

# Linux (Nemo)
rm ~/.local/share/nemo/scripts/Jebleskon*
```

---

## 13. Glosarium

| Istilah | Arti |
| --- | --- |
| **Headless** | Berjalan di latar belakang tanpa jendela aplikasi |
| **Menu konteks** | Menu yang muncul saat Anda klik kanan |
| **Notifikasi toast** | Kotak pemberitahuan kecil di sudut layar yang hilang sendiri |
| **`--files`** | Daftar berkas masukan, dipisah koma |
| **`--out`** | Berkas/folder tujuan hasil |
| **Preset `/screen`** | Pengaturan kompresi Ghostscript untuk ukuran terkecil (kualitas gambar lebih rendah) |
| **PATH** | Daftar folder tempat sistem mencari program yang dapat dijalankan |
