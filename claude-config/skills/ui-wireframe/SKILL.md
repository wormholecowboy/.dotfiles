---
name: ui-wireframe
description: >
  Rapid UI wireframing using simple HTML/CSS files. Creates gray-box wireframe layouts,
  opens them in the browser for instant visual feedback, and supports iterative refinement.
  Use when the user wants to: plan a UI layout, sketch a wireframe, prototype page structure,
  compare layout options, design a user flow, mock up a screen, or visualize a component arrangement.
  Triggers: "wireframe", "mock up", "sketch a UI", "plan the layout", "prototype", "UI wireframe",
  "what should this page look like", "design this screen".
---

# UI Wireframe Skill

Create simple HTML/CSS wireframes for rapid UI planning. Output files to `/tmp/wireframes/`.

## Workflow

1. Clarify what the user wants to wireframe (page, flow, component)
2. Create HTML file(s) in `/tmp/wireframes/`
3. Open for viewing (default: `open` in browser; use `agent-browser` skill for screenshot if requested)
4. Iterate based on feedback — user references elements by number (e.g., "move 3 above 1", "swap 2 and 5", "remove 4")

## Element Labeling (always use)

Wrap every major section in a numbered `.el` wrapper. This is **required on all wireframes** so the user can reference elements by number.

```html
<div class="el" data-id="1">
  <!-- nav, hero, card grid, form, etc. -->
</div>
<div class="el" data-id="2">
  <!-- next section -->
</div>
```

Always add an element key at the bottom of the wireframe:

```html
<div style="margin-top:30px; padding:14px; background:#fff; border:1px solid #ddd; border-radius:4px; font-size:12px; color:#666;">
  <strong style="color:#444;">Element Key:</strong>
  <span style="margin-left:12px;"><span style="background:#e74c3c; color:#fff; padding:1px 6px; border-radius:10px; font-size:10px; font-weight:bold;">1</span> Nav</span>
  <span style="margin-left:12px;"><span style="background:#e74c3c; color:#fff; padding:1px 6px; border-radius:10px; font-size:10px; font-weight:bold;">2</span> Hero</span>
  <!-- ... one per element -->
</div>
```

## File Setup

```bash
mkdir -p /tmp/wireframes
```

Every wireframe file should be self-contained (inline CSS, no external deps). Use this base:

```html
<!DOCTYPE html>
<html><head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Wireframe - [Page Name]</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: system-ui, sans-serif; color: #333; background: #f5f5f5; padding: 20px; }
  .wire-box { background: #e0e0e0; border: 2px dashed #999; border-radius: 4px;
    padding: 16px; display: flex; align-items: center; justify-content: center;
    color: #666; font-size: 14px; min-height: 40px; }
  .wire-text { background: repeating-linear-gradient(0deg, #ccc, #ccc 1px, transparent 1px, transparent 8px);
    height: 40px; border-radius: 2px; }
  .wire-label { font-size: 11px; color: #999; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 4px; }
  .container { max-width: 1200px; margin: 0 auto; }
  .el { position: relative; margin-bottom: 16px; }
  .el::before { content: attr(data-id); position: absolute; top: -10px; left: -10px; z-index: 10;
    background: #e74c3c; color: #fff; width: 24px; height: 24px; border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    font-size: 11px; font-weight: bold; box-shadow: 0 1px 3px rgba(0,0,0,0.3); }
</style>
</head><body>
<div class="container">
  <!-- wireframe content: wrap each section in <div class="el" data-id="N"> -->
</div>
</body></html>
```

## Component Palette

Use these patterns to compose layouts quickly. All components use the `.wire-box` base style.

### Navigation
```html
<nav style="display:flex; justify-content:space-between; align-items:center; padding:12px 24px; background:#d0d0d0; margin-bottom:20px;">
  <div class="wire-box" style="width:120px; min-height:32px; background:#bbb;">Logo</div>
  <div style="display:flex; gap:16px;">
    <div class="wire-box" style="min-height:28px; padding:4px 16px;">Link</div>
    <div class="wire-box" style="min-height:28px; padding:4px 16px;">Link</div>
    <div class="wire-box" style="min-height:28px; padding:4px 16px;">Link</div>
  </div>
</nav>
```

