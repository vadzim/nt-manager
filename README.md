# nt — Node.js Tool Manager

A lightweight Node.js package manager that isolates tools with their own Node.js versions.

## Why?

- **Zero dependencies**: No Node.js required on your system
- **Isolated Node versions**: Each tool gets its own Node.js version
- **No global pollution**: Tools are installed in `~/.local/nt/`
- **Version pinning**: Lock tools to specific Node.js versions
- **Simple**: Shell script (Fish or Bash), downloads what it needs
- **Cross-shell**: Works with Fish, Bash, and Zsh

## Installation

```bash
# Clone the repo
git clone https://github.com/vadzim/nt-manager.git
cd nt-manager

# Choose your shell version
# For Fish shell:
chmod +x nt
ln -s $(pwd)/nt ~/.bin/nt
fish_add_path ~/.bin

# For Bash/Zsh:
chmod +x nt.bash
ln -s $(pwd)/nt.bash ~/.bin/nt
echo 'export PATH="$HOME/.bin:$PATH"' >> ~/.bashrc  # or ~/.zshrc
```

## Usage

```bash
# Install a package with latest Node.js
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

1. **Bootstrap**: Downloads [n](https://github.com/tj/n) on first run (no Node.js needed!)
2. **Node.js isolation**: Uses `n` to install Node.js versions in `~/.local/nt/node/<version>/`
3. **Package installation**: Installs npm packages in `~/.local/nt/tools/<package>/`
4. **Wrapper scripts**: Creates executable wrappers in `~/.local/nt/bin/` that set up the correct Node.js version

## Directory structure

```
~/.local/nt/
├── bin/
│   ├── n               # Node.js version manager (auto-downloaded)
│   ├── tsc             # Executable wrappers
│   ├── vite
│   └── ng
├── node/               # Isolated Node.js versions
│   ├── 18/
│   ├── 20/
│   └── latest/
└── tools/              # Installed packages
    ├── typescript/
    ├── vite/
    └── @angular__cli/
```

## Requirements

- Bash 4.0+ or Fish shell
- `curl` (for downloading Node.js and packages)
- Internet connection

**No Node.js required!** `nt` will download and manage Node.js versions automatically.

## Examples

```bash
# Install TypeScript with Node 20
nt install --node=20 typescript

# Install multiple tools
nt install vite
nt install --node=18 webpack
nt install prettier

# Check what's installed
nt list
# Output:
#   typescript  pkg: typescript@latest  node: 20
#   vite        pkg: vite@latest        node: latest
#   webpack     pkg: webpack@latest     node: 18
#   prettier    pkg: prettier@latest    node: latest

# Update everything
nt update
```

## License

MIT

## Author

Vadzim
