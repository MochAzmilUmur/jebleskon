#!/usr/bin/env bash
# Jebleskon installer for Linux
# Supports: Debian/Ubuntu/Mint, Fedora/RHEL, Arch/Manjaro
# File managers: KDE Dolphin, GNOME Nautilus, Nemo, Thunar
#
# Penggunaan:
#   ./install.sh            — pasang
#   ./install.sh --uninstall — hapus
set -euo pipefail

BINARY_NAME="jebleskon"
INSTALL_DIR="$HOME/.local/bin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${CYAN}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC}   $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
die()     { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

# ── Detect package manager ────────────────────────────────────────────────────
detect_pm() {
    if   command -v apt-get &>/dev/null; then echo apt
    elif command -v dnf     &>/dev/null; then echo dnf
    elif command -v pacman  &>/dev/null; then echo pacman
    else echo unknown
    fi
}

install_pkg() {
    local pm="$1"; shift
    case "$pm" in
        apt)    sudo apt-get install -y "$@" ;;
        dnf)    sudo dnf install -y "$@" ;;
        pacman) sudo pacman -S --needed --noconfirm "$@" ;;
    esac
}

# ── Check / install Go ────────────────────────────────────────────────────────
ensure_go() {
    if command -v go &>/dev/null; then
        local ver; ver=$(go version | awk '{print $3}' | sed 's/go//')
        local major minor
        IFS='.' read -r major minor _ <<< "$ver"
        if (( major > 1 || (major == 1 && minor >= 26) )); then
            success "Go $ver sudah terpasang."
            return
        fi
        warn "Go $ver ditemukan, butuh ≥ 1.26. Mencoba memasang versi terbaru..."
    else
        info "Go tidak ditemukan. Memasang Go..."
    fi

    local pm; pm=$(detect_pm)
    case "$pm" in
        apt)
            # apt biasanya punya Go lama; pakai official tarball
            local GO_VER="1.24.3"
            local ARCH; ARCH=$(uname -m)
            [[ "$ARCH" == "x86_64" ]] && ARCH="amd64" || ARCH="arm64"
            local TAR="go${GO_VER}.linux-${ARCH}.tar.gz"
            info "Mengunduh Go $GO_VER..."
            curl -fsSL "https://go.dev/dl/$TAR" -o "/tmp/$TAR"
            sudo rm -rf /usr/local/go
            sudo tar -C /usr/local -xzf "/tmp/$TAR"
            rm "/tmp/$TAR"
            export PATH="/usr/local/go/bin:$PATH"
            # Tambahkan ke .bashrc / .zshrc jika belum ada
                    for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
                [[ -f "$rc" ]] || continue
                grep -q '/usr/local/go/bin' "$rc" && continue
                echo 'export PATH="/usr/local/go/bin:$PATH"' >> "$rc"
            done
            ;;
        dnf)    install_pkg dnf golang ;;
        pacman) install_pkg pacman go ;;
        *)      die "Tidak bisa memasang Go otomatis. Pasang Go 1.26+ dari https://go.dev/dl/ lalu jalankan ulang." ;;
    esac
    success "Go terpasang."
}

# ── Install external deps (optional, user-prompted) ──────────────────────────
install_deps() {
    local pm="$1"
    [[ "$pm" == "unknown" ]] && { warn "Package manager tidak dikenal, lewati instalasi dependensi."; return; }

    echo ""
    echo "Dependensi opsional:"
    echo "  • Ghostscript  — untuk aksi 'Compress PDF'"
    echo "  • LibreOffice  — untuk aksi 'Convert to PDF/DOCX'"
    echo ""
    read -rp "Pasang Ghostscript dan LibreOffice sekarang? [Y/n] " ans
    [[ "${ans,,}" == "n" ]] && { warn "Dilewati. Pasang manual jika diperlukan."; return; }

    info "Memasang Ghostscript dan LibreOffice..."
    case "$pm" in
        apt)    install_pkg apt ghostscript libreoffice ;;
        dnf)    install_pkg dnf ghostscript libreoffice ;;
        pacman) install_pkg pacman ghostscript libreoffice-fresh ;;
    esac
    success "Dependensi terpasang."
}

