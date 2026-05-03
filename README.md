# nt — Node.js Tool Manager

Install global npm packages and pin them to specific Node.js versions.

## Why?

- **Version pinning**: Lock tools to specific Node.js versions if you need
- **Independent from nvm/fnm**: Switch Node.js versions for development without breaking global tools
- **No global pollution**: Tools are installed in `~/.local/nt/`
- **Simple**: Single Bash script, downloads what it needs

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
# Install a tool (pinned to latest LTS Node.js)
nt install typescript

# Pin a tool to specific Node.js version
nt install --node=18 vite        # vite pinned to Node.js 18
nt install --node=20 @angular/cli # @angular/cli pinned to Node.js 20

# Install specific package version (still pinned to Node.js version)
nt install typescript@5.0.0           # typescript@5.0.0 pinned to latest LTS
nt install --node=18 vite@4.0.0       # vite@4.0.0 pinned to Node.js 18

# List installed tools
nt list

# Update all tools (keeps Node.js version pinning)
nt update

# Remove a tool
nt remove typescript
```

**Important:** 
- Each tool always uses its pinned Node.js version, regardless of what's on your PATH
- Tools without `--node` use the latest LTS
- Use `nvm use` or `fnm use` for development — your global tools won't break

## How it works

1. Downloads LTS Node.js directly from nodejs.org (no system Node.js needed!)
2. Uses npm to install specific Node.js versions via `npm install node@X`
3. Installs npm packages in `~/.local/nt/tools/<package>/`
4. Creates executable wrappers in `~/.local/nt/bin/` that set up the correct Node.js version

## Directory structure

```
~/.local/nt/
├── .internal/
│   └── node/           # LTS Node.js (auto-updated)
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
#   typescript  pkg: typescript@latest  node: lts
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
