# nt — Node.js Tool Manager

Install global npm packages and pin them to specific Node.js versions.

## Why?

- **Version pinning**: Lock tools to specific Node.js versions if you need
- **Independent from nvm/fnm**: Switch Node.js versions for development without breaking global tools
- **No global pollution**: Tools are installed in `~/.local/nt/`
- **Simple**: Single Bash script, downloads what it needs

## Installation

**Quick install:**

```bash
curl -fsSL https://raw.githubusercontent.com/vadzim/nt-manager/main/nt-install.sh | bash
```

Then add to your shell profile (if not already in PATH):

```bash
export PATH="$HOME/.local/nt/bin:$PATH"
```

**Manual install:**

Download the script and put it in your PATH:

```bash
curl -fsSL https://raw.githubusercontent.com/vadzim/nt-manager/main/nt -o ~/.local/bin/nt
chmod +x ~/.local/bin/nt
```

Make sure `~/.local/bin` is in your PATH.

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

# Force reinstall all tools (even if up-to-date)
nt update --force

# Remove a tool
nt remove typescript
```

**Important:** 
- Each tool always uses its pinned Node.js version, regardless of what's on your PATH
- Tools without `--node` use the latest LTS
- Use `nvm use` or `fnm use` for development — your global tools won't break

## Requirements

- Bash 4.0+
- `curl` or `wget` (for downloading Node.js and packages)
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

## Contributing

For implementation details, architecture, and testing, see [IMPLEMENTATION.md](IMPLEMENTATION.md).

## License

MIT

## Author

Vadzim
