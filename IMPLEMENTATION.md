# Implementation Details

This document describes the internal implementation of `nt-manager` for contributors and maintainers.

## How it works

1. **Bootstrap Node.js**: Downloads LTS Node.js directly from nodejs.org (no system Node.js needed!)
2. **Node.js isolation**: Uses bootstrap npm to install specific Node.js versions via `npm install node@X npm@latest`
3. **Package installation**: Installs npm packages in `~/.local/nt/tools/<package>/`
4. **Wrapper scripts**: Creates executable wrappers in `~/.local/nt/bin/` that set up the correct Node.js version
5. **Auto-updates**: Bootstrap Node.js checks for LTS updates once per day (on `nt install` or `nt update`)

## Directory structure

```
~/.local/nt/
├── .internal/
│   └── node/           # Bootstrap Node.js (LTS, auto-updated)
│       ├── bin/
│       │   ├── node
│       │   └── npm
│       └── .last_check # Timestamp of last LTS check
├── bin/
│   ├── tsc             # Executable wrappers
│   ├── vite
│   └── ng
├── node/               # Isolated Node.js versions (via npm install node@X)
│   ├── 18/
│   │   ├── bin/
│   │   │   ├── node -> ../node_modules/.bin/node
│   │   │   └── npm -> ../node_modules/.bin/npm
│   │   └── node_modules/
│   │       └── node/
│   └── 20/
│       └── ...
└── tools/              # Installed packages
    ├── typescript/
    │   ├── .node-version      # "bootstrap" or "18" or "20"
    │   ├── .package-spec      # "typescript@5.0.0"
    │   └── node_modules/
    │       └── typescript/
    ├── vite/
    └── @angular__cli/         # Scoped packages use __ instead of /
```

## Key functions

### `__nt_ensure_bootstrap_node()`

Downloads and maintains the bootstrap LTS Node.js:
- Checks `~/.local/nt/.internal/node/.last_check` timestamp
- If >24 hours old, queries nodejs.org for latest LTS
- Downloads and extracts if new version available
- Used by all tools without `--node` flag

### `__nt_ensure_node(spec)`

Installs specific Node.js version via npm:
- Uses bootstrap npm to run `npm install node@${spec} npm@latest`
- Creates symlinks in `bin/` directory
- Caches installed versions in `~/.local/nt/node/${spec}/`

### `__nt_create_wrappers(node_dir, tool_dir, pkg_name)`

Creates executable wrapper scripts:
- Reads `package.json` to find binary entries
- Creates wrapper in `~/.local/nt/bin/` for each binary
- Wrapper sets `PATH` to correct Node.js version and executes the tool

### `__nt_cleanup_wrappers(tool_dir)`

Removes wrapper scripts for a tool:
- Scans `~/.local/nt/bin/` for wrappers pointing to `tool_dir`
- Removes matching wrappers

### `__nt_recreate_all_wrappers()`

Recreates all wrappers after package removal:
- Iterates through all installed tools
- Recreates wrappers for each tool
- Resolves binary name conflicts (last tool wins)

## Download tool detection

The script auto-detects `curl` or `wget`:

```bash
if command -v curl >/dev/null 2>&1; then
    DOWNLOAD_CMD="curl -fsSL"
elif command -v wget >/dev/null 2>&1; then
    DOWNLOAD_CMD="wget -qO-"
else
    echo "nt: curl or wget is required"
    exit 1
fi
```

## Version pinning

Each tool stores its Node.js version in `.node-version`:
- `"bootstrap"` - uses LTS Node.js from `.internal/node/`
- `"18"`, `"20"`, etc. - uses specific version from `node/18/`, `node/20/`

When executing a tool, the wrapper reads `.node-version` and sets `PATH` accordingly.

## Testing

See [tests/README.md](tests/README.md) for test suite documentation.

All tests run in isolated temporary directories to avoid affecting the user's installation.
