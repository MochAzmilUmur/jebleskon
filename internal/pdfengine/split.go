package pdfengine

import (
	"context"
	"os"

	"github.com/pdfcpu/pdfcpu/pkg/api"
	"github.com/pdfcpu/pdfcpu/pkg/pdfcpu/model"
)

// Split writes one single-page PDF per page of file into outDir.
func Split(ctx context.Context, file, outDir string) error {
	if err := os.MkdirAll(outDir, 0o755); err != nil {
		return err
	}
	// span=1 -> a new output file every page.
	return api.SplitFile(ctx, file, outDir, 1, model.NewDefaultConfiguration())
}
