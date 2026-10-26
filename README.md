# Jebleskon

[![Go](https://img.shields.io/badge/Go-1.26%2B-00ADD8?logo=go&logoColor=white)](https://go.dev/dl/)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux-lightgrey)](#installation)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![CI](https://img.shields.io/badge/tests-passing-brightgreen)](#development)

**Jebleskon** is a cross-platform, headless CLI utility (Windows & Linux) for processing PDF files
and documents locally. It is designed to be invoked from the **OS context menu** (right-click in
Windows Explorer or a Linux file manager) rather than run directly from a terminal.

Jebleskon has **no GUI**. All feedback — success or failure — is delivered through **OS desktop
notifications (toast)**, so users never need to open a terminal window.

> 🌐 **Bahasa Indonesia?** Baca dokumentasi dalam Bahasa Indonesia:
> **[README.id.md](README.id.md)**

> 📖 **New to Jebleskon?** Start with the step-by-step user guide:
> **[PANDUAN-PENGGUNA.md](PANDUAN-PENGGUNA.md)**

---

## Table of Contents

- [Features](#features)
- [Quick Install](#quick-install)
- [Prerequisites](#prerequisites)
- [Manual Installation](#manual-installation)
- [Usage](#usage)
- [How It Works](#how-it-works)
- [Project Structure](#project-structure)
- [Development](#development)
- [Known Limitations](#known-limitations)
- [Contributing](#contributing)
- [License](#license)

---

## Features

| Action | `--action` value | Engine | Description |
| --- | --- | --- | --- |
| Merge PDFs | `merge` | pdfcpu (Go) | Combine multiple PDFs into one, preserving input order |
| Split PDF | `split` | pdfcpu (Go) | Split a single PDF into one file per page |
| Images to PDF | `img2pdf` | pdfcpu (Go) | Convert JPG/PNG images into a multi-page PDF |
| Compress PDF | `compress` | Ghostscript | Reduce PDF file size using the `/screen` preset |
| Convert Document | `convert-doc` | LibreOffice | Convert DOC/DOCX/ODT ⇄ PDF headlessly |

All processing runs **locally** — no files are ever uploaded anywhere.

---

## Quick Install

> No manual file editing required. The installer handles everything automatically.

### Linux

```bash
git clone https://github.com/MochAzmilUmur/jebleskon.git
cd jebleskon
chmod +x install.sh
./install.sh
```

The installer will automatically:
- Detect your distro and install Go if not present
- Offer to install Ghostscript and LibreOffice
- Build the binary and install it to `~/.local/bin`
- Detect your file manager (Dolphin, Nautilus, Nemo, Thunar) and register the context menu

To uninstall:

```bash
./install.sh --uninstall
```

### Windows

Open PowerShell as Administrator (right-click → **Run as administrator**), then:

```powershell
git clone https://github.com/MochAzmilUmur/jebleskon.git
cd jebleskon
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\install.ps1
```

The installer will automatically:
- Install Go via `winget` if not present
- Build `jebleskon.exe` and install it to `C:\Tools\jebleskon\`
- Add that folder to your `PATH`
- Register the Windows Explorer context menu without any manual registry editing

To uninstall:

```powershell
.\install.ps1 -Uninstall
```

---

## Prerequisites

| Dependency | Version | Required? | Used for |
| --- | --- | --- | --- |
| [Go](https://go.dev/dl/) | **1.26 or later** | Yes (build only) | Compiling the project |
| [Ghostscript](https://www.ghostscript.com/) (`gs`) | Latest | Only for `compress` | PDF compression |
| [LibreOffice](https://www.libreoffice.org/) (`soffice`) | Latest | Only for `convert-doc` | Document conversion |

> The Linux installer will offer to install Ghostscript and LibreOffice automatically.
> On Windows, the installer checks for them and displays download links if they are missing.
> If you only use a subset of actions, unused dependencies can be skipped —
> Jebleskon will show a clear error notification if `gs` or `soffice` is not found.

---

## Manual Installation

This section is for users who want full control over each step, or who cannot run the installer
scripts.

### 1. Clone the repository

```bash
git clone https://github.com/MochAzmilUmur/jebleskon.git
cd jebleskon
```

### 2. Build the binary

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

**Cross-compile from Linux to Windows**

```bash
GOOS=windows GOARCH=amd64 go build -trimpath -ldflags "-s -w" -o jebleskon.exe ./cmd/jebleskon
```

### 3. Install the binary to PATH

**Linux**

```bash
install -m 0755 jebleskon ~/.local/bin/jebleskon
# Ensure ~/.local/bin is in your PATH (it usually is on modern distros)
```

**Windows**

Move `jebleskon.exe` to a permanent folder, then add it to `PATH`:

```powershell
[Environment]::SetEnvironmentVariable(
  "Path",
  [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\Tools\jebleskon",
  "User"
)
```

### 4. Register the OS context menu

#### Windows — Registry

Use `install.ps1` — it handles this automatically. If you prefer to do it manually, open
`os-integrator/windows/jebleskon_menu.reg`, replace every occurrence of `JEBLESKON_EXE` with the
full path to `jebleskon.exe` (use `\\` as the path separator), then:

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

> For **Plasma 5**, use `~/.local/share/kservices5/ServiceMenus/` and run `kbuildsycoca5`.

#### Linux — GNOME Nautilus / Nemo

```bash
# Nautilus
cp os-integrator/linux/nautilus-scripts/Jebleskon* ~/.local/share/nautilus/scripts/
chmod +x ~/.local/share/nautilus/scripts/Jebleskon*

# Nemo
cp os-integrator/linux/nautilus-scripts/Jebleskon* ~/.local/share/nemo/scripts/
chmod +x ~/.local/share/nemo/scripts/Jebleskon*
```

Right-click a file → **Scripts** → **Jebleskon - ...**

#### Linux — Thunar (XFCE)

Use `install.sh`, which injects the required entries into `~/.config/Thunar/uca.xml` automatically.

### 5. Verify the installation

```bash
jebleskon --version
jebleskon --help
```

---

## Usage

```
jebleskon --action <action> --files <file1,file2,...> [--out <output>]
```

### Flags

| Flag | Required | Default | Description |
| --- | --- | --- | --- |
| `--action` | Yes | — | Action to run (see table below) |
| `--files` | Yes | — | Comma-separated list of input file paths |
| `--out` | No | Auto-generated | Output file path, or a **directory** for `split` |
| `--version` / `-v` | No | — | Print version and exit |
| `--help` | No | — | Print usage and exit |

### Actions and default output names

| `--action` | Input | Default output when `--out` is omitted |
| --- | --- | --- |
| `merge` | ≥ 2 PDF files | `merged.pdf` in the folder of the first input file |
| `split` | 1 PDF file | Individual pages written to the same folder as the input |
| `img2pdf` | ≥ 1 JPG/PNG file | `images.pdf` in the folder of the first image |
| `compress` | 1 PDF file | `<name>_compressed.pdf` in the same folder |
| `convert-doc` | 1 document file | `<name>.pdf`; if input is a PDF: `<name>.docx` |

### Examples

```bash
# Merge two PDFs
jebleskon --action merge --files "report-q1.pdf,report-q2.pdf"

# Merge with a custom output name
jebleskon --action merge --files "a.pdf,b.pdf,c.pdf" --out annual.pdf

# Split a PDF into individual pages
jebleskon --action split --files slides.pdf --out ./pages/

# Compress a PDF
jebleskon --action compress --files book.pdf

# Convert scanned images into a single multi-page PDF
jebleskon --action img2pdf --files "scan-01.jpg,scan-02.jpg,scan-03.png"

# Convert a Word document to PDF
jebleskon --action convert-doc --files invoice.docx

# Convert a PDF to DOCX
jebleskon --action convert-doc --files report.pdf
```

### Exit codes

| Code | Meaning |
| --- | --- |
| `0` | Success |
| `1` | Failure (invalid input, missing dependency, or engine error) |

---

## How It Works

1. The OS context menu invokes `jebleskon` with `--action`, `--files`, and optionally `--out`.
2. `cmd/jebleskon/main.go` validates the flags and routes the call to the `internal/pdfengine`
   package.
3. The `merge`, `split`, and `img2pdf` actions are handled **entirely within the Go process** via
   the pdfcpu library. The `compress` and `convert-doc` actions spawn external processes (`gs` and
   `soffice`) via `os/exec`.
4. The final result is reported through the `internal/notifier` package (beeep library) as an OS
   desktop toast notification.

---

## Project Structure

```
jebleskon/
├── cmd/jebleskon/            # Entry point, flag parsing, and action routing
├── internal/pdfengine/       # Processing engines (merge, split, img2pdf, compress, convert-doc)
├── internal/notifier/        # Cross-platform desktop notification wrapper
├── os-integrator/
│   ├── windows/              # Registry file for the Explorer context menu
│   └── linux/
│       ├── dolphin.desktop   # KDE Dolphin service menu
│       ├── nautilus-scripts/ # Scripts for Nautilus and Nemo
│       └── thunar-uca.xml    # Custom actions for Thunar
├── install.sh                # Automated Linux installer
├── install.ps1               # Automated Windows installer
├── LICENSE                   # MIT License
└── PANDUAN-PENGGUNA.md       # End-user guide (actions, troubleshooting, FAQ)
```

---

## Development

```bash
go build ./...   # Compile all packages
go test ./...    # Run tests (includes pdfcpu round-trip: img2pdf → merge → split)
go vet ./...     # Static analysis
gofmt -l .       # Check formatting (empty output = all clean)
```

Tests do **not** require Ghostscript or LibreOffice. Those external engines are only invoked when
their respective actions are called at runtime.

---

## Known Limitations

- **Multi-file merge is not available from Windows Explorer.** The registry verb is registered on
  the `*` key, which only forwards a **single** file (`%1`). Compress, Split, and Convert work
  fine per-file. Multi-file merge from the context menu is only available on Linux (Dolphin uses
  `%F`; Nautilus/Nemo uses `$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS`), or by calling the CLI manually.
- **`compress` and `convert-doc` depend on external programs.** If `gs` or `soffice` is not on
  `PATH`, the action fails with a notification that names the missing dependency.
- **Document conversion uses LibreOffice only.** Microsoft Word COM automation is intentionally not
  implemented — it is Windows-only and adds heavy dependencies for work that LibreOffice already
  covers on both platforms.
- **Notifications require a desktop session.** D-Bus on Linux and the Windows Notification Platform
  on Windows must be running. In headless environments (e.g., pure SSH), notifications will not
  appear, but error messages are still printed to `stderr`.
- **`--action split` writes to a directory.** When using `--out`, point it to a directory, not a
  file path.
- **The Linux installer requires an internet connection** only if Go is not already installed (to
  download the Go tarball from go.dev). If Go is present, the build runs entirely offline.

---

## Contributing

Contributions are welcome. Please follow these steps:

1. Fork the repository and create a feature branch (`git checkout -b feat/your-feature`).
2. Make your changes. Keep the diff minimal — see `.amazonq/rules/AGENTS.md` for the coding
   philosophy this project follows.
3. Ensure all tests pass: `go test ./...`
4. Open a pull request with a clear description of the problem and solution.

Please open an issue before starting work on a large change, to avoid duplicated effort.

---

## License

Copyright (c) 2025 Mochammad Azmil Umur

Released under the [MIT License](LICENSE). See the `LICENSE` file for the full text.

Third-party dependencies are listed in `go.mod` and carry their own licenses.
