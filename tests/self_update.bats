#!/usr/bin/env bats

load test_helper/common

setup() {
    setup_test_dir
    cp "$FINDIR" "$TEST_DIR/findir_copy"
    chmod +x "$TEST_DIR/findir_copy"
}

teardown() {
    teardown_test_dir
}

@test "self-update flag is recognized" {
    run "$FINDIR" --help
    [ "$status" -eq 0 ]
    assert_output_contains "self-update"
}

@test "self-update attempts download" {
    # Run with a short network timeout; may fail without internet
    run bash -c "\"$TEST_DIR/findir_copy\" --self-update --no-color 2>&1" || true
    # Should either succeed, show version info, or fail with network error
    # It must NOT show "Unknown option"
    assert_output_not_contains "Unknown option"
}

@test "version flag works on copy" {
    run "$TEST_DIR/findir_copy" --version
    [ "$status" -eq 0 ]
    [[ "$output" =~ [0-9]+\.[0-9]+\.[0-9]+ ]]
}