# ── Build binary ──────────────────────────────────────────────────────────────
build_binary() {
    info "Mengunduh modul Go..."
    (cd "$SCRIPT_DIR" && go mod download)
    info "Membangun binary jebleskon..."
    (cd "$SCRIPT_DIR" && go build -trimpath -ldflags "-s -w" -o "$SCRIPT_DIR/$BINARY_NAME" ./cmd/jebleskon)
    success "Binary berhasil dibangun."
}

# ── Install binary to PATH ────────────────────────────────────────────────────
install_binary() {
    mkdir -p "$INSTALL_DIR"
    cp "$SCRIPT_DIR/$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
    chmod +x "$INSTALL_DIR/$BINARY_NAME"

    # Pastikan ~/.local/bin ada di PATH
    for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
        [[ -f "$rc" ]] || continue
        grep -qF "$INSTALL_DIR" "$rc" && continue
        echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$rc"
        info "PATH diperbarui di $rc"
    done
    export PATH="$INSTALL_DIR:$PATH"
    success "Binary dipasang di $INSTALL_DIR/$BINARY_NAME"
}

# ── Detect file manager ───────────────────────────────────────────────────────
detect_fm() {
    # Cek yang sedang berjalan dulu
    for fm in dolphin nautilus nemo thunar; do
        pgrep -x "$fm" &>/dev/null && { echo "$fm"; return; }
    done
    # Fallback: cek yang terinstall
    for fm in dolphin nautilus nemo thunar; do
        command -v "$fm" &>/dev/null && { echo "$fm"; return; }
    done
    echo "unknown"
}

# ── Install KDE Dolphin service menu ─────────────────────────────────────────
install_dolphin() {
    # Plasma 6 pakai kio/servicemenus, Plasma 5 pakai kservices5/ServiceMenus
    local dest_dir="$HOME/.local/share/kio/servicemenus"
    if command -v kbuildsycoca6 &>/dev/null; then
        dest_dir="$HOME/.local/share/kio/servicemenus"
    elif command -v kbuildsycoca5 &>/dev/null; then
        dest_dir="$HOME/.local/share/kservices5/ServiceMenus"
    fi
    mkdir -p "$dest_dir"
    cp "$SCRIPT_DIR/os-integrator/linux/dolphin.desktop" "$dest_dir/jebleskon.desktop"
    chmod +x "$dest_dir/jebleskon.desktop"

    if command -v kbuildsycoca6 &>/dev/null; then
        kbuildsycoca6 --noincremental 2>/dev/null || true
    elif command -v kbuildsycoca5 &>/dev/null; then
        kbuildsycoca5 --noincremental 2>/dev/null || true
    fi
    success "Menu konteks Dolphin terpasang di $dest_dir"
}

# ── Install GNOME Nautilus / Nemo / Thunar script ────────────────────────────
install_nautilus() {
    local scripts_dir="$HOME/.local/share/nautilus/scripts"
    mkdir -p "$scripts_dir"
    cp "$SCRIPT_DIR/os-integrator/linux/nautilus-scripts/"* "$scripts_dir/"
    chmod +x "$scripts_dir"/Jebleskon*
    success "Skrip Nautilus terpasang di $scripts_dir"
    info "Di Nautilus: klik kanan file → Scripts → Jebleskon ..."
}

install_nemo() {
    local scripts_dir="$HOME/.local/share/nemo/scripts"
    mkdir -p "$scripts_dir"
    cp "$SCRIPT_DIR/os-integrator/linux/nautilus-scripts/"* "$scripts_dir/"
    chmod +x "$scripts_dir"/Jebleskon*
    success "Skrip Nemo terpasang di $scripts_dir"
}

