#!/usr/bin/env bats

load test_helper/common

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

@test "--no-color disables color codes" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color --danger -y "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    # Output should not contain ANSI escape codes
    local stripped
    stripped=$(printf '%s' "$output" | strip_ansi)
    [ "$output" = "$stripped" ]
}

@test "NO_COLOR env var disables colors" {
    create_file "test.txt" "hello world"
    run env NO_COLOR=1 "$FINDIR" --danger -y "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    local stripped
    stripped=$(printf '%s' "$output" | strip_ansi)
    [ "$output" = "$stripped" ]
}

@test "FINDIR_NO_COLOR=1 disables colors" {
    create_file "test.txt" "hello world"
    run env FINDIR_NO_COLOR=1 "$FINDIR" --danger -y "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    local stripped
    stripped=$(printf '%s' "$output" | strip_ansi)
    [ "$output" = "$stripped" ]
}

@test "TERM=dumb disables colors" {
    create_file "test.txt" "hello world"
    run env TERM=dumb "$FINDIR" --danger -y "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    local stripped
    stripped=$(printf '%s' "$output" | strip_ansi)
    [ "$output" = "$stripped" ]
}

@test "piped output has no colors (non-TTY)" {
    create_file "test.txt" "hello world"
    # When piped through cat, stdout is not a TTY
    run bash -c "\"$FINDIR\" --danger -y 'hello' 'goodbye' '$TEST_DIR' | cat"
    [ "$status" -eq 0 ]
    local stripped
    stripped=$(printf '%s' "$output" | strip_ansi)
    [ "$output" = "$stripped" ]
}

@test "dry run output shows diff markers without color" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color --dry-run "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_output_contains "-hello"
    assert_output_contains "+goodbye"
}
