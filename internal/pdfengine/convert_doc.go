package pdfengine

import (
	"context"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// ConvertDoc converts between office documents and PDF with headless LibreOffice.
// Non-PDF input becomes PDF; PDF input becomes DOCX.
//
// Why only LibreOffice: driving MS Word headless means COM automation (Windows-only,
// cgo/ole dependency) for a path LibreOffice already covers on both platforms.
// Add the Word path only if a machine genuinely lacks LibreOffice.
func ConvertDoc(ctx context.Context, file, out string) error {
	soffice, err := findSoffice()
	if err != nil {
		return err
	}

	ext := strings.ToLower(filepath.Ext(file))
	target := "pdf"
	if ext == ".pdf" {
		target = "docx"
	}

	// LibreOffice names the result after the input and writes it to outDir,
	// so convert into a temp dir and move only when we know the real name.
	tmp, err := os.MkdirTemp("", "jebleskon-")
	if err != nil {
		return err
	}
	defer os.RemoveAll(tmp)

	cmd := exec.CommandContext(ctx, soffice,
		"--headless", "--norestore",
		"--convert-to", target,
		"--outdir", tmp,
		file,
	)
	if msg, err := cmd.CombinedOutput(); err != nil {
		return fmt.Errorf("libreoffice: %w: %s", err, msg)
	}

	produced := filepath.Join(tmp, strings.TrimSuffix(filepath.Base(file), ext)+"."+target)
	if _, err := os.Stat(produced); err != nil {
		return fmt.Errorf("libreoffice produced no output for %s: %w", file, err)
	}
	return os.Rename(produced, out)
}

// findSoffice locates the LibreOffice binary under either of its common names.
func findSoffice() (string, error) {
	for _, name := range []string{"soffice", "libreoffice"} {
		if p, err := exec.LookPath(name); err == nil {
			return p, nil
		}
	}
	return "", fmt.Errorf("libreoffice (soffice) not found on PATH")
}
