# Jebleskon Installer for Windows
# Jalankan di PowerShell sebagai Administrator:
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\install.ps1

#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Warna helper ──────────────────────────────────────────────────────────────
function Write-Info   { param($msg) Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Ok     { param($msg) Write-Host "[OK]   $msg" -ForegroundColor Green }
function Write-Warn   { param($msg) Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Fail   { param($msg) Write-Host "[ERROR] $msg" -ForegroundColor Red; exit 1 }

# ── Konstanta ─────────────────────────────────────────────────────────────────
$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$InstallDir = "C:\Tools\jebleskon"
$ExePath    = "$InstallDir\jebleskon.exe"

# ── Cek hak Administrator ─────────────────────────────────────────────────────
function Assert-Admin {
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Fail "Jalankan PowerShell sebagai Administrator (klik kanan → Run as administrator)."
    }
}

# ── Cek / pasang Go ───────────────────────────────────────────────────────────
function Ensure-Go {
    $goCmd = Get-Command go -ErrorAction SilentlyContinue
    if ($goCmd) {
        $ver = (go version) -replace 'go version go(\S+).*','$1'
        $parts = $ver -split '\.'
        if ([int]$parts[0] -gt 1 -or ([int]$parts[0] -eq 1 -and [int]$parts[1] -ge 26)) {
            Write-Ok "Go $ver sudah terpasang."
            return
        }
        Write-Warn "Go $ver ditemukan, butuh >= 1.26."
    } else {
        Write-Info "Go tidak ditemukan."
    }

    # Coba via winget
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Info "Memasang Go via winget..."
        winget install --id GoLang.Go --silent --accept-package-agreements --accept-source-agreements
        # Refresh PATH di sesi ini
        $env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' +
                    [System.Environment]::GetEnvironmentVariable('Path','User')
        Write-Ok "Go terpasang."
    } else {
        Write-Warn "winget tidak tersedia."
        Write-Warn "Unduh dan pasang Go 1.26+ dari: https://go.dev/dl/"
        Write-Warn "Setelah selesai, jalankan ulang skrip ini."
        exit 1
    }
}

# ── Cek dependensi opsional ───────────────────────────────────────────────────
function Check-OptionalDeps {
    Write-Host ""
    Write-Host "Memeriksa dependensi opsional..." -ForegroundColor Cyan

    $gsOk  = [bool](Get-Command gs      -ErrorAction SilentlyContinue)
    $soOk  = [bool](Get-Command soffice -ErrorAction SilentlyContinue)

    if ($gsOk)  { Write-Ok "Ghostscript (gs) ditemukan." }
    else        { Write-Warn "Ghostscript tidak ditemukan. Aksi 'Compress PDF' tidak akan berfungsi." }

    if ($soOk)  { Write-Ok "LibreOffice (soffice) ditemukan." }
    else        { Write-Warn "LibreOffice tidak ditemukan. Aksi 'Convert to PDF/DOCX' tidak akan berfungsi." }

    if (-not $gsOk -or -not $soOk) {
        Write-Host ""
        Write-Host "  Ghostscript : https://www.ghostscript.com/releases/gsdnld.html" -ForegroundColor Yellow
        Write-Host "  LibreOffice : https://www.libreoffice.org/download/libreoffice-fresh/" -ForegroundColor Yellow
        Write-Host "  Setelah memasang, pastikan folder 'bin'-nya ada di PATH." -ForegroundColor Yellow
    }
}

# ── Build binary ──────────────────────────────────────────────────────────────
function Build-Binary {
    Write-Info "Mengunduh modul Go..."
    Push-Location $ScriptDir
    try {
        go mod download
        Write-Info "Membangun jebleskon.exe..."
        go build -trimpath -ldflags "-s -w" -o "$ScriptDir\jebleskon.exe" .\cmd\jebleskon
        Write-Ok "Binary berhasil dibangun."
    } finally {
        Pop-Location
    }
}

