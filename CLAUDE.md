# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**findir** is a bash CLI tool for literal string find-and-replace across file trees. Single-file script (`findir`), no build step. Uses `grep -F` for matching and `perl -i -pe` with `quotemeta()` for safe literal replacement. Must support bash 3.2+ (macOS default) through bash 5.2.

## Commands

### Lint
```bash
shellcheck findir
```

### Test — Native (requires bats-core)
```bash
bats tests/                        # run all tests
bats tests/basic_replace.bats     # run a single test file
```

### Test — Docker (runs on both bash 3.2 and 5.2)
```bash
docker-compose up --build --abort-on-container-exit
```

### Test — Docker single target
```bash
docker build -f Dockerfile -t findir-test-bash32 . && docker run --rm findir-test-bash32
docker build -f Dockerfile.bash5 -t findir-test-bash52 . && docker run --rm findir-test-bash52
```

## Architecture

- `findir` — Entire tool in one bash script. Sections separated by comment banners: color setup, logging, argument parsing, validation, file discovery, replacement engine (perl), backup system, interactive mode, self-update/remove, summary, main logic (`run_pass` for preview/apply modes, `prompt_apply` for TTY confirmation, `do_find_replace` dispatch), main dispatch. Default behavior: preview changes then prompt to apply. `--yes`/`-y` skips preview and applies immediately. `--dry-run`/`-n` previews without prompting.
- `tests/` — [bats-core](https://github.com/bats-core/bats-core) test files, one per feature area. Each test uses `setup_test_dir`/`teardown_test_dir` from `tests/test_helper/common.bash` to create and clean up isolated temp directories.
- `Dockerfile` — bash 3.2 test image; `Dockerfile.bash5` — bash 5.2 test image. Both install bats-core, bats-support, and bats-assert.
- CI (`.github/workflows/ci.yml`) — ShellCheck lint + tests on bash 3.2 (Docker), bash 5.2 (Docker), and macOS native.

## Key Constraints

- **Bash 3.2 compatibility is mandatory.** No associative arrays, no `readarray`/`mapfile`, no `${var,,}` case conversion, no `|&` pipe syntax. Test on bash 3.2 via Docker before merging.
- **Literal string operations only** — no regex in user-facing search/replace. `grep -F` for matching, `quotemeta()` in perl for replacement.
- **Binary file detection** uses `file --mime-encoding`; binary files are always skipped.

## Test Conventions

- Each `.bats` file loads `test_helper/common` and uses `setup()`/`teardown()` to manage temp dirs.
- Use `--no-color --danger -y` flags in test `run` commands to suppress color codes, skip backups, and skip the default preview+prompt (apply immediately).
- Helper functions: `create_file`, `create_binary_file`, `assert_file_content`, `assert_file_contains`, `assert_output_contains`, `assert_output_not_contains`, `count_occurrences`, `strip_ansi`.