### Sidebar + Content
```html
<div style="display:grid; grid-template-columns:250px 1fr; gap:20px;">
  <aside>
    <div class="wire-box" style="flex-direction:column; align-items:stretch; gap:8px; padding:12px;">
      Sidebar<br><div class="wire-text" style="width:100%;"></div>
      <div class="wire-text" style="width:100%;"></div>
    </div>
  </aside>
  <main>
    <div class="wire-box" style="min-height:400px;">Main Content</div>
  </main>
</div>
```

### Card Grid
```html
<div style="display:grid; grid-template-columns:repeat(auto-fill, minmax(280px, 1fr)); gap:16px;">
  <div class="wire-box" style="flex-direction:column; min-height:200px; gap:8px;">
    <div style="background:#ccc; width:100%; height:120px; border-radius:4px;"></div>
    Card Title<div class="wire-text" style="width:100%;"></div>
  </div>
  <!-- repeat for more cards -->
</div>
```

### Hero Section
```html
<section style="text-align:center; padding:60px 20px; background:#d5d5d5; margin-bottom:20px; border-radius:4px;">
  <div style="font-size:24px; color:#555; margin-bottom:12px;">Headline Text</div>
  <div class="wire-text" style="width:60%; margin:0 auto 20px;"></div>
  <div class="wire-box" style="display:inline-block; padding:12px 32px; background:#bbb;">CTA Button</div>
</section>
```

### Form
```html
<form style="max-width:400px; display:flex; flex-direction:column; gap:12px;">
  <div><div class="wire-label">Label</div><div class="wire-box" style="min-height:36px; background:#fff; border:1px solid #ccc;">Input</div></div>
  <div><div class="wire-label">Label</div><div class="wire-box" style="min-height:36px; background:#fff; border:1px solid #ccc;">Input</div></div>
  <div><div class="wire-label">Label</div><div class="wire-box" style="min-height:80px; background:#fff; border:1px solid #ccc;">Textarea</div></div>
  <div class="wire-box" style="padding:10px 24px; background:#bbb; align-self:flex-start;">Submit</div>
</form>
```

### Footer
```html
<footer style="display:flex; justify-content:space-between; padding:24px; background:#d0d0d0; margin-top:20px;">
  <div class="wire-box" style="padding:4px 12px;">Footer Left</div>
  <div style="display:flex; gap:12px;">
    <div class="wire-box" style="padding:4px 12px;">Link</div>
    <div class="wire-box" style="padding:4px 12px;">Link</div>
  </div>
</footer>
```

## Chatbot Components

Add these CSS classes to the base styles when building chat UIs:

```css
.chat-container { border: 2px solid #999; border-radius: 8px; overflow: hidden; background: #fff; }
.chat-header { background: #d0d0d0; padding: 12px 16px; display: flex; justify-content: space-between; align-items: center; }
.chat-messages { padding: 16px; min-height: 350px; display: flex; flex-direction: column; gap: 12px; background: #fafafa; }
.msg-bot { background: #e0e0e0; border-radius: 12px 12px 12px 4px; padding: 10px 14px; max-width: 70%; align-self: flex-start; font-size: 13px; color: #555; }
.msg-user { background: #c8daf0; border-radius: 12px 12px 4px 12px; padding: 10px 14px; max-width: 70%; align-self: flex-end; font-size: 13px; color: #444; }
.msg-agent { background: #d0e4ff; border-radius: 12px 12px 12px 4px; padding: 10px 14px; max-width: 70%; align-self: flex-start; font-size: 13px; color: #444; }
.chat-input { display: flex; gap: 8px; padding: 12px; border-top: 1px solid #ddd; background: #fff; }
.chat-input-field { flex: 1; border: 1px solid #ccc; border-radius: 20px; padding: 8px 16px; background: #f9f9f9; color: #888; font-size: 13px; }
.chat-send-btn { background: #bbb; border: none; border-radius: 50%; width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; color: #666; font-size: 16px; }
.avatar { width: 28px; height: 28px; border-radius: 50%; background: #bbb; flex-shrink: 0; }
.msg-row { display: flex; gap: 8px; align-items: flex-end; }
.quick-replies { display: flex; gap: 8px; flex-wrap: wrap; padding: 8px 12px; }
.quick-reply { border: 1px solid #aaa; border-radius: 16px; padding: 6px 14px; font-size: 12px; color: #555; background: #fff; }
.typing-indicator { display: flex; gap: 4px; padding: 10px 14px; background: #e0e0e0; border-radius: 12px 12px 12px 4px; align-self: flex-start; }
.typing-dot { width: 8px; height: 8px; background: #999; border-radius: 50%; }
.system-msg { text-align: center; font-size: 11px; color: #999; padding: 8px; }
```

