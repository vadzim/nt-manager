# nt — Node.js Tool Manager

A lightweight Node.js package manager that isolates tools with their own Node.js versions.

## Why?

- **Isolated Node versions**: Each tool gets its own Node.js version
- **No global pollution**: Tools are installed in `~/.local/nt/`
- **Version pinning**: Lock tools to specific Node.js versions
- **Simple**: Just a Fish shell script, no dependencies

## Installation

```bash
# Clone the repo
git clone https://github.com/vadzim/nt-manager.git
cd nt-manager

# Make it executable
chmod +x nt

# Add to PATH (Fish shell)
mkdir -p ~/.bin
ln -s $(pwd)/nt ~/.bin/nt
fish_add_path ~/.bin
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

1. **Node.js isolation**: Uses [n](https://github.com/tj/n) to install Node.js versions in `~/.local/nt/node/<version>/`
2. **Package installation**: Installs npm packages in `~/.local/nt/tools/<package>/`
3. **Wrapper scripts**: Creates executable wrappers in `~/.local/nt/bin/` that set up the correct Node.js version

## Directory structure

```
~/.local/nt/
├── node/           # Isolated Node.js versions
│   ├── 18/
│   ├── 20/
│   └── latest/
├── tools/          # Installed packages
│   ├── typescript/
│   ├── vite/
│   └── @angular__cli/
└── bin/            # Executable wrappers
    ├── tsc
    ├── vite
    └── ng
```

## Requirements

- Fish shell
- `npx` (comes with Node.js)
- Internet connection for initial setup

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
