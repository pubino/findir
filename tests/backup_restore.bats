#!/usr/bin/env bats

load test_helper/common

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

@test "creates backup directory on replace" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color -y "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d ".findir-backups" ]
}

@test "creates manifest file in backup" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color -y "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    local manifest
    manifest=$(find .findir-backups -name "manifest.txt" | head -1)
    [ -n "$manifest" ]
    [ -f "$manifest" ]
}

@test "backup manifest contains file paths" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color -y "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    local manifest
    manifest=$(find .findir-backups -name "manifest.txt" | head -1)
    grep -q "test.txt" "$manifest"
}

@test "backup preserves original file content" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color -y "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Find the backed up file
    local backup_file
    backup_file=$(find .findir-backups -name "test.txt" -not -name "manifest.txt" | head -1)
    [ -f "$backup_file" ]
    local content
    content=$(cat "$backup_file")
    [ "$content" = "hello world" ]
}

@test "restore brings back original content" {
    create_file "test.txt" "original content"
    "$FINDIR" --no-color -y "original" "modified" "$TEST_DIR"
    assert_file_content "test.txt" "modified content"

    local manifest
    manifest=$(find .findir-backups -name "manifest.txt" | head -1)

    run "$FINDIR" --no-color --restore "$manifest"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "original content"
}

@test "restore works with multiple files" {
    create_file "a.txt" "hello a"
    create_file "b.txt" "hello b"
    "$FINDIR" --no-color -y "hello" "bye" "$TEST_DIR"

    local manifest
    manifest=$(find .findir-backups -name "manifest.txt" | head -1)

    run "$FINDIR" --no-color --restore "$manifest"
    [ "$status" -eq 0 ]
    assert_file_content "a.txt" "hello a"
    assert_file_content "b.txt" "hello b"
}

@test "restore errors on missing manifest" {
    run "$FINDIR" --no-color --restore "/nonexistent/manifest.txt"
    [ "$status" -ne 0 ]
    assert_output_contains "Manifest file not found"
}

@test "uses custom backup directory with --backup-dir" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color -y --backup-dir "my-backups" "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "my-backups" ]
}

@test "summary shows restore command" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color -y "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_output_contains "Restore with"
}
