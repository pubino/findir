#!/usr/bin/env bats

load test_helper/common

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

@test "skips binary files" {
    create_file "text.txt" "hello world"
    create_binary_file "image.png"
    # Add search string to binary to test it's still skipped
    printf '\x00hello\x01' > "binary.dat"
    run "$FINDIR" --no-color --danger "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "text.txt" "goodbye world"
}

@test "reports skipped binary files in verbose mode" {
    create_file "text.txt" "hello world"
    create_binary_file "image.png"
    run "$FINDIR" --no-color --danger -v "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_output_contains "Skipping binary"
}

@test "binary skip count in summary" {
    create_file "text.txt" "hello world"
    create_binary_file "data.bin"
    run "$FINDIR" --no-color --danger -v "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    # Summary should show binary count if any were skipped
    assert_output_contains "binary"
}

@test "does not modify binary files even with matching bytes" {
    create_file "text.txt" "hello there"
    printf 'hello\x00binary\x01data' > "mixed.dat"
    local original_hash
    original_hash=$(md5sum "mixed.dat" 2>/dev/null || md5 -q "mixed.dat" 2>/dev/null || echo "skip")
    if [ "$original_hash" = "skip" ]; then
        skip "No md5 tool available"
    fi
    run "$FINDIR" --no-color --danger "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    local new_hash
    new_hash=$(md5sum "mixed.dat" 2>/dev/null || md5 -q "mixed.dat")
    [ "$original_hash" = "$new_hash" ]
}

@test "processes text files with various encodings" {
    create_file "plain.txt" "hello plain"
    create_file "utf8.txt" "hello utf8 café"
    run "$FINDIR" --no-color --danger "hello" "goodbye" "$TEST_DIR"
    [ "$status" -eq 0 ]
    assert_file_content "plain.txt" "goodbye plain"
    assert_file_content "utf8.txt" "goodbye utf8 café"
}