install_thunar() {
    # Thunar pakai custom actions via XML
    local conf="$HOME/.config/Thunar/uca.xml"
    if [[ ! -f "$conf" ]]; then
        mkdir -p "$(dirname "$conf")"
        cat > "$conf" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<actions>
</actions>
EOF
    fi

    # Cek apakah sudah ada
    grep -q "Jebleskon" "$conf" && { warn "Thunar custom actions sudah ada, dilewati."; return; }

    # Sisipkan sebelum </actions>
    local actions_block
    actions_block=$(cat "$SCRIPT_DIR/os-integrator/linux/thunar-uca.xml")
    sed -i "s|</actions>|${actions_block}\n</actions>|" "$conf"
    success "Custom actions Thunar terpasang."
    info "Restart Thunar agar perubahan berlaku: thunar -q && thunar"
}

# ── Register .desktop for all file managers (generic fallback) ───────────────
install_desktop_entry() {
    local apps_dir="$HOME/.local/share/applications"
    mkdir -p "$apps_dir"
    cat > "$apps_dir/jebleskon.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Jebleskon
Comment=PDF & document tools
Exec=$INSTALL_DIR/$BINARY_NAME %F
Icon=application-pdf
Categories=Utility;
NoDisplay=true
MimeType=application/pdf;image/jpeg;image/png;application/msword;application/vnd.openxmlformats-officedocument.wordprocessingml.document;
EOF
    update-desktop-database "$apps_dir" 2>/dev/null || true
}

# ── Uninstall ────────────────────────────────────────────────────────────────
uninstall() {
    info "Menghapus Jebleskon..."
    rm -f "$INSTALL_DIR/$BINARY_NAME"

    rm -f "$HOME/.local/share/kio/servicemenus/jebleskon.desktop"
    rm -f "$HOME/.local/share/kservices5/ServiceMenus/jebleskon.desktop"
    rm -f "$HOME/.local/share/nautilus/scripts/Jebleskon"*
    rm -f "$HOME/.local/share/nemo/scripts/Jebleskon"*
    rm -f "$HOME/.local/share/applications/jebleskon.desktop"

    if [[ -f "$HOME/.config/Thunar/uca.xml" ]]; then
        # Hapus blok <action> Jebleskon dari uca.xml
        python3 -c "
import xml.etree.ElementTree as ET
tree = ET.parse('$HOME/.config/Thunar/uca.xml')
root = tree.getroot()
for a in root.findall('action'):
    uid = a.findtext('unique-id', '')
    if uid.startswith('jebleskon-'):
        root.remove(a)
tree.write('$HOME/.config/Thunar/uca.xml', xml_declaration=True, encoding='UTF-8')
" 2>/dev/null || warn "Tidak bisa membersihkan uca.xml Thunar secara otomatis, hapus manual."
    fi

    success "Jebleskon berhasil dihapus."
    exit 0
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║        Jebleskon Installer           ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"
    echo ""

    local pm; pm=$(detect_pm)
    info "Package manager terdeteksi: ${pm}"

    ensure_go
    install_deps "$pm"
    build_binary
    install_binary

    # Deteksi file manager dan pasang integrasi yang sesuai
    local fm; fm=$(detect_fm)
    info "File manager terdeteksi: ${fm}"

    case "$fm" in
        dolphin)
            install_dolphin
            ;;
        nautilus)
            install_nautilus
            install_desktop_entry
            ;;
        nemo)
            install_nemo
            install_desktop_entry
            ;;
        thunar)
            install_thunar
            install_desktop_entry
            ;;
        *)
            warn "File manager tidak dikenal. Memasang untuk semua yang tersedia..."
            command -v dolphin  &>/dev/null && install_dolphin
            command -v nautilus &>/dev/null && install_nautilus
            command -v nemo     &>/dev/null && install_nemo
            command -v thunar   &>/dev/null && install_thunar
            install_desktop_entry
            ;;
    esac

    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  Instalasi selesai!                                  ║${NC}"
    echo -e "${GREEN}║  Klik kanan file PDF/gambar/dokumen untuk memulai.   ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
    warn "Buka ulang sesi terminal atau jalankan: source ~/.bashrc"
    warn "Jika menu konteks belum muncul, logout dan login kembali."
}

# Tangani flag --uninstall sebelum masuk main
for arg in "$@"; do
    [[ "$arg" == "--uninstall" ]] && uninstall
done

main "$@"
