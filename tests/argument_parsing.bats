#!/usr/bin/env bats

load test_helper/common

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

@test "shows help with --help" {
    run "$FINDIR" --help
    [ "$status" -eq 0 ]
    assert_output_contains "USAGE"
    assert_output_contains "findir"
}

@test "shows help with -h" {
    run "$FINDIR" -h
    [ "$status" -eq 0 ]
    assert_output_contains "USAGE"
}

@test "shows version with --version" {
    run "$FINDIR" --version
    [ "$status" -eq 0 ]
    assert_output_contains "findir"
    [[ "$output" =~ [0-9]+\.[0-9]+\.[0-9]+ ]]
}

@test "shows version with -V" {
    run "$FINDIR" -V
    [ "$status" -eq 0 ]
    [[ "$output" =~ [0-9]+\.[0-9]+\.[0-9]+ ]]
}

@test "errors when no search string provided" {
    run "$FINDIR" --no-color
    [ "$status" -ne 0 ]
    assert_output_contains "Search string is required"
}

@test "accepts positional arguments: search replace dir" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color --danger "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "goodbye world"
}

@test "accepts flag-based arguments: -s -r -d" {
    create_file "test.txt" "foo bar"
    run "$FINDIR" --no-color --danger -s "foo" -r "baz" -d "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "baz bar"
}

@test "errors on unknown option" {
    run "$FINDIR" --unknown-flag
    [ "$status" -ne 0 ]
    assert_output_contains "Unknown option"
}

@test "errors when too many positional arguments" {
    run "$FINDIR" --no-color "a" "b" "." "extra"
    [ "$status" -ne 0 ]
    assert_output_contains "Too many positional arguments"
}

@test "errors when --search missing argument" {
    run "$FINDIR" --search
    [ "$status" -ne 0 ]
    assert_output_contains "requires an argument"
}

@test "errors when --replace missing argument" {
    run "$FINDIR" --replace
    [ "$status" -ne 0 ]
    assert_output_contains "requires an argument"
}

@test "errors when --directory missing argument" {
    run "$FINDIR" --directory
    [ "$status" -ne 0 ]
    assert_output_contains "requires an argument"
}

@test "errors when target directory does not exist" {
    run "$FINDIR" --no-color "foo" "bar" "/nonexistent/path"
    [ "$status" -ne 0 ]
    assert_output_contains "Directory does not exist"
}

@test "-- stops option parsing" {
    create_file "test.txt" "-n hello"
    run "$FINDIR" --no-color --danger -- "-n" "-x" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "-x hello"
}
