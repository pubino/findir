#!/usr/bin/env bats

load test_helper/common

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

@test "replaces a simple string in one file" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color --danger "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "goodbye world"
}

@test "replaces multiple occurrences in one file" {
    create_file "test.txt" "foo and foo and foo"
    run "$FINDIR" --no-color --danger "foo" "bar" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "bar and bar and bar"
}

@test "replaces across multiple files" {
    create_file "a.txt" "hello there"
    create_file "b.txt" "hello again"
    run "$FINDIR" --no-color --danger "hello" "hi" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "a.txt" "hi there"
    assert_file_content "b.txt" "hi again"
}

@test "replaces in nested directory files" {
    create_file "sub/deep/test.txt" "old value"
    run "$FINDIR" --no-color --danger "old" "new" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "sub/deep/test.txt" "new value"
}

@test "does not modify files without matches" {
    create_file "match.txt" "foo bar"
    create_file "nomatch.txt" "baz qux"
    run "$FINDIR" --no-color --danger "foo" "replaced" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "match.txt" "replaced bar"
    assert_file_content "nomatch.txt" "baz qux"
}

@test "replaces with empty string (deletion)" {
    create_file "test.txt" "remove_this_part please"
    run "$FINDIR" --no-color --danger "remove_this_part " "" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "please"
}

@test "handles multiline files" {
    create_file "test.txt" "$(printf 'line1 old\nline2 old\nline3')"
    run "$FINDIR" --no-color --danger "old" "new" "$TEST_DIR"
    [ "$status" -eq 0 ]
    local expected
    expected=$(printf 'line1 new\nline2 new\nline3')
    assert_file_content "test.txt" "$expected"
}

@test "treats search as literal string not regex" {
    create_file "test.txt" "price is \$10.00 (USD)"
    run "$FINDIR" --no-color --danger "\$10.00" "\$20.00" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "price is \$20.00 (USD)"
}

@test "handles special regex characters in search" {
    create_file "test.txt" "match [this] (pattern) {here} and *star*"
    run "$FINDIR" --no-color --danger "[this]" "[that]" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "match [that] (pattern) {here} and *star*"
}

@test "shows summary output" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color --danger "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_output_contains "Files modified"
}
