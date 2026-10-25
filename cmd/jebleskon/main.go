// Command jebleskon is a headless CLI for local document and PDF work, meant to be
// invoked from OS context menus. It has no GUI: results and errors are reported
// through desktop notifications.
package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/ming/jebleskon/internal/notifier"
	"github.com/ming/jebleskon/internal/pdfengine"
)

const (
	appName    = "Jebleskon"
	appVersion = "v1.0.0"
)

func main() {
	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "Usage: jebleskon --action <action> --files <file1,file2,...> [--out <output>]\n\n")
		fmt.Fprintf(os.Stderr, "A headless CLI for local PDF and document processing.\n")
		fmt.Fprintf(os.Stderr, "Results and errors are reported via desktop notifications.\n\n")
		fmt.Fprintf(os.Stderr, "Options:\n")
		flag.PrintDefaults()
		fmt.Fprintf(os.Stderr, "\nActions:\n")
		fmt.Fprintf(os.Stderr, "  merge        Merge two or more PDFs into one (input order preserved)\n")
		fmt.Fprintf(os.Stderr, "  split        Split a PDF into one file per page\n")
		fmt.Fprintf(os.Stderr, "  img2pdf      Convert JPG/PNG images into a multi-page PDF\n")
		fmt.Fprintf(os.Stderr, "  compress     Shrink a PDF using Ghostscript (requires: gs)\n")
		fmt.Fprintf(os.Stderr, "  convert-doc  Convert DOC/DOCX/ODT <-> PDF using LibreOffice (requires: soffice)\n")
		fmt.Fprintf(os.Stderr, "\nExamples:\n")
		fmt.Fprintf(os.Stderr, "  jebleskon --action merge   --files \"a.pdf,b.pdf\" --out merged.pdf\n")
		fmt.Fprintf(os.Stderr, "  jebleskon --action split   --files report.pdf --out ./pages/\n")
		fmt.Fprintf(os.Stderr, "  jebleskon --action img2pdf --files \"scan1.jpg,scan2.png\"\n")
		fmt.Fprintf(os.Stderr, "  jebleskon --action compress     --files big.pdf\n")
		fmt.Fprintf(os.Stderr, "  jebleskon --action convert-doc  --files doc.docx\n")
	}

	version := flag.Bool("version", false, "Print version and exit")
	v := flag.Bool("v", false, "Print version and exit (shorthand)")
	action := flag.String("action", "", "Action to run: merge | split | img2pdf | compress | convert-doc")
	files := flag.String("files", "", "Comma-separated input file paths")
	out := flag.String("out", "", "Output file path, or output directory for --action split")
	flag.Parse()

	if *version || *v {
		fmt.Printf("%s %s\n", appName, appVersion)
		os.Exit(0)
	}

	if *action == "" || *files == "" {
		flag.Usage()
		os.Exit(1)
	}

	msg, err := run(*action, splitFiles(*files), *out)
	if err != nil {
		// A failed notification must not hide the real error, which still goes to stderr.
		_ = notifier.Alert(appName, err.Error())
		fmt.Fprintf(os.Stderr, "%s: %v\n", appName, err)
		os.Exit(1)
	}
	_ = notifier.Notify(appName, msg)
}

// run routes action to the matching engine and returns the success message.
func run(action string, files []string, out string) (string, error) {
	if len(files) == 0 {
		return "", errors.New("no input files given")
	}

	ctx := context.Background()
	switch action {
	case "merge":
		if len(files) < 2 {
			return "", errors.New("merge needs at least two PDFs")
		}
		dest := orDefault(out, filepath.Join(filepath.Dir(files[0]), "merged.pdf"))
		return "Merge successful!", pdfengine.Merge(ctx, files, dest)

	case "img2pdf":
		dest := orDefault(out, filepath.Join(filepath.Dir(files[0]), "images.pdf"))
		return "Images converted to PDF!", pdfengine.ImagesToPDF(ctx, files, dest)

	case "compress":
		dest := orDefault(out, withSuffix(files[0], "_compressed", ".pdf"))
		return "Compression successful!", pdfengine.Compress(ctx, files[0], dest)

	case "split":
		return "Split successful!", pdfengine.Split(ctx, files[0], orDefault(out, filepath.Dir(files[0])))

	case "convert-doc":
		dest := orDefault(out, swapExt(files[0], ".pdf"))
		return "Conversion successful!", pdfengine.ConvertDoc(ctx, files[0], dest)

	default:
		return "", fmt.Errorf("unknown action %q", action)
	}
}

// splitFiles splits the context-menu argument list, dropping empty entries.
//
// shortcut: --files is comma-separated with no escaping, so a path containing a
// comma cannot be passed. Context-menu invocation never hits this; if shell users
// need it, switch to a repeatable flag (-files per path) or accept a list file.
func splitFiles(csv string) []string {
	var files []string
	for _, f := range strings.Split(csv, ",") {
		if f = strings.TrimSpace(f); f != "" {
			files = append(files, f)
		}
	}
	return files
}

func orDefault(out, fallback string) string {
	if out == "" {
		return fallback
	}
	return out
}

// withSuffix inserts suffix before ext: "a.pdf", "_c", ".pdf" -> "a_c.pdf".
func withSuffix(file, suffix, ext string) string {
	return strings.TrimSuffix(file, filepath.Ext(file)) + suffix + ext
}

// swapExt replaces the input's extension with ext.
func swapExt(file, ext string) string {
	return strings.TrimSuffix(file, filepath.Ext(file)) + ext
}
