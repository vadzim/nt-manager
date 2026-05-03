# Tests

Automated test suite for nt-manager.

## Running tests

```bash
cd tests
./test.bash
```

## What is tested

1. **Basic installation** - Install a small package (chalk)
2. **Wrapper creation** - Verify executable wrappers are created
3. **List command** - Check installed packages appear in list
4. **Node.js installation** - Verify Node.js is downloaded automatically
5. **Specific Node version** - Install package with `--node=20`
6. **Version pinning** - Verify `.node-version` file is created
7. **Package removal** - Remove a package and verify cleanup
8. **Wrapper cleanup** - Verify wrappers are removed with package
9. **Scoped packages** - Install `@scope/package` format
10. **Bootstrap** - Verify `n` is auto-downloaded on first run
11. **Custom prefix** - Tests use `NT_HOME` environment variable

## Test packages

- **cowsay** - Classic ASCII art generator with binary
- **figlet** - ASCII art text generator
- **@sindresorhus/is** - Scoped package example

## Test isolation

Each test run uses a temporary directory via `NT_HOME` environment variable:
- No interference with your actual `~/.local/nt/` installation
- Clean state for each test run
- Automatic cleanup on exit

## CI/CD

Tests can be run in CI environments:
```bash
# GitHub Actions example
- name: Run tests
  run: ./tests/test.bash
```
