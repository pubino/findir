# tests/test_helper/common.bash — Shared fixtures and helpers for findir tests

# Path to findir under test
export FINDIR="${BATS_TEST_DIRNAME}/../findir"

# Create a fresh temp directory for each test
setup_test_dir() {
    export TEST_DIR
    TEST_DIR="$(mktemp -d)"
    export ORIGINAL_DIR
    ORIGINAL_DIR="$(pwd)"
    cd "$TEST_DIR"
}

# Clean up temp directory after each test
teardown_test_dir() {
    cd "$ORIGINAL_DIR"
    rm -rf "$TEST_DIR"
}

# Create a text file with given content
create_file() {
    local path="$1"
    local content="${2:-}"
    local dir
    dir=$(dirname "$path")
    mkdir -p "$dir"
    printf '%s' "$content" > "$path"
}

# Create a binary file
create_binary_file() {
    local path="$1"
    local dir
    dir=$(dirname "$path")
    mkdir -p "$dir"
    printf '\x00\x01\x02\x03\x89PNG' > "$path"
}

# Assert file content equals expected string
assert_file_content() {
    local path="$1"
    local expected="$2"
    local actual
    actual=$(cat "$path")
    [[ "$actual" == "$expected" ]] || {
        echo "Expected file content: '$expected'"
        echo "Actual file content:   '$actual'"
        return 1
    }
}

# Assert file contains a substring
assert_file_contains() {
    local path="$1"
    local expected="$2"
    grep -qF -- "$expected" "$path" || {
        echo "Expected '$path' to contain: '$expected'"
        echo "Actual content: $(cat "$path")"
        return 1
    }
}

# Assert output contains a substring (works with $output from bats run)
assert_output_contains() {
    local expected="$1"
    [[ "$output" == *"$expected"* ]] || {
        echo "Expected output to contain: '$expected'"
        echo "Actual output: $output"
        return 1
    }
}

# Assert output does NOT contain a substring
assert_output_not_contains() {
    local expected="$1"
    [[ "$output" != *"$expected"* ]] || {
        echo "Expected output NOT to contain: '$expected'"
        echo "Actual output: $output"
        return 1
    }
}

# Count occurrences of a string in a file
count_occurrences() {
    local path="$1"
    local string="$2"
    grep -oF -- "$string" "$path" 2>/dev/null | wc -l | tr -d ' '
}

# Strip ANSI escape codes from a string
strip_ansi() {
    # Use perl for reliable ANSI stripping (works on macOS and Linux)
    perl -pe 's/\e\[[0-9;]*m//g; s/\e\([A-Z]//g'
}
