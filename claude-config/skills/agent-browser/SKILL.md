---
name: agent-browser
description: Headless browser automation via CLI for web scraping, UI testing, and automated workflows. Use when tasks require navigating websites, interacting with page elements (clicking, typing, form filling), taking screenshots, verifying page content, or performing end-to-end browser automation. Assumes agent-browser is installed globally.
---

# Agent Browser

Control a headless browser via CLI. Use `--json` flag for machine-readable output.

## Core Workflow

1. **Navigate** to target URL
2. **Snapshot** to get accessibility tree with element refs (`@e1`, `@e2`, etc.)
3. **Act** using refs for deterministic element selection
4. **Re-snapshot** after page changes

```bash
agent-browser open "https://example.com"
agent-browser snapshot -i -c    # interactive elements only, compact
agent-browser click @e3
agent-browser snapshot -i -c    # re-snapshot after interaction
```

## Selectors

Prefer refs from snapshots for reliability:
- `@e1` - Ref from accessibility tree (most reliable)
- `text=Submit` - By text content
- `#id` / `.class` - CSS selectors
- `xpath=//button` - XPath

## Common Patterns

### Form Interaction
```bash
agent-browser fill @e5 "user@example.com"
agent-browser fill @e6 "password123"
agent-browser click @e7
agent-browser wait --url "/dashboard"
```

### UI Verification
```bash
agent-browser is visible "#success-message"
agent-browser get text ".error-message"
agent-browser get count ".list-item"
agent-browser get attr @e2 "disabled"
```

### Screenshots & PDFs
```bash
agent-browser screenshot ./page.png
agent-browser screenshot --full ./fullpage.png
agent-browser pdf ./document.pdf
```

### Wait Patterns
```bash
agent-browser wait "#loading"              # Wait for element
agent-browser wait 2000                    # Wait ms
agent-browser wait --text "Success"        # Wait for text
agent-browser wait --load networkidle     # Wait for network
```

### Sessions (Parallel Isolation)
```bash
agent-browser --session test1 open "https://example.com"
agent-browser --session test2 open "https://other.com"
agent-browser session list
```

### Authentication
```bash
# Set headers for API auth
agent-browser --headers '{"Authorization": "Bearer token"}' open "https://api.example.com"

# Save/restore auth state
agent-browser state save ./auth.json
agent-browser state load ./auth.json
```

### Network Mocking
```bash
agent-browser network route "**/api/users" --body '{"users": []}'
agent-browser network route "**/ads/*" --abort
```

## Snapshot Tips

| Flag | Purpose |
|------|---------|
| `-i` | Interactive elements only (buttons, inputs, links) |
| `-c` | Compact output, removes empty containers |
| `-d 3` | Limit depth to 3 levels |
| `-s "#main"` | Scope to specific container |

Always use `-i -c` for cleaner output when interacting.

## Reference

Full command reference: [references/commands.md](references/commands.md)