# ── Pasang binary ke PATH ─────────────────────────────────────────────────────
function Install-Binary {
    if (-not (Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir | Out-Null
    }
    Copy-Item "$ScriptDir\jebleskon.exe" $ExePath -Force
    Write-Ok "Binary dipasang di $ExePath"

    # Tambahkan ke PATH user jika belum ada
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if ($userPath -notlike "*$InstallDir*") {
        [Environment]::SetEnvironmentVariable('Path', "$userPath;$InstallDir", 'User')
        $env:Path += ";$InstallDir"
        Write-Ok "PATH diperbarui (User): $InstallDir"
    } else {
        Write-Info "PATH sudah mengandung $InstallDir"
    }
}

# ── Tulis registry menu konteks ───────────────────────────────────────────────
function Install-ContextMenu {
    Write-Info "Mendaftarkan menu konteks Windows Explorer..."

    $exe = $ExePath -replace '\\', '\\'   # escape untuk registry string

    # Helper: buat key + set nilai default
    function Set-RegKey { param($path, $name, $value)
        if (-not (Test-Path "Registry::$path")) {
            New-Item -Path "Registry::$path" -Force | Out-Null
        }
        if ($name -eq '(Default)') {
            Set-ItemProperty -Path "Registry::$path" -Name '(Default)' -Value $value
        } else {
            New-ItemProperty -Path "Registry::$path" -Name $name -Value $value -Force | Out-Null
        }
    }

    # Root cascade pada semua file
    $root = 'HKEY_CLASSES_ROOT\*\shell\Jebleskon'
    Set-RegKey $root 'MUIVerb' 'Jebleskon'
    Set-RegKey $root 'SubCommands' ''
    Set-RegKey $root 'Icon' 'shell32.dll,71'

    # Compress
    Set-RegKey "$root\shell\01compress" 'MUIVerb' 'Compress PDF'
    Set-RegKey "$root\shell\01compress" 'Icon' $ExePath
    Set-RegKey "$root\shell\01compress\command" '(Default)' "`"$ExePath`" --action compress --files `"%1`""

    # Split
    Set-RegKey "$root\shell\02split" 'MUIVerb' 'Split PDF into pages'
    Set-RegKey "$root\shell\02split" 'Icon' $ExePath
    Set-RegKey "$root\shell\02split\command" '(Default)' "`"$ExePath`" --action split --files `"%1`""

    # Convert
    Set-RegKey "$root\shell\03convert" 'MUIVerb' 'Convert to PDF / DOCX'
    Set-RegKey "$root\shell\03convert" 'Icon' $ExePath
    Set-RegKey "$root\shell\03convert\command" '(Default)' "`"$ExePath`" --action convert-doc --files `"%1`""

    # PDF-specific submenu
    $pdfRoot = 'HKEY_CLASSES_ROOT\SystemFileAssociations\.pdf\shell\Jebleskon'
    Set-RegKey $pdfRoot 'MUIVerb' 'Jebleskon'
    Set-RegKey $pdfRoot 'SubCommands' ''
    Set-RegKey $pdfRoot 'Icon' 'shell32.dll,71'

    Set-RegKey "$pdfRoot\shell\01compress" 'MUIVerb' 'Compress PDF'
    Set-RegKey "$pdfRoot\shell\01compress\command" '(Default)' "`"$ExePath`" --action compress --files `"%1`""

    Set-RegKey "$pdfRoot\shell\02split" 'MUIVerb' 'Split PDF into pages'
    Set-RegKey "$pdfRoot\shell\02split\command" '(Default)' "`"$ExePath`" --action split --files `"%1`""

    Set-RegKey "$pdfRoot\shell\03convert" 'MUIVerb' 'Convert to PDF / DOCX'
    Set-RegKey "$pdfRoot\shell\03convert\command" '(Default)' "`"$ExePath`" --action convert-doc --files `"%1`""

    Write-Ok "Menu konteks Windows Explorer terdaftar."
}

# ── Uninstall helper (opsional, panggil dengan -Uninstall) ────────────────────
function Uninstall {
    Write-Info "Menghapus Jebleskon..."
    reg delete "HKEY_CLASSES_ROOT\*\shell\Jebleskon" /f 2>$null
    reg delete "HKEY_CLASSES_ROOT\SystemFileAssociations\.pdf\shell\Jebleskon" /f 2>$null

    if (Test-Path $InstallDir) { Remove-Item $InstallDir -Recurse -Force }

    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $newPath  = ($userPath -split ';' | Where-Object { $_ -ne $InstallDir }) -join ';'
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')

    Write-Ok "Jebleskon berhasil dihapus."
    exit 0
}

# ── Main ──────────────────────────────────────────────────────────────────────
param([switch]$Uninstall)

Write-Host ""
Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        Jebleskon Installer           ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Assert-Admin

if ($Uninstall) { Uninstall }

Ensure-Go
Check-OptionalDeps
Build-Binary
Install-Binary
Install-ContextMenu

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  Instalasi selesai!                                  ║" -ForegroundColor Green
Write-Host "║  Klik kanan file PDF/dokumen di Explorer untuk       ║" -ForegroundColor Green
Write-Host "║  melihat menu Jebleskon.                             ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Warn "Buka ulang File Explorer agar menu konteks muncul."
Write-Warn "Untuk menghapus: .\install.ps1 -Uninstall"
