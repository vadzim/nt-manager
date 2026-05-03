# nt — Node.js Tool Manager

A lightweight Node.js package manager that isolates tools with their own Node.js versions.

## Why?

- **Zero dependencies**: No Node.js required on your system
- **Isolated Node versions**: Each tool gets its own Node.js version
- **No global pollution**: Tools are installed in `~/.local/nt/`
- **Version pinning**: Lock tools to specific Node.js versions
- **Simple**: Single Bash script, downloads what it needs
- **Auto-updates**: Bootstrap Node.js (LTS) updates automatically

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/vadzim/nt-manager/main/nt-install.sh | bash
```

Then add to your shell profile (if not already in PATH):

```bash
export PATH="$HOME/.local/nt/bin:$PATH"
```

## Usage

```bash
# Install a tool (uses bootstrap LTS Node.js)
nt install typescript

# Install with specific Node.js version
nt install --node=18 vite
nt install --node=20 @angular/cli

# Install specific package version
nt install typescript@5.0.0
nt install --node=18 vite@4.0.0

# List installed tools
nt list

# Update all tools
nt update

# Remove a tool
nt remove typescript
```

## How it works

1. **Bootstrap**: Downloads LTS Node.js directly from nodejs.org (no system Node.js needed!)
2. **Node.js isolation**: Uses bootstrap npm to install specific Node.js versions via `npm install node@X`
3. **Package installation**: Installs npm packages in `~/.local/nt/tools/<package>/`
4. **Wrapper scripts**: Creates executable wrappers in `~/.local/nt/bin/` that set up the correct Node.js version
5. **Auto-updates**: Bootstrap Node.js checks for LTS updates daily

## Directory structure

```
~/.local/nt/
├── .internal/
│   └── node/           # Bootstrap Node.js (LTS, auto-updated)
├── bin/
│   ├── tsc             # Executable wrappers
│   ├── vite
│   └── ng
├── node/               # Isolated Node.js versions (via npm)
│   ├── 18/
│   └── 20/
└── tools/              # Installed packages
    ├── typescript/
    ├── vite/
    └── @angular__cli/
```

## Requirements

- Bash 4.0+
- `curl` (for downloading Node.js and packages)
- `tar` with xz support
- Internet connection

**No Node.js required!** `nt` will download and manage Node.js versions automatically.

## Advanced Usage

```bash
# Use custom installation directory
nt install --home=/opt/myproject/nt typescript

# Or set NT_HOME environment variable
export NT_HOME=/opt/myproject/nt
nt install typescript

# Install with specific Node.js version
nt install --node=20 typescript

# Check what's installed
nt list
# Output:
#   typescript  pkg: typescript@latest  node: bootstrap
#   vite        pkg: vite@latest        node: 20
```

## Testing

Run the test suite to verify everything works:

```bash
cd tests
./test.bash
```

All 13 tests should pass. See [tests/README.md](tests/README.md) for details.

## License

MIT

## Author

Vadzim
