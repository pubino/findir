#!/usr/bin/env bats

load test_helper/common

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

@test "quiet mode suppresses normal output" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color --danger -y -q "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    # In quiet mode there should be no summary
    assert_output_not_contains "Summary"
    assert_file_content "test.txt" "goodbye world"
}

@test "verbose mode shows extra info" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color --danger -y -v "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_output_contains "Match"
}

@test "debug mode shows debug messages" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color --danger -y --debug "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_output_contains "debug"
}

@test "normal mode shows summary" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color --danger -y "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_output_contains "Summary"
    assert_output_contains "Files modified"
}

@test "verbose mode shows file matches" {
    create_file "a.txt" "hello"
    create_file "b.txt" "world"
    run "$FINDIR" --no-color --danger -y -v "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_output_contains "Match"
}

@test "debug mode shows backup info" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color -y --debug "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_output_contains "debug"
    assert_output_contains "Backup"
}

@test "quiet mode still shows errors" {
    run "$FINDIR" --no-color -q "hello" "goodbye" "/nonexistent"
    [ "$status" -ne 0 ]
    assert_output_contains "error"
}
