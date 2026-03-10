# Builder Dependencies

External tools and skills required for full functionality.

## Required

| Dependency | Purpose | Install |
|------------|---------|---------|
| Claude Code | Task building, subagents | `npm install -g @anthropic-ai/claude-code` |
| Git | Version control, commit tracking | System package manager |

## Optional

| Dependency | Purpose | When Needed | Install |
|------------|---------|-------------|---------|
| agent-browser | UI testing, screenshots, visual validation | UI validation tasks | `npm install -g agent-browser` |
| Docker | Sandboxed builds for unattended runs | Ralph loops | [docker.com](https://docker.com) |

## Validation Tools

For task validation, ensure your project has appropriate linters/testers installed:

**Python projects:**
```bash
pip install pytest ruff mypy
```

**Node/TypeScript projects:**
```bash
npm install -g jest eslint typescript
```

## Notes

- `agent-browser` requires a Chromium-based browser to be installed
- Docker is strongly recommended for unattended Ralph loops (`*ralph` command)
- See `ralph-patterns.md` for detailed Docker setup instructions
