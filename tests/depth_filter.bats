#!/usr/bin/env bats

load test_helper/common

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

@test "depth 1 only processes files in target directory" {
    create_file "top.txt" "hello"
    create_file "sub/nested.txt" "hello"
    run "$FINDIR" --no-color --danger --depth 1 "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "top.txt" "goodbye"
    assert_file_content "sub/nested.txt" "hello"
}

@test "depth 2 processes one level of subdirectories" {
    create_file "top.txt" "hello"
    create_file "sub/mid.txt" "hello"
    create_file "sub/deep/bottom.txt" "hello"
    run "$FINDIR" --no-color --danger --depth 2 "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "top.txt" "goodbye"
    assert_file_content "sub/mid.txt" "goodbye"
    assert_file_content "sub/deep/bottom.txt" "hello"
}

@test "no depth limit processes all levels" {
    create_file "a.txt" "hello"
    create_file "b/c.txt" "hello"
    create_file "b/c/d.txt" "hello"
    create_file "b/c/d/e.txt" "hello"
    run "$FINDIR" --no-color --danger "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "a.txt" "goodbye"
    assert_file_content "b/c.txt" "goodbye"
    assert_file_content "b/c/d.txt" "goodbye"
    assert_file_content "b/c/d/e.txt" "goodbye"
}

@test "depth 0 processes nothing (only the directory itself)" {
    create_file "top.txt" "hello"
    run "$FINDIR" --no-color --danger --depth 0 "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "top.txt" "hello"
}

@test "errors on non-numeric depth" {
    run "$FINDIR" --no-color --depth "abc" "hello" "goodbye"
    [ "$status" -ne 0 ]
    assert_output_contains "non-negative integer"
}

@test "depth with pattern filter combined" {
    create_file "top.py" "hello"
    create_file "top.txt" "hello"
    create_file "sub/nested.py" "hello"
    run "$FINDIR" --no-color --danger --depth 1 -p "*.py" "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "top.py" "goodbye"
    assert_file_content "top.txt" "hello"
    assert_file_content "sub/nested.py" "hello"
}