### Chat Message Bubbles
```html
<!-- Bot message with avatar -->
<div class="msg-row">
  <div class="avatar"></div>
  <div class="msg-bot">Bot response text here</div>
</div>
<!-- User message (right-aligned, no avatar) -->
<div class="msg-user">User message text here</div>
<!-- Human agent message (different color to distinguish from bot) -->
<div class="msg-row">
  <div class="avatar" style="background:#a0c4ff;"></div>
  <div class="msg-agent">Hi, I'm Sarah from support.</div>
</div>
```

### Typing Indicator
```html
<div class="msg-row">
  <div class="avatar"></div>
  <div class="typing-indicator">
    <div class="typing-dot"></div>
    <div class="typing-dot" style="opacity:0.7;"></div>
    <div class="typing-dot" style="opacity:0.4;"></div>
  </div>
</div>
```

### Quick Reply Chips
```html
<div class="quick-replies">
  <div class="quick-reply">Option A</div>
  <div class="quick-reply">Option B</div>
  <div class="quick-reply">Talk to human</div>
</div>
```

### Chat Input Bar
```html
<div class="chat-input">
  <div style="font-size:16px; color:#888; padding:4px;">📎</div>
  <div class="chat-input-field">Type a message...</div>
  <div class="chat-send-btn">→</div>
</div>
```

### Chat Header with Status
```html
<div class="chat-header">
  <div style="display:flex; align-items:center; gap:10px;">
    <div class="avatar"></div>
    <div>
      <div style="font-size:14px; font-weight:600; color:#444;">Bot Name</div>
      <div style="font-size:11px; color:#888;">Online</div>
    </div>
  </div>
  <div class="wire-box" style="min-height:28px; padding:4px 8px; font-size:11px; background:transparent; border:1px dashed #aaa;">Menu ☰</div>
</div>
```

### System / Event Divider
```html
<div class="system-msg">— Escalated to human agent —</div>
```

### Conversation List Sidebar
```html
<div style="background:#eee; padding:12px; border-right:1px solid #ddd; width:220px;">
  <div style="font-size:12px; font-weight:600; color:#555; margin-bottom:8px;">Conversations</div>
  <div class="wire-box" style="min-height:32px; margin-bottom:8px; font-size:12px; background:#fff; border:1px solid #ccc; border-style:solid;">🔍 Search...</div>
  <div style="padding:8px; border-radius:4px; background:#d5d5d5; font-size:11px; color:#555; margin-bottom:4px;">Active Chat <span style="font-size:9px; opacity:0.5;">2m ago</span></div>
  <div style="padding:8px; border-radius:4px; font-size:11px; color:#666; margin-bottom:4px;">Past Chat <span style="font-size:9px; opacity:0.5;">1h ago</span></div>
  <div style="margin-top:12px; padding:8px; border-top:1px solid #ddd;">
    <div class="wire-box" style="font-size:11px; padding:6px; background:#d5d5d5;">+ New Chat</div>
  </div>
</div>
```

### Context / Details Panel
```html
<div style="background:#eee; padding:12px; border-left:1px solid #ddd; width:280px;">
  <div style="font-size:12px; font-weight:600; color:#555; margin-bottom:12px;">User Details</div>
  <div style="font-size:12px; color:#666; line-height:1.8; margin-bottom:16px;">
    <div><span style="color:#999;">Name:</span> John Doe</div>
    <div><span style="color:#999;">Email:</span> j.doe@email.com</div>
    <div><span style="color:#999;">Plan:</span> Pro</div>
  </div>
  <div style="font-size:12px; font-weight:600; color:#555; margin-bottom:8px;">Related Articles</div>
  <div style="font-size:12px; color:#4a90d9; margin-bottom:6px;">→ Help article title</div>
  <div style="font-size:12px; font-weight:600; color:#555; margin:16px 0 8px;">Actions</div>
  <div class="wire-box" style="font-size:11px; padding:8px; margin-bottom:6px; background:#d5d5d5;">Action Button</div>
  <div class="wire-box" style="font-size:11px; padding:8px; background:#ffd5d5;">Danger Action</div>
</div>
```

