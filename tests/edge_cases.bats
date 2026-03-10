#!/usr/bin/env bats

load test_helper/common

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

@test "handles empty files" {
    create_file "empty.txt" ""
    create_file "notempty.txt" "hello world"
    run "$FINDIR" --no-color --danger "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "notempty.txt" "goodbye world"
}

@test "handles files with spaces in names" {
    create_file "my file.txt" "hello world"
    run "$FINDIR" --no-color --danger "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "my file.txt" "goodbye world"
}

@test "handles directories with spaces in names" {
    create_file "my dir/test.txt" "hello world"
    run "$FINDIR" --no-color --danger "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "my dir/test.txt" "goodbye world"
}

@test "handles search string with newlines" {
    create_file "test.txt" "$(printf 'hello\nworld')"
    run "$FINDIR" --no-color --danger "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    local expected
    expected=$(printf 'goodbye\nworld')
    assert_file_content "test.txt" "$expected"
}

@test "handles replacement with special characters" {
    create_file "test.txt" "replace me"
    run "$FINDIR" --no-color --danger "replace me" 'a$b&c\d' "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" 'a$b&c\d'
}

@test "handles very long lines" {
    local long_line
    long_line=$(printf '%0.sA' {1..1000})
    create_file "test.txt" "${long_line}FINDME${long_line}"
    run "$FINDIR" --no-color --danger "FINDME" "FOUND" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_contains "test.txt" "FOUND"
    assert_file_contains "test.txt" "AAAA"
}

@test "does not process files in .findir-backups" {
    create_file "test.txt" "hello world"
    mkdir -p ".findir-backups/old"
    create_file ".findir-backups/old/test.txt" "hello world"
    run "$FINDIR" --no-color --danger "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "goodbye world"
    assert_file_content ".findir-backups/old/test.txt" "hello world"
}

@test "does not process files in .git directory" {
    create_file "test.txt" "hello world"
    mkdir -p ".git"
    create_file ".git/config" "hello world"
    run "$FINDIR" --no-color --danger "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "goodbye world"
    assert_file_content ".git/config" "hello world"
}

@test "handles search string with backslashes" {
    create_file "test.txt" 'path\to\file'
    run "$FINDIR" --no-color --danger 'path\to\file' 'path/to/file' "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "path/to/file"
}

@test "handles tab characters" {
    create_file "test.txt" "$(printf 'col1\tcol2\tcol3')"
    run "$FINDIR" --no-color --danger "$(printf 'col1\tcol2')" "$(printf 'a\tb')" "$TEST_DIR"
    [ "$status" -eq 0 ]
    local expected
    expected=$(printf 'a\tb\tcol3')
    assert_file_content "test.txt" "$expected"
}

@test "replace string identical to search does nothing" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color --danger "hello" "hello" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "hello world"
}
