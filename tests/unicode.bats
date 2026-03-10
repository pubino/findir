#!/usr/bin/env bats

load test_helper/common

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

@test "replaces unicode characters" {
    create_file "test.txt" "café latte"
    run "$FINDIR" --no-color --danger "café" "coffee" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "coffee latte"
}

@test "replaces CJK characters" {
    create_file "test.txt" "hello 世界"
    run "$FINDIR" --no-color --danger "世界" "world" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "hello world"
}

@test "replaces emoji characters" {
    create_file "test.txt" "I love 🍕 pizza"
    run "$FINDIR" --no-color --danger "🍕" "🍔" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "I love 🍔 pizza"
}

@test "replaces accented characters" {
    create_file "test.txt" "naïve résumé"
    run "$FINDIR" --no-color --danger "naïve" "sophisticated" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "sophisticated résumé"
}

@test "replaces with unicode in replacement string" {
    create_file "test.txt" "hello world"
    run "$FINDIR" --no-color --danger "world" "мир" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "hello мир"
}

@test "handles mixed unicode and ASCII" {
    create_file "test.txt" "abc αβγ 123 日本語"
    run "$FINDIR" --no-color --danger "αβγ" "delta" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "abc delta 123 日本語"
}

@test "preserves unicode in non-matching parts" {
    create_file "test.txt" "ünïcödé search ünïcödé"
    run "$FINDIR" --no-color --danger "search" "found" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "test.txt" "ünïcödé found ünïcödé"
}
