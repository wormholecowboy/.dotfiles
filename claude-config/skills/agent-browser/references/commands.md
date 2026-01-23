# Agent-Browser Command Reference

## Installation & Setup
```bash
npm install -g agent-browser    # Install CLI
agent-browser install           # Download Chromium
agent-browser install --with-deps  # With system deps (Linux)
```

## Navigation
| Command | Description |
|---------|-------------|
| `open <url>` | Navigate to URL (aliases: goto, navigate) |
| `back` | Go back in history |
| `forward` | Go forward in history |
| `reload` | Reload current page |

## Interaction
| Command | Description |
|---------|-------------|
| `click <sel>` | Click element |
| `dblclick <sel>` | Double-click element |
| `focus <sel>` | Focus element |
| `type <sel> <text>` | Type into element (appends) |
| `fill <sel> <text>` | Clear and fill field |
| `press <key>` | Press key (aliases: key) |
| `keydown <key>` | Hold key down |
| `keyup <key>` | Release key |
| `hover <sel>` | Hover over element |
| `select <sel> <val>` | Select dropdown option |
| `check <sel>` | Check checkbox |
| `uncheck <sel>` | Uncheck checkbox |
| `drag <src> <tgt>` | Drag and drop |
| `upload <sel> <files>` | Upload files |

## Scrolling & Mouse
| Command | Description |
|---------|-------------|
| `scroll <dir> [px]` | Scroll (up/down/left/right) |
| `scrollintoview <sel>` | Scroll element into view |
| `mouse move <x> <y>` | Move mouse position |
| `mouse down [button]` | Press mouse button |
| `mouse up [button]` | Release mouse button |
| `mouse wheel <dy> [dx]` | Scroll wheel |

## Page Information
| Command | Description |
|---------|-------------|
| `snapshot` | Get accessibility tree with refs |
| `screenshot [path]` | Take screenshot (--full for full page) |
| `pdf <path>` | Save as PDF |
| `get text <sel>` | Get text content |
| `get html <sel>` | Get innerHTML |
| `get value <sel>` | Get input value |
| `get attr <sel> <attr>` | Get attribute value |
| `get title` | Get page title |
| `get url` | Get current URL |
| `get count <sel>` | Count matching elements |
| `get box <sel>` | Get bounding box |

## Element State
| Command | Description |
|---------|-------------|
| `is visible <sel>` | Check if visible |
| `is enabled <sel>` | Check if enabled |
| `is checked <sel>` | Check if checked |

## Semantic Finding
Find elements by semantic attributes and perform actions:
```bash
find role <role> <action> [value]      # By ARIA role
find text <text> <action>               # By text content
find label <label> <action> [value]    # By label
find placeholder <ph> <action> [value]  # By placeholder
find alt <text> <action>                # By alt text
find title <text> <action>              # By title attribute
find testid <id> <action> [value]      # By data-testid
find first <sel> <action> [value]      # First match
find last <sel> <action> [value]       # Last match
find nth <n> <sel> <action> [value]    # Nth match
```

## Waiting
| Command | Description |
|---------|-------------|
| `wait <selector>` | Wait for element visibility |
| `wait <ms>` | Wait for milliseconds |
| `wait --text "text"` | Wait for text to appear |
| `wait --url "pattern"` | Wait for URL pattern |
| `wait --load <state>` | Wait for load state |
| `wait --fn "condition"` | Wait for JS condition |

## Browser Settings
| Command | Description |
|---------|-------------|
| `set viewport <w> <h>` | Set viewport dimensions |
| `set device <name>` | Emulate device |
| `set geo <lat> <lng>` | Set geolocation |
| `set offline [on\|off]` | Toggle offline mode |
| `set headers <json>` | Set HTTP headers |
| `set credentials <u> <p>` | HTTP basic auth |
| `set media [dark\|light]` | Emulate color scheme |

## Cookies & Storage
```bash
cookies                    # Get all cookies
cookies set <name> <val>   # Set cookie
cookies clear              # Clear all cookies

storage local              # Get localStorage
storage local <key>        # Get specific key
storage local set <k> <v>  # Set value
storage local clear        # Clear storage
storage session            # Same for sessionStorage
```

## Network
| Command | Description |
|---------|-------------|
| `network route <url>` | Intercept requests |
| `network route <url> --abort` | Block requests |
| `network route <url> --body <json>` | Mock response |
| `network unroute [url]` | Remove routes |
| `network requests` | View tracked requests |
| `network requests --filter <type>` | Filter requests |

## Tabs & Windows
| Command | Description |
|---------|-------------|
| `tab` | List tabs |
| `tab new [url]` | New tab |
| `tab <n>` | Switch to tab |
| `tab close [n]` | Close tab |
| `window new` | New window |

## Frames & Dialogs
| Command | Description |
|---------|-------------|
| `frame <sel>` | Switch to iframe |
| `frame main` | Return to main frame |
| `dialog accept [text]` | Accept dialog |
| `dialog dismiss` | Dismiss dialog |

## Debugging
| Command | Description |
|---------|-------------|
| `eval <js>` | Run JavaScript |
| `trace start [path]` | Start trace recording |
| `trace stop [path]` | Stop and save trace |
| `console` | View console messages |
| `console --clear` | Clear console |
| `errors` | View page errors |
| `errors --clear` | Clear errors |
| `highlight <sel>` | Highlight element |
| `state save <path>` | Save auth state |
| `state load <path>` | Load auth state |
| `close` | Close browser (aliases: quit, exit) |

## Sessions
```bash
--session <name> <command>    # Use isolated session
AGENT_BROWSER_SESSION=<name>  # Environment variable
session list                  # List active sessions
session                       # Show current session
```

## Snapshot Options
| Flag | Description |
|------|-------------|
| `-i, --interactive` | Show interactive elements only |
| `-c, --compact` | Remove empty structural elements |
| `-d, --depth <n>` | Limit tree depth |
| `-s, --selector <sel>` | Scope to CSS selector |

## Global Flags
| Flag | Description |
|------|-------------|
| `--session <name>` | Use isolated session |
| `--headers <json>` | Set HTTP headers |
| `--executable-path <path>` | Custom browser executable |
| `--json` | JSON output for agents |
| `--full, -f` | Full page screenshot |
| `--name, -n` | Locator name filter |
| `--exact` | Exact text match |
| `--headed` | Show browser window |
| `--cdp <port>` | Connect via Chrome DevTools Protocol |
| `--debug` | Debug output |

## Selector Types
| Selector | Example | Description |
|----------|---------|-------------|
| Ref | `@e1` | From snapshot accessibility tree |
| CSS ID | `#submit-btn` | By element ID |
| CSS class | `.btn-primary` | By class name |
| CSS hierarchy | `div > button` | CSS combinators |
| Text | `text=Submit` | By text content |
| XPath | `xpath=//button` | XPath expression |
