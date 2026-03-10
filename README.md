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
cp findir /usr/local/bin/
```

## Usage

```bash
# Positional arguments
findir "old_string" "new_string" ./src

# Flag-based arguments
findir -s "old_func" -r "new_func" -d ./project

# Dry run (preview changes)
findir --dry-run "TODO" "DONE" ./docs

# Interactive mode (confirm each file)
findir -i "foo" "bar" ./src

# Filter by file pattern and depth
findir -p "*.py" --depth 3 "os.path" "pathlib.Path" ./project

# Skip backups (danger mode)
findir --danger "old" "new" ./src

# Restore from backup
findir --restore .findir-backups/20260310-120000/manifest.txt
```

## Options

| Flag | Description |
|---|---|
| `-s, --search STRING` | Search string |
| `-r, --replace STRING` | Replacement string |
| `-d, --directory DIR` | Target directory (default: `.`) |
| `-n, --dry-run` | Preview changes without modifying files |
| `-i, --interactive` | Confirm each file before replacing |
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

## How It Works

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
