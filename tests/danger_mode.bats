#!/usr/bin/env bats

load test_helper/common

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

@test "danger mode skips backup creation" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color --danger "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "goodbye world"
    [ ! -d ".findir-backups" ]
}

@test "danger mode still replaces correctly" {
    create_file "a.txt" "foo bar"
    create_file "b.txt" "foo baz"
    run "$FINDIR" --no-color --danger "foo" "qux" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "a.txt" "qux bar"
    assert_file_content "b.txt" "qux baz"
}

@test "danger mode summary does not show restore command" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color --danger "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_output_not_contains "Restore with"
}

@test "without danger mode, backup is created" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d ".findir-backups" ]
}

@test "danger mode with verbose shows skip message" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color --danger --debug "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_output_contains "Danger mode"
}

@test "danger mode combined with dry-run" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color --danger --dry-run "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "hello world"
    [ ! -d ".findir-backups" ]
}
