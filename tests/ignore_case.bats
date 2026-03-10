#!/usr/bin/env bats

load test_helper/common

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

@test "ignore-case replaces all case variants" {
    create_file "test.txt" "Hello HELLO hello hElLo"
    run "$FINDIR" --no-color --danger --ignore-case "hello" "bye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "bye bye bye bye"
}

@test "ignore-case with -I flag" {
    create_file "test.txt" "Foo FOO foo"
    run "$FINDIR" --no-color --danger -I "foo" "bar" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "bar bar bar"
}

@test "ignore-case finds files with different casing" {
    create_file "a.txt" "HELLO world"
    create_file "b.txt" "hello world"
    create_file "c.txt" "Hello World"
    create_file "d.txt" "no match here"
    run "$FINDIR" --no-color --danger -I "hello" "hi" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "a.txt" "hi world"
    assert_file_content "b.txt" "hi world"
    assert_file_content "c.txt" "hi World"
    assert_file_content "d.txt" "no match here"
}

@test "ignore-case with special characters" {
    create_file "test.txt" 'Price is $10.00 and PRICE IS $10.00'
    run "$FINDIR" --no-color --danger -I 'price is $10.00' 'cost: $20' "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" 'cost: $20 and cost: $20'
}

@test "ignore-case with dry-run shows diff" {
    create_file "test.txt" "Hello HELLO hello"
    run "$FINDIR" --no-color --dry-run -I "hello" "bye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_output_contains "DRY RUN"
    assert_file_content "test.txt" "Hello HELLO hello"
}

@test "ignore-case is documented in help" {
    run "$FINDIR" --help
    [ "$status" -eq 0 ]
    assert_output_contains "ignore-case"
}

@test "without ignore-case only matches exact case" {
    create_file "test.txt" "Hello HELLO hello"
    run "$FINDIR" --no-color --danger "hello" "bye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "Hello HELLO bye"
}

@test "ignore-case with multiline file" {
    create_file "test.txt" "$(printf 'Hello world\nHELLO WORLD\nhello world')"
    run "$FINDIR" --no-color --danger -I "hello" "hi" "$TEST_DIR"
    [ "$status" -eq 0 ]
    local expected
    expected=$(printf 'hi world\nhi WORLD\nhi world')
    assert_file_content "test.txt" "$expected"
}

@test "ignore-case with backup" {
    create_file "test.txt" "Hello HELLO"
    run "$FINDIR" --no-color -I "hello" "bye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "bye bye"
    [ -d ".findir-backups" ]
}