### Chat Layout Patterns

**Centered single-column** (WhatsApp/ChatGPT): Wrap chat-container in `max-width:600px; margin:0 auto;`

**Sidebar + Chat** (Slack/Discord): `display:grid; grid-template-columns:220px 1fr;` on chat-container

**Chat + Context Panel** (Intercom/Zendesk): `display:grid; grid-template-columns:1fr 280px;` on chat-container

### Responsive Chat Behavior

| Component | Mobile (<576px) | Tablet (576-1024px) | Desktop (1024px+) |
|-----------|----------------|--------------------|--------------------|
| Sidebar | Hidden → hamburger | Narrow (200px) | Full (250px) |
| Context Panel | Hidden (modal) | Hidden (modal) | Visible (280px) |
| Quick Replies | Horizontal scroll | Inline wrap | Inline wrap |
| Message max-width | 80% | 70% | 60% |
| Avatars | 20px | 24px | 28px |

On mobile, replace sidebar with hamburger icon in header:
```html
<div style="font-size:18px; color:#555;">☰</div>
```

## Side-by-Side Variants

When comparing layouts, generate a single HTML file with variants stacked vertically, separated by labels:

```html
<h2 style="color:#666; border-bottom:2px solid #ccc; padding-bottom:8px; margin:40px 0 20px;">
  Option A: [Description]
</h2>
<!-- variant A layout -->

<h2 style="color:#666; border-bottom:2px solid #ccc; padding-bottom:8px; margin:40px 0 20px;">
  Option B: [Description]
</h2>
<!-- variant B layout -->
```

## Multi-Page Flows

For user flows, create separate HTML files linked together:

- Name files descriptively: `01-login.html`, `02-dashboard.html`, `03-settings.html`
- Add navigation links between pages at the top:

```html
<div style="background:#333; color:#fff; padding:8px 16px; display:flex; gap:12px; margin-bottom:20px; border-radius:4px; font-size:13px;">
  <span style="opacity:0.5;">Flow:</span>
  <a href="01-login.html" style="color:#8cf;">Login</a>
  <span style="opacity:0.3;">→</span>
  <a href="02-dashboard.html" style="color:#8cf;">Dashboard</a>
  <span style="opacity:0.3;">→</span>
  <a href="03-settings.html" style="color:#8cf;">Settings</a>
</div>
```

After creating all files, open the first page: `open /tmp/wireframes/01-login.html`

## Responsive Previews

To show responsive breakpoints in a single file, embed iframes:

```html
<div style="display:flex; flex-wrap:wrap; gap:20px; align-items:flex-start;">
  <div>
    <div class="wire-label">Mobile (375px)</div>
    <iframe src="[page].html" style="width:375px; height:667px; border:2px solid #999; border-radius:4px;"></iframe>
  </div>
  <div>
    <div class="wire-label">Tablet (768px)</div>
    <iframe src="[page].html" style="width:768px; height:600px; border:2px solid #999; border-radius:4px;"></iframe>
  </div>
  <div>
    <div class="wire-label">Desktop (1200px)</div>
    <iframe src="[page].html" style="width:1200px; height:600px; border:2px solid #999; border-radius:4px;"></iframe>
  </div>
</div>
```

Save responsive preview as `responsive-[page].html` and open it.

## Viewing

**Default:** Open in browser with `open /tmp/wireframes/[filename].html`

**Screenshot mode:** When user asks for a screenshot or inline preview, use the `agent-browser` skill to navigate to `file:///tmp/wireframes/[filename].html` and capture a screenshot.

## Annotations

When the user asks for design notes, add numbered callouts:

```html
<div style="position:relative;">
  <!-- component being annotated -->
  <div style="position:absolute; top:-8px; right:-8px; background:#e74c3c; color:#fff;
    width:24px; height:24px; border-radius:50%; display:flex; align-items:center;
    justify-content:center; font-size:12px; font-weight:bold;">1</div>
</div>
```

Add a notes section at the bottom:

```html
<div style="margin-top:40px; padding:16px; background:#fff3cd; border-radius:4px; font-size:13px;">
  <strong>Design Notes:</strong>
  <ol>
    <li>Note about annotation 1</li>
    <li>Note about annotation 2</li>
  </ol>
</div>
```
