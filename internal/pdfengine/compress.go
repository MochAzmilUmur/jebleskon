package pdfengine

import (
	"context"
	"fmt"
	"os/exec"
)

// Compress shrinks a PDF with Ghostscript's /screen preset (72 dpi images),
// which is the smallest of the built-in presets. It needs the `gs` binary on PATH.
func Compress(ctx context.Context, file, out string) error {
	if _, err := exec.LookPath("gs"); err != nil {
		return fmt.Errorf("ghostscript (gs) not found on PATH: %w", err)
	}
	cmd := exec.CommandContext(ctx, "gs",
		"-sDEVICE=pdfwrite",
		"-dCompatibilityLevel=1.4",
		"-dPDFSETTINGS=/screen",
		"-dNOPAUSE", "-dQUIET", "-dBATCH",
		"-sOutputFile="+out,
		file,
	)
	if msg, err := cmd.CombinedOutput(); err != nil {
		return fmt.Errorf("ghostscript: %w: %s", err, msg)
	}
	return nil
}
