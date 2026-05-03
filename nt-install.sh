#!/usr/bin/env bash
set -euo pipefail

# nt-manager installer
# Usage: curl -fsSL https://raw.githubusercontent.com/vadzim/nt-manager/main/nt-install.sh | bash

INSTALL_DIR="${NT_HOME:-${HOME}/.local/nt}"
BIN_DIR="${INSTALL_DIR}/bin"
SCRIPT_URL="https://raw.githubusercontent.com/vadzim/nt-manager/main/nt"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  nt-manager installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Installing to: ${INSTALL_DIR}"
echo ""

# Detect download tool
if command -v curl >/dev/null 2>&1; then
    DOWNLOAD_CMD="curl -fsSL"
elif command -v wget >/dev/null 2>&1; then
    DOWNLOAD_CMD="wget -qO-"
else
    echo "✗ curl or wget is required"
    exit 1
fi

# Create directories
mkdir -p "${BIN_DIR}"

# Download nt script
echo "→ downloading nt script..."
if ! $DOWNLOAD_CMD "${SCRIPT_URL}" > "${BIN_DIR}/nt"; then
    echo "✗ failed to download nt script"
    exit 1
fi

chmod +x "${BIN_DIR}/nt"

echo "✓ nt installed to ${BIN_DIR}/nt"
echo ""

# Check if already in PATH
if [[ ":${PATH}:" == *":${BIN_DIR}:"* ]]; then
    echo "✓ ${BIN_DIR} is already in PATH"
else
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Add to your shell profile:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  export PATH=\"${BIN_DIR}:\$PATH\""
    echo ""
    
    # Detect shell and suggest config file
    if [[ -n "${BASH_VERSION:-}" ]]; then
        echo "For Bash, add to ~/.bashrc:"
        echo "  echo 'export PATH=\"${BIN_DIR}:\$PATH\"' >> ~/.bashrc"
        echo "  source ~/.bashrc"
    elif [[ -n "${ZSH_VERSION:-}" ]]; then
        echo "For Zsh, add to ~/.zshrc:"
        echo "  echo 'export PATH=\"${BIN_DIR}:\$PATH\"' >> ~/.zshrc"
        echo "  source ~/.zshrc"
    else
        echo "Add the export line to your shell's config file and reload it."
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Installation complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Try it out:"
echo "  nt install cowsay"
echo "  cowsay 'Hello from nt!'"
echo ""
