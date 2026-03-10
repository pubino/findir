#!/usr/bin/env bash
# findir installer — curl -fsSL https://raw.githubusercontent.com/pubino/findir/main/install.sh | bash
set -euo pipefail

REPO="pubino/findir"
RAW_URL="https://raw.githubusercontent.com/${REPO}/main/findir"
INSTALL_DIR="${HOME}/.local/bin"

# Detect the user's shell profile file
detect_profile() {
    local shell_name
    shell_name="$(basename "${SHELL:-/bin/bash}")"

    case "$shell_name" in
        zsh)  echo "${HOME}/.zshrc" ;;
        fish) echo "${HOME}/.config/fish/config.fish" ;;
        *)    echo "${HOME}/.bashrc" ;;
    esac
}

# Build the PATH export line appropriate for the shell
path_export_line() {
    local shell_name
    shell_name="$(basename "${SHELL:-/bin/bash}")"

    case "$shell_name" in
        fish) echo "set -gx PATH ${HOME}/.local/bin \$PATH" ;;
        *)    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" ;;
    esac
}

# Check if INSTALL_DIR is already in PATH
check_path() {
    case ":${PATH}:" in
        *":${INSTALL_DIR}:"*) return 0 ;;
        *)                    return 1 ;;
    esac
}

# Prompt user to add INSTALL_DIR to their shell profile
prompt_path_setup() {
    local profile
    profile="$(detect_profile)"
    local export_line
    export_line="$(path_export_line)"

    # Check if the export line is already in the profile
    if [ -f "$profile" ] && grep -qF "$export_line" "$profile" 2>/dev/null; then
        echo "${INSTALL_DIR} is already configured in ${profile}."
        echo "Open a new terminal or run: source ${profile}"
        return
    fi

    echo ""
    echo "${INSTALL_DIR} is not in your PATH."

    # If not running interactively (piped install), add automatically
    if [ ! -t 0 ]; then
        mkdir -p "$(dirname "$profile")"
        echo "" >> "$profile"
        echo "$export_line" >> "$profile"
        echo "Added to ${profile}."
        echo "Open a new terminal or run: source ${profile}"
        return
    fi

    printf "Add it to %s? [Y/n] " "$profile"
    local answer
    read -r answer </dev/tty
    case "$answer" in
        [nN]|[nN][oO])
            echo ""
            echo "To add it manually, append this to your shell profile:"
            echo "  ${export_line}"
            ;;
        *)
            mkdir -p "$(dirname "$profile")"
            echo "" >> "$profile"
            echo "$export_line" >> "$profile"
            echo "Added to ${profile}."
            echo "Open a new terminal or run: source ${profile}"
            ;;
    esac
}

main() {
    echo "Installing findir..."

    mkdir -p "$INSTALL_DIR"

    local tmpfile
    tmpfile=$(mktemp)

    if ! curl -fsSL "$RAW_URL" -o "$tmpfile"; then
        echo "Error: Failed to download findir" >&2
        rm -f "$tmpfile"
        exit 1
    fi

    chmod +x "$tmpfile"
    mv "$tmpfile" "${INSTALL_DIR}/findir"

    echo "findir installed to ${INSTALL_DIR}/findir"

    if check_path; then
        echo "Run 'findir --help' to get started."
    else
        prompt_path_setup
    fi
}

main
