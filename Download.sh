#!/usr/bin/env bash
#
# Download.sh
# Linux replacement for the Windows-only Downloads.bat.
# Intended for Ubuntu 24.04 inside the remote Linux container.
#
set -Eeuo pipefail

log() {
  printf '[Download.sh] %s\n' "$*"
}

fail() {
  printf '[Download.sh] ERROR: %s\n' "$*" >&2
  exit 1
}

if [[ "$(id -u)" -eq 0 ]]; then
  SUDO=()
elif command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
  SUDO=(sudo -n)
else
  fail "This script needs root or passwordless sudo to install packages."
fi

if [[ ! -r /etc/os-release ]]; then
  fail "Cannot identify the Linux distribution."
fi

. /etc/os-release

if [[ "${ID:-}" != "ubuntu" ]]; then
  fail "This script is designed for Ubuntu; detected: ${PRETTY_NAME:-unknown}."
fi

log "Preparing user directories..."
mkdir -p "$HOME/Downloads" "$HOME/Projects" "$HOME/.local/bin"

log "Updating Ubuntu package indexes..."
"${SUDO[@]}" apt-get update

log "Installing Linux development and desktop-support utilities..."
"${SUDO[@]}" DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  zsh \
  fish \
  ripgrep \
  fd-find \
  bat \
  tree \
  fzf \
  neovim \
  p7zip-full \
  btop \
  cmake \
  ninja-build \
  clang \
  lldb

log "Creating convenient command aliases for Ubuntu package names..."
mkdir -p "$HOME/.local/bin"

if command -v fdfind >/dev/null 2>&1 && [[ ! -e "$HOME/.local/bin/fd" ]]; then
  ln -s "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

if command -v batcat >/dev/null 2>&1 && [[ ! -e "$HOME/.local/bin/bat" ]]; then
  ln -s "$(command -v batcat)" "$HOME/.local/bin/bat"
fi

if ! grep -Fq 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.profile" 2>/dev/null; then
  printf '\n# User-installed command-line tools\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$HOME/.profile"
fi

log "Installed tool versions:"
for tool in git curl wget zsh fish rg fzf nvim cmake clang; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf '  %-8s %s\n' "$tool" "$(command -v "$tool")"
  fi
done

log "Linux setup completed."
log "Directories: $HOME/Downloads and $HOME/Projects"
log "Note: This is a headless SSH container; Windows installers, .bat files, PowerShell scripts, and GUI-only setup tools are intentionally not run."
