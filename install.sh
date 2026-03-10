#!/usr/bin/env bash
# findir installer — curl -fsSL https://raw.githubusercontent.com/pubino/findir/main/install.sh | bash
set -euo pipefail

REPO="pubino/findir"
RAW_URL="https://raw.githubusercontent.com/${REPO}/main/findir"
INSTALL_DIR="/usr/local/bin"

main() {
    echo "Installing findir..."

    local tmpfile
    tmpfile=$(mktemp)

    if ! curl -fsSL "$RAW_URL" -o "$tmpfile"; then
        echo "Error: Failed to download findir" >&2
        rm -f "$tmpfile"
        exit 1
    fi

    chmod +x "$tmpfile"

    if [[ -w "$INSTALL_DIR" ]]; then
        mv "$tmpfile" "${INSTALL_DIR}/findir"
    else
        echo "Installing to ${INSTALL_DIR} (requires sudo)..."
        sudo mv "$tmpfile" "${INSTALL_DIR}/findir"
    fi

    echo "findir installed successfully!"
    echo "Run 'findir --help' to get started."
}

main
