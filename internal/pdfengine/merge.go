package pdfengine

import (
	"context"

	"github.com/pdfcpu/pdfcpu/pkg/api"
	"github.com/pdfcpu/pdfcpu/pkg/pdfcpu/model"
)

// Merge appends every PDF in files into a single PDF at out, in the given order.
func Merge(ctx context.Context, files []string, out string) error {
	// dividerPage=false: no blank separator pages between documents.
	return api.MergeCreateFile(ctx, files, out, false, model.NewDefaultConfiguration())
}
