#!/usr/bin/env bats

load test_helper/common

INSTALL_SCRIPT="${BATS_TEST_DIRNAME}/../install.sh"

setup() {
    setup_test_dir
    export FAKE_HOME="${TEST_DIR}/fakehome"
    mkdir -p "$FAKE_HOME"

    # Create a mock curl that copies the local findir script
    mkdir -p "${TEST_DIR}/bin"
    cat > "${TEST_DIR}/bin/curl" << 'MOCKCURL'
#!/usr/bin/env bash
# Mock curl: copy the local findir script to the -o target
output_file=""
for arg in "$@"; do
    if [ "$prev_was_o" = "1" ]; then
        output_file="$arg"
        prev_was_o=0
    fi
    if [ "$arg" = "-o" ]; then
        prev_was_o=1
    fi
done
if [ -n "$output_file" ] && [ -n "$FINDIR_SOURCE" ]; then
    cp "$FINDIR_SOURCE" "$output_file"
    exit 0
fi
exit 1
MOCKCURL
    chmod +x "${TEST_DIR}/bin/curl"

    export FINDIR_SOURCE="${BATS_TEST_DIRNAME}/../findir"
}

teardown() {
    teardown_test_dir
}

# Run install.sh with mocked HOME, PATH, and curl
run_installer() {
    local extra_path="${1:-}"
    local shell_override="${2:-/bin/bash}"
    local test_path="${TEST_DIR}/bin:/usr/local/bin:/usr/bin:/bin"
    if [ -n "$extra_path" ]; then
        test_path="${extra_path}:${test_path}"
    fi
    HOME="$FAKE_HOME" \
    PATH="$test_path" \
    SHELL="$shell_override" \
    bash "$INSTALL_SCRIPT" < /dev/null
}

@test "installs findir to ~/.local/bin" {
    run run_installer
    [ "$status" -eq 0 ]
    [ -f "${FAKE_HOME}/.local/bin/findir" ]
    [ -x "${FAKE_HOME}/.local/bin/findir" ]
}

@test "creates ~/.local/bin if it does not exist" {
    [ ! -d "${FAKE_HOME}/.local/bin" ]
    run run_installer
    [ "$status" -eq 0 ]
    [ -d "${FAKE_HOME}/.local/bin" ]
}

@test "reports success message with install path" {
    run run_installer
    [ "$status" -eq 0 ]
    assert_output_contains "findir installed to"
    assert_output_contains ".local/bin/findir"
}

@test "skips PATH prompt when ~/.local/bin is already in PATH" {
    mkdir -p "${FAKE_HOME}/.local/bin"
    run run_installer "${FAKE_HOME}/.local/bin"
    [ "$status" -eq 0 ]
    assert_output_contains "findir --help"
    assert_output_not_contains "not in your PATH"
}

@test "detects missing PATH and adds to .bashrc for bash" {
    run run_installer "" "/bin/bash"
    [ "$status" -eq 0 ]
    assert_output_contains "not in your PATH"
    assert_output_contains ".bashrc"
    [ -f "${FAKE_HOME}/.bashrc" ]
    assert_file_contains "${FAKE_HOME}/.bashrc" 'export PATH="$HOME/.local/bin:$PATH"'
}

@test "detects missing PATH and adds to .zshrc for zsh" {
    run run_installer "" "/bin/zsh"
    [ "$status" -eq 0 ]
    assert_output_contains ".zshrc"
    [ -f "${FAKE_HOME}/.zshrc" ]
    assert_file_contains "${FAKE_HOME}/.zshrc" 'export PATH="$HOME/.local/bin:$PATH"'
}

@test "detects missing PATH and adds to config.fish for fish" {
    run run_installer "" "/usr/bin/fish"
    [ "$status" -eq 0 ]
    assert_output_contains "config.fish"
    [ -f "${FAKE_HOME}/.config/fish/config.fish" ]
    assert_file_contains "${FAKE_HOME}/.config/fish/config.fish" "set -gx PATH"
}

@test "does not duplicate PATH export in existing profile" {
    mkdir -p "${FAKE_HOME}"
    echo 'export PATH="$HOME/.local/bin:$PATH"' > "${FAKE_HOME}/.bashrc"
    run run_installer "" "/bin/bash"
    [ "$status" -eq 0 ]
    assert_output_contains "already configured"
    # Count the export lines — should still be exactly one
    local count
    count=$(grep -cF 'export PATH="$HOME/.local/bin:$PATH"' "${FAKE_HOME}/.bashrc")
    [ "$count" -eq 1 ]
}

@test "installed binary is executable" {
    run run_installer "${FAKE_HOME}/.local/bin"
    [ "$status" -eq 0 ]
    run "${FAKE_HOME}/.local/bin/findir" --version
    [ "$status" -eq 0 ]
    [[ "$output" =~ [0-9]+\.[0-9]+\.[0-9]+ ]]
}
