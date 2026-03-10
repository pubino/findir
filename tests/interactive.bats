#!/usr/bin/env bats

load test_helper/common

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

@test "interactive flag is accepted" {
    create_file "test.txt" "hello world"
    # Just verify the flag doesn't cause an error in combination with dry-run
    run "$FINDIR" --no-color --danger -i --dry-run "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_output_contains "DRY RUN"
}

@test "interactive mode shows diff in dry-run" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color -i --dry-run "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_output_contains "-hello world"
    assert_output_contains "+goodbye world"
}

@test "interactive -i flag is recognized" {
    run "$FINDIR" --help
    [ "$status" -eq 0 ]
    assert_output_contains "interactive"
}

@test "interactive combined with other flags does not error" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color -i -n -v "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
}
