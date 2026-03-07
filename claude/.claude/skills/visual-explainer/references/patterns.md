# Visual Explainer Reference Patterns

Read this file before generating any visualization. Apply these patterns directly.

## Theme Setup

Default to dark mode. Define dark palette as `:root` default, light as the override:

```css
:root {
  --bg: #1c1917; --bg-card: #292524; --bg-recessed: #1a1918;
  --text: #e7e5e4; --text-dim: #a8a29e; --text-accent: #5eead4;
  --accent: #2dd4bf; --accent-soft: #134e4a;
  --border: #44403c; --border-accent: #134e4a;
  --success: #22c55e; --warning: #fbbf24; --error: #f87171; --info: #60a5fa;
}
@media (prefers-color-scheme: light) {
  :root {
    --bg: #fafaf9; --bg-card: #ffffff; --bg-recessed: #f5f5f4;
    --text: #1c1917; --text-dim: #78716c; --text-accent: #0d9488;
    --accent: #0d9488; --accent-soft: #ccfbf1;
    --border: #e7e5e4; --border-accent: #99f6e4;
    --success: #16a34a; --warning: #d97706; --error: #dc2626; --info: #2563eb;
  }
}
```

Swap the palette per aesthetic. These are defaults — adapt hues to match the chosen direction.

## Background Atmosphere

Flat backgrounds feel dead. Add one:
```css
/* radial glow behind focal area */
body::before { content:''; position:fixed; inset:0; z-index:-1;
  background: radial-gradient(ellipse at 50% 30%, var(--accent-soft) 0%, transparent 60%); }
/* faint dot grid */
body { background-image: radial-gradient(var(--border) 1px, transparent 1px);
  background-size: 20px 20px; }
```

## Font Pairings (rotate between visualizations)

| Body / Headings | Mono / Labels | Feel |
|---|---|---|
| DM Sans | Fira Code | Friendly, developer |
| Instrument Serif | JetBrains Mono | Editorial, refined |
| IBM Plex Sans | IBM Plex Mono | Reliable, readable |
| Bricolage Grotesque | Fragment Mono | Bold, characterful |
| Plus Jakarta Sans | Azeret Mono | Rounded, approachable |
| Outfit | Space Mono | Clean geometric |
| Crimson Pro | Noto Sans Mono | Scholarly, serious |
| Fraunces | Source Code Pro | Warm, distinctive |

## Mermaid.js

**CDN with ELK layout:**
```html
<script type="module">
  import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';
  import elkLayouts from 'https://cdn.jsdelivr.net/npm/@mermaid-js/layout-elk/dist/mermaid-layout-elk.esm.min.mjs';
  mermaid.registerLayoutLoaders(elkLayouts);

  const isDark = !window.matchMedia('(prefers-color-scheme: light)').matches;
  mermaid.initialize({
    startOnLoad: true, layout: 'elk', theme: 'base',
    themeVariables: {
      primaryColor: isDark ? '#134e4a' : '#ccfbf1',
      primaryTextColor: isDark ? '#e7e5e4' : '#1c1917',
      primaryBorderColor: isDark ? '#2dd4bf' : '#0d9488',
      lineColor: isDark ? '#a8a29e' : '#78716c',
      secondaryColor: isDark ? '#292524' : '#f5f5f4',
      tertiaryColor: isDark ? '#1a1918' : '#fafaf9',
      background: isDark ? '#1c1917' : '#fafaf9',
    }
  });
</script>
```

**Always use `theme: 'base'`** — built-in themes ignore variable overrides.

**CSS overrides on Mermaid SVG** (required for dark/light mode):
```css
.mermaid .nodeLabel { color: var(--text) !important; }
.mermaid .edgeLabel { color: var(--text-dim) !important; background-color: var(--bg) !important; }
.mermaid .edgeLabel rect { fill: var(--bg) !important; }
```

**Never set `color:` in Mermaid `classDef`** — it hardcodes a value that breaks in the opposite theme.

**Layout direction:** TD (top-down) for 5+ nodes. LR only for simple 3-4 node linear flows.

## Mermaid Zoom Controls

Every `.mermaid-wrap` must include zoom controls. Use CSS `zoom` (not `transform: scale` — scale creates negative-space scrolling issues).

