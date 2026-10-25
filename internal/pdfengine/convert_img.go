package pdfengine

import (
	"context"

	"github.com/pdfcpu/pdfcpu/pkg/api"
	"github.com/pdfcpu/pdfcpu/pkg/pdfcpu"
	"github.com/pdfcpu/pdfcpu/pkg/pdfcpu/model"
)

// ImagesToPDF appends each JPG/PNG in files as a full page of a new PDF at out.
func ImagesToPDF(ctx context.Context, files []string, out string) error {
	return api.ImportImagesFile(ctx, files, out, pdfcpu.DefaultImportConfig(), model.NewDefaultConfiguration())
}
