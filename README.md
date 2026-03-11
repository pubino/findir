# findir

Find & replace literal strings across files in directory trees.

## Installation

### One-liner

```bash
curl -fsSL https://raw.githubusercontent.com/pubino/findir/main/install.sh | bash
```

### Manual

```bash
git clone https://github.com/pubino/findir.git
cd findir
mkdir -p ~/.local/bin
cp findir ~/.local/bin/
```

> **Note:** Make sure `~/.local/bin` is in your `PATH`. If not, add `export PATH="$HOME/.local/bin:$PATH"` to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.).

## Usage

```bash
# Preview changes, then prompt to apply (default)
findir "old_string" "new_string" ./src

# Apply immediately, skip preview
findir -y "old_func" "new_func" ./src

# Dry run (preview only, no prompt)
findir --dry-run "TODO" "DONE" ./docs

# Interactive mode (confirm each file)
findir -i "foo" "bar" ./src

# Filter by file pattern and depth
findir -p "*.py" --depth 3 "os.path" "pathlib.Path" ./project

# Skip backups (danger mode)
findir --danger "old" "new" ./src

# Compact file list only (no diffs)
findir --dry-run --summary "TODO" "DONE" ./docs

# Restore from backup
findir --restore .findir-backups/20260310-120000/manifest.txt
```

> **Note:** By default, findir shows a preview of all changes and prompts before applying. Use `-y`/`--yes` to skip the preview and apply immediately.

## Options

| Flag | Description |
|---|---|
| `-s, --search STRING` | Search string |
| `-r, --replace STRING` | Replacement string |
| `-d, --directory DIR` | Target directory (default: `.`) |
| `-n, --dry-run` | Preview only (no prompt to apply) |
| `-y, --yes` | Skip preview, apply changes immediately |
| `--summary` | List affected files only (no inline diffs) |
| `-i, --interactive` | Confirm each file before replacing |
| `-I, --ignore-case` | Case-insensitive search |
| `--danger` | Skip backup creation |
| `--depth N` | Limit directory traversal depth |
| `-p, --pattern PATTERN` | Only process files matching glob pattern |
| `--backup-dir DIR` | Custom backup directory |
| `--restore FILE` | Restore from a backup manifest |
| `--no-color` | Disable colored output |
| `-v, --verbose` | Increase verbosity |
| `-q, --quiet` | Suppress non-error output |
| `--debug` | Enable debug output |
| `--self-update` | Update findir to latest version |
| `--self-remove` | Uninstall findir |
| `-V, --version` | Show version |
| `-h, --help` | Show help |

## Quoting and Special Characters

findir operates on **literal strings only** — no regex. Quotes, brackets, dots, and other special characters are matched and replaced exactly as given. You only need to handle normal shell quoting to pass your strings in:

```bash
# Single quotes in the string — wrap in double quotes
findir "it's here" "it's there" ./src

# Double quotes in the string — wrap in single quotes
findir 'say "hello"' 'say "goodbye"' ./src

# Both quote types — use $'...' syntax
findir $'it\'s "here"' $'it\'s "there"' ./src

# Regex metacharacters are literal (replaces the actual dot-star)
findir "foo.*bar" "baz" ./src

# Backslashes, dollar signs, brackets — all literal
findir '$obj[0]' '$obj[1]' ./src
```

Internally, search/replace strings are passed to perl via environment variables (not command-line interpolation) and the search string is escaped with `quotemeta()`, so no characters receive special treatment.

## How It Works

- **Preview by default**: Shows a diff preview of all changes and prompts `Apply changes? [Y/n]` before modifying any files. Use `-y`/`--yes` to apply immediately, or `-n`/`--dry-run` to preview without prompting.
- **Search**: Uses `grep -F` for literal string matching (no regex)
- **Replace**: Uses `perl -i -pe` with `quotemeta()` for safe literal replacement
- **Binary detection**: Uses `file --mime-encoding` to skip binary files
- **Backups**: Creates timestamped backups with a manifest for easy restore

## Testing

### Native (requires bats-core)

```bash
brew install bats-core   # macOS
bats tests/
```

### Docker

```bash
docker-compose up --build --abort-on-container-exit
```

Tests run on both bash 3.2 (macOS baseline) and bash 5.2.

## Requirements

- bash 3.2+
- perl
- grep
- find
- file
- diff
- curl (for self-update)

## License

MIT