```html
<div class="mermaid-wrap">
  <div class="zoom-bar">
    <button onclick="zoomDiagram(this,1.2)" title="Zoom in">+</button>
    <button onclick="zoomDiagram(this,0.8)" title="Zoom out">&minus;</button>
    <button onclick="resetZoom(this)" title="Reset">Reset</button>
    <button onclick="expandDiagram(this)" title="Expand">&#x26F6;</button>
  </div>
  <div class="mermaid">
    graph TD
      A-->B
  </div>
</div>
```

```css
.mermaid-wrap { position: relative; overflow: auto; border: 1px solid var(--border);
  border-radius: 8px; padding: 24px; background: var(--bg-card); }
.zoom-bar { position: absolute; top: 8px; right: 8px; display: flex; gap: 4px; z-index: 10; }
.zoom-bar button { background: var(--bg-recessed); border: 1px solid var(--border);
  border-radius: 4px; padding: 4px 10px; cursor: pointer; font-size: 14px; color: var(--text); }
```

```javascript
function zoomDiagram(btn, factor) {
  const wrap = btn.closest('.mermaid-wrap');
  const cur = parseFloat(wrap.style.zoom || 1);
  wrap.style.zoom = Math.max(0.3, Math.min(3, cur * factor));
}
function resetZoom(btn) { btn.closest('.mermaid-wrap').style.zoom = 1; }
function expandDiagram(btn) {
  const svg = btn.closest('.mermaid-wrap').querySelector('svg');
  if (svg) { const w = window.open(); w.document.write(svg.outerHTML); }
}
```

Also support Ctrl/Cmd+scroll zoom on `.mermaid-wrap`.

## Chart.js

For bar/line/pie/doughnut/radar charts. CDN:
```html
<script src="https://cdn.jsdelivr.net/npm/chart.js@4/dist/chart.umd.min.js"></script>
```

## Depth Tiers

Use visual weight to create hierarchy:

```css
.card--hero { background: var(--accent-soft); border: 1px solid var(--border-accent);
  padding: 32px; border-radius: 12px; font-size: 1.15em; }
.card { background: var(--bg-card); border: 1px solid var(--border);
  padding: 24px; border-radius: 8px; }
.card--recessed { background: var(--bg-recessed); border: 1px solid var(--border);
  padding: 20px; border-radius: 8px; font-size: 0.95em; color: var(--text-dim); }
```

## Status Badges

```css
.badge { display: inline-block; padding: 2px 10px; border-radius: 12px;
  font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; }
.badge--pass { background: #dcfce7; color: #166534; }
.badge--fail { background: #fee2e2; color: #991b1b; }
.badge--warn { background: #fef3c7; color: #92400e; }
.badge--info { background: #dbeafe; color: #1e40af; }
/* dark mode overrides */
@media (prefers-color-scheme: dark) {
  .badge--pass { background: #166534; color: #dcfce7; }
  .badge--fail { background: #991b1b; color: #fee2e2; }
  .badge--warn { background: #92400e; color: #fef3c7; }
  .badge--info { background: #1e40af; color: #dbeafe; }
}
```

## Data Tables

Use real `<table>` elements, not divs:

```css
table { width: 100%; border-collapse: collapse; font-size: 14px; }
thead { position: sticky; top: 0; z-index: 5; }
th { background: var(--bg-recessed); text-align: left; padding: 10px 14px;
  font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px;
  color: var(--text-dim); border-bottom: 2px solid var(--border); }
td { padding: 10px 14px; border-bottom: 1px solid var(--border); }
tbody tr:hover { background: var(--accent-soft); }
```

## Code Review Cards

For diff-review Good/Bad/Ugly analysis:

```css
.review-card { border-left: 4px solid; padding: 16px 20px; margin-bottom: 12px;
  background: var(--bg-card); border-radius: 0 8px 8px 0; }
.review-card--good { border-left-color: var(--success); }
.review-card--bad { border-left-color: var(--error); }
.review-card--ugly { border-left-color: var(--warning); }
.review-card--question { border-left-color: var(--info); }
```

## Responsive Navigation (multi-section pages)

For pages with 4+ sections, add a sticky TOC:

