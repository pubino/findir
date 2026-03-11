#!/usr/bin/env bats

load test_helper/common

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

@test "pattern filter only processes matching files" {
    create_file "code.py" "hello world"
    create_file "readme.txt" "hello world"
    create_file "code.js" "hello world"
    run "$FINDIR" --no-color --danger -y -p "*.py" "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "code.py" "goodbye world"
    assert_file_content "readme.txt" "hello world"
    assert_file_content "code.js" "hello world"
}

@test "pattern filter with -p flag" {
    create_file "a.txt" "hello"
    create_file "b.md" "hello"
    run "$FINDIR" --no-color --danger -y -p "*.txt" "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "a.txt" "goodbye"
    assert_file_content "b.md" "hello"
}

@test "pattern filter with --pattern flag" {
    create_file "app.js" "hello"
    create_file "app.ts" "hello"
    run "$FINDIR" --no-color --danger -y --pattern "*.js" "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "app.js" "goodbye"
    assert_file_content "app.ts" "hello"
}

@test "pattern filter applies to nested files too" {
    create_file "top.py" "hello"
    create_file "sub/deep.py" "hello"
    create_file "sub/deep.txt" "hello"
    run "$FINDIR" --no-color --danger -y -p "*.py" "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "top.py" "goodbye"
    assert_file_content "sub/deep.py" "goodbye"
    assert_file_content "sub/deep.txt" "hello"
}

@test "no pattern processes all file types" {
    create_file "a.py" "hello"
    create_file "b.js" "hello"
    create_file "c.txt" "hello"
    run "$FINDIR" --no-color --danger -y "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "a.py" "goodbye"
    assert_file_content "b.js" "goodbye"
    assert_file_content "c.txt" "goodbye"
}

@test "pattern with question mark wildcard" {
    create_file "test.py" "hello"
    create_file "test.pl" "hello"
    create_file "test.txt" "hello"
    run "$FINDIR" --no-color --danger -y -p "*.p?" "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.py" "goodbye"
    assert_file_content "test.pl" "goodbye"
    assert_file_content "test.txt" "hello"
}
