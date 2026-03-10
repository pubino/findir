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

@test "self-remove flag is recognized" {
    run "$FINDIR" --help
    [ "$status" -eq 0 ]
    assert_output_contains "self-remove"
}

@test "self-remove is documented in help" {
    run "$FINDIR" --help
    [ "$status" -eq 0 ]
    assert_output_contains "Uninstall"
}

@test "self-remove binary exists before removal" {
    [ -f "$TEST_DIR/findir_copy" ]
    [ -x "$TEST_DIR/findir_copy" ]
}