```html
<div class="wrap">
  <nav class="toc" id="toc">
    <div class="toc-title">Contents</div>
    <a href="#s1">1. Section</a>
    <a href="#s2">2. Section</a>
  </nav>
  <div class="main">
    <!-- sections with id="s1", id="s2", etc. -->
  </div>
</div>
```

```css
.wrap { max-width: 1400px; margin: 0 auto;
  display: grid; grid-template-columns: 170px 1fr; gap: 0 40px; }
.main { min-width: 0; }
.toc { position: sticky; top: 24px; align-self: start; padding: 14px 0;
  grid-row: 1 / -1; max-height: calc(100dvh - 48px); overflow-y: auto; }
.toc a { display: block; font-size: 11px; color: var(--text-dim);
  text-decoration: none; padding: 4px 8px; border-radius: 5px;
  border-left: 2px solid transparent; transition: all 0.15s; }
.toc a.active { color: var(--text); border-left-color: var(--accent); }

@media (max-width: 1000px) {
  .wrap { grid-template-columns: 1fr; }
  .toc { position: sticky; top: 0; z-index: 200; display: flex; gap: 4px;
    overflow-x: auto; -webkit-overflow-scrolling: touch;
    background: var(--bg); border-bottom: 1px solid var(--border); padding: 8px; }
  .toc a { white-space: nowrap; flex-shrink: 0; border-left: none;
    border-bottom: 2px solid transparent; }
  .toc a.active { border-left: none; border-bottom-color: var(--accent); }
}
```

**Scroll spy JS** (place before `</body>`):
```javascript
const sections = document.querySelectorAll('[id^="s"]');
const tocLinks = document.querySelectorAll('.toc a');
const observer = new IntersectionObserver(entries => {
  entries.forEach(e => {
    if (e.isIntersecting) {
      tocLinks.forEach(a => a.classList.remove('active'));
      const link = document.querySelector(`.toc a[href="#${e.target.id}"]`);
      if (link) {
        link.classList.add('active');
        if (window.innerWidth <= 1000) link.scrollIntoView({ inline:'center', block:'nearest' });
      }
    }
  });
}, { rootMargin: '-10% 0px -80% 0px' });
sections.forEach(s => observer.observe(s));
```

## Slide Engine (slides only)

```css
.deck { scroll-snap-type: y mandatory; overflow-y: scroll; height: 100dvh; }
.slide { scroll-snap-align: start; height: 100dvh; display: flex;
  align-items: center; justify-content: center; padding: 60px 80px; position: relative; }
.slide-content { max-width: 1100px; width: 100%; opacity: 0;
  transform: translateY(30px); transition: all 0.6s ease-out; }
.slide.visible .slide-content { opacity: 1; transform: translateY(0); }
/* staggered child reveals */
.slide.visible .slide-content > *:nth-child(1) { transition-delay: 0.1s; }
.slide.visible .slide-content > *:nth-child(2) { transition-delay: 0.2s; }
.slide.visible .slide-content > *:nth-child(3) { transition-delay: 0.3s; }
```

**Slide observer:**
```javascript
const slides = document.querySelectorAll('.slide');
const slideObs = new IntersectionObserver(entries => {
  entries.forEach(e => e.target.classList.toggle('visible', e.isIntersecting));
}, { threshold: 0.5 });
slides.forEach(s => slideObs.observe(s));
```

Add navigation: arrow key listeners, slide counter, progress bar. Typography scale: 48-120px display, 28-48px headings, 16-24px body.

## Overflow Protection

Apply on every page:
```css
* { box-sizing: border-box; }
img, svg, pre { max-width: 100%; }
```

On grid/flex children: `min-width: 0;`
On text containers: `overflow-wrap: break-word;`
Never use `display: flex` on `<li>` — use absolute positioning for custom markers instead.

## KPI Dashboard Cards

```html
<div style="display:grid; grid-template-columns:repeat(auto-fit, minmax(160px,1fr)); gap:16px;">
  <div class="card" style="text-align:center;">
    <div style="font-size:36px; font-weight:700; color:var(--accent);">42</div>
    <div style="font-size:12px; color:var(--text-dim); text-transform:uppercase;">Files Changed</div>
  </div>
</div>
```
