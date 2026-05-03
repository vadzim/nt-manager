# Contributing to nt-manager

Thanks for your interest in contributing! 🎉

## How to contribute

### Reporting bugs

If you find a bug, please open an issue with:
- A clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Your environment (OS, Fish version, Node.js version)

### Suggesting features

Feature requests are welcome! Please open an issue describing:
- What problem does it solve?
- How should it work?
- Any examples or use cases

### Pull requests

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test your changes thoroughly
5. Commit with a clear message (`git commit -m 'Add amazing feature'`)
6. Push to your fork (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Code style

- Follow existing Fish shell conventions
- Keep functions focused and single-purpose
- Add comments for complex logic
- Test edge cases (missing packages, network failures, etc.)

### Testing

Before submitting a PR, test:
```bash
# Basic operations
nt install typescript
nt list
nt remove typescript

# Edge cases
nt install nonexistent-package  # Should fail gracefully
nt install --node=999 typescript  # Should handle invalid Node version
```

## Questions?

Feel free to open an issue for any questions!
