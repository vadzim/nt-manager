# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-05-03

### Added
- Initial release
- Install npm packages with isolated Node.js versions
- Support for `--node=<version>` flag to specify Node.js version
- List installed tools with `nt list`
- Update all tools with `nt update`
- Remove tools with `nt remove`
- Automatic wrapper script generation for package binaries
- Support for scoped packages (e.g., `@angular/cli`)
- Zero dependencies: auto-downloads `n` on first run
- `NT_HOME` environment variable for custom installation directory
- Comprehensive test suite

### Features
- Isolated Node.js versions per tool using `n`
- Clean installation in `~/.local/nt/` (or custom via `NT_HOME`)
- No global npm pollution
- Version pinning for both packages and Node.js
- Works on systems without Node.js installed

[Unreleased]: https://github.com/vadzim/nt-manager/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/vadzim/nt-manager/releases/tag/v1.0.0
