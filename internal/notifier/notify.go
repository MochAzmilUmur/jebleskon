// Package notifier shows OS-level desktop notifications. Jebleskon is headless,
// so this is the only channel the user sees.
package notifier

import "github.com/gen2brain/beeep"

// appIcon is empty: the OS falls back to the application/default icon, which is
// good enough and avoids shipping per-platform icon assets.
const appIcon = ""

// Notify shows a normal toast for a completed operation.
func Notify(title, message string) error {
	return beeep.Notify(title, message, appIcon)
}

// Alert shows a higher-priority OS alert, used for failures.
func Alert(title, message string) error {
	return beeep.Alert(title, message, appIcon)
}
