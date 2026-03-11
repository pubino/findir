#!/usr/bin/env bats

load test_helper/common

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

@test "dry run does not modify files" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color --dry-run "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "hello world"
}

@test "dry run shows diff output" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color --dry-run "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_output_contains "-hello world"
    assert_output_contains "+goodbye world"
}

@test "dry run shows dry run banner" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color --dry-run "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_output_contains "DRY RUN"
}

@test "dry run with -n flag" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color -n "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "hello world"
    assert_output_contains "DRY RUN"
}

@test "dry run does not create backup directory" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color --dry-run "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ ! -d ".findir-backups" ]
}

@test "dry run summary indicates no files modified" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color --dry-run "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_output_contains "dry run"
    assert_output_contains "no files were modified"
}

@test "dry run shows multiple file diffs" {
    create_file "a.txt" "hello a"
    create_file "b.txt" "hello b"
    run "$FINDIR" --no-color --dry-run "hello" "bye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_output_contains "a.txt"
    assert_output_contains "b.txt"
}

# ─── Default preview+prompt behavior ────────────────────────────────────────────

@test "default mode shows preview and does not modify files" {
    create_file "test.txt" "hello world"
    # Without a TTY, prompt_apply read fails and defaults to decline
    run "$FINDIR" --no-color --danger "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "hello world"
    assert_output_contains "PREVIEW"
    assert_output_contains "No changes applied"
}

@test "default mode shows diff in preview" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color --danger "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_output_contains "-hello world"
    assert_output_contains "+goodbye world"
}

@test "--yes skips preview and applies immediately" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color --danger -y "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "goodbye world"
    assert_output_not_contains "PREVIEW"
}

@test "-y flag applies changes immediately" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color --danger -y "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "goodbye world"
}

@test "--yes flag is documented in help" {
    run "$FINDIR" --help
    [ "$status" -eq 0 ]
    assert_output_contains -- "--yes"
}

# ─── --summary flag ──────────────────────────────────────────────────────────

@test "--summary with dry-run shows file list without diffs" {
    create_file "a.txt" "hello a"
    create_file "b.txt" "hello b"
    run "$FINDIR" --no-color --dry-run --summary "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_output_contains "a.txt"
    assert_output_contains "b.txt"
    assert_output_not_contains "-hello"
    assert_output_not_contains "+goodbye"
}

@test "--summary with default mode shows file list without diffs" {
    create_file "a.txt" "hello a"
    create_file "b.txt" "hello b"
    run "$FINDIR" --no-color --danger --summary "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_output_contains "a.txt"
    assert_output_contains "b.txt"
    assert_output_not_contains "-hello"
    assert_output_not_contains "+goodbye"
    assert_output_contains "No changes applied"
}

@test "--summary flag is documented in help" {
    run "$FINDIR" --help
    [ "$status" -eq 0 ]
    assert_output_contains -- "--summary"
}

@test "default mode does not create backups when declined" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "hello world"
    [ ! -d ".findir-backups" ]
}
