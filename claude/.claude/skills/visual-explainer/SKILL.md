---
name: visual-explainer
description: >
  Generate rich, self-contained HTML visualizations that replace ASCII art with interactive,
  styled pages. Use when the user invokes /visual-explainer, or proactively when about to
  render a complex table (4+ rows or 3+ columns) or diagram as ASCII. Auto-selects the best
  visualization type based on conversation context: diagrams, slides, diff reviews, project
  recaps, or knowledge organizers. Triggers: "visualize", "diagram", "visual", "show me",
  "make a slide deck", "recap this project", "organize this", or any context where a visual
  HTML page would communicate better than terminal text.
---

# Visual Explainer

Generate self-contained HTML files for diagrams, visualizations, slides, and organized knowledge. Auto-open in browser. Never fall back to ASCII art when this skill is loaded.

**Proactive table rendering.** When about to present tabular data as ASCII (4+ rows or 3+ columns), generate HTML instead. Don't wait for the user to ask.

**Output directory:** `/tmp/visual-explainer/` (create with `mkdir -p` before writing).
**Open after writing:** `open /tmp/visual-explainer/<filename>.html`

## Routing

Auto-select the visualization type based on conversation context:

| Type | When to use |
|------|------------|
| **Diagram** | Technical flows, architecture, sequences, state machines, ER diagrams, system overviews |
| **Slides** | User explicitly asks for slides/presentation/deck |
| **Diff Review** | User has been working on code changes, asks to review, or mentions diffs/PRs |
| **Project Recap** | User wants to understand project state, catch up, or rebuild mental model |
| **Knowledge Organizer** | Everything else: conversations, learning, meal plans, research, comparisons, brainstorming |

If ambiguous, prefer Knowledge Organizer — it handles the widest range of content.

## Pre-Generation Checklist

Before generating any HTML, read `./references/patterns.md` for CSS patterns, Mermaid theming, typography, and interactive features. Apply these patterns — don't reinvent them.

Pick a distinctive aesthetic each time. Vary fonts and palette. Choose from these directions:
- **Blueprint** — technical drawing feel, subtle grid, deep slate/blue, monospace labels
- **Editorial** — serif headlines, generous whitespace, muted earth tones
- **Paper/ink** — warm cream background, terracotta/sage accents, informal
- **Terminal** — green/amber on dark, monospace, CRT feel
- **IDE-inspired** — borrow real schemes: Dracula, Nord, Catppuccin, Solarized, Gruvbox

## 1. Diagram

Generate a single interactive HTML page with Mermaid.js or CSS Grid diagrams.

**Workflow:**
1. Identify diagram type: flowchart, sequence, ER, state machine, mind map, class diagram, or CSS Grid layout
2. For Mermaid: use TD (top-down) for 5+ nodes, LR only for simple 3-4 node linear flows
3. Wrap every Mermaid diagram in `.mermaid-wrap` with zoom controls (see patterns.md)
4. Include dark/light theme toggle
5. Write to `/tmp/visual-explainer/<topic-slug>.html`, open in browser

**When to use CSS Grid instead of Mermaid:** Dashboards, KPI cards, comparison layouts, anything where precise visual control matters more than automatic graph layout.

## 2. Slides

Generate a magazine-quality HTML slide deck. **Only when explicitly requested.**

**Workflow:**
1. Plan the narrative arc: impact (title) → context (overview) → deep dive → resolution
2. Assign a composition to each slide (centered, left-heavy, split, full-bleed) — vary consecutively
3. Use scroll-snap engine: `scroll-snap-type: y mandatory`, each slide `height: 100dvh`
4. Add IntersectionObserver for cinematic entrance animations with staggered child reveals
5. Include navigation: progress bar, nav dots, slide counter, arrow key support
6. Typography scale 2-3x larger than scrollable pages: 48-120px display, 28-48px headings
7. Target 18-25 slides. Every piece of source content must appear — don't drop content for aesthetics
8. Write to `/tmp/visual-explainer/slides-<topic>.html`, open in browser

**Slide types:** Title, Section Divider, Content, Split, Diagram, Dashboard, Table, Code, Quote, Full-Bleed.

## 3. Diff Review

Visual analysis of git changes as a styled HTML page.

**Workflow:**
1. Determine scope from context or ask:
   - Branch name → working tree vs that branch
   - Commit hash → `git show <hash>`
   - `HEAD` → uncommitted changes
   - PR number → `gh pr diff <n>`
   - Default → `main`
2. **Gather data:**
   - `git diff --stat <ref>` — file overview
   - `git diff --name-status <ref>` — new/modified/deleted
   - Line counts for key files
   - Grep for new exports, functions, types
   - Read all changed files
   - Check CHANGELOG.md status
3. **Generate HTML sections:**
   - Executive summary (why do these changes exist?)
   - KPI dashboard (lines added/removed, files changed, new modules)
   - Module architecture (Mermaid dependency graph with zoom)
   - Before/after panels (side-by-side, red/green diff colors)
   - Code review cards (Good/Bad/Ugly with green/red/amber borders)
   - Decision log (what was decided, why, alternatives)
   - Re-entry context (invariants, coupling, gotchas)
4. Write to `/tmp/visual-explainer/diff-review-<ref>.html`, open in browser

**Visual language:** Red for removed, green for added, yellow for modified, blue for context.

## 4. Project Recap

Rebuild mental model of a project's current state.

**Workflow:**
1. Determine time window (default 2 weeks): parse `2w`, `30d`, `3m` to git `--since`
2. **Gather data:**
   - README, package manifest for identity
   - `git log --oneline --since=<window>` — commit history
   - `git log --stat --since=<window>` — file change scope
   - `git status` — uncommitted work
   - Read key source files for architecture understanding
   - Look for TODOs, plan docs, RFCs
3. **Generate HTML sections:**
   - Project identity (what it does, version, elevator pitch)
   - Architecture snapshot (Mermaid diagram of modules/relationships with zoom)
   - Recent activity (narrative grouped by theme: features, fixes, refactors)
   - Decision log (extracted from commits, docs)
   - State dashboard (KPI cards: working/in-progress/broken/blocked)
   - Mental model essentials (invariants, coupling, gotchas, patterns)
   - Cognitive debt hotspots (amber cards with severity indicators)
   - Next steps (inferred from momentum)
4. Write to `/tmp/visual-explainer/recap-<project>-<window>.html`, open in browser

**Aesthetic:** Warm editorial with muted blues/greens, amber for debt hotspots.

## 5. Knowledge Organizer

The general-purpose visualizer for any conversation content.

**Workflow:**
1. Analyze the conversation to identify content structure:
   - Categories/groups → card grid or sectioned layout
   - Hierarchies → nested sections with depth tiers
   - Comparisons → side-by-side panels or table
   - Sequences/timelines → ordered flow with visual connectors
   - Lists with metadata → styled cards with badges/tags
   - Mixed content → combine layouts as needed
2. **Choose layout patterns:**
   - **Card grid** — for items with equal weight (recipes, concepts, tools)
   - **Grouped sections** — for categorized content (meal plan by day, concepts by topic)
   - **Comparison panels** — for side-by-side evaluation
   - **Timeline** — for sequential or chronological content
   - **Dashboard** — for status/metrics/KPIs
   - **Reference table** — for structured data with status badges
3. **Generate HTML with:**
   - Clear visual hierarchy (hero cards for key items, recessed cards for supporting)
   - Status badges where applicable (colored spans: green/red/amber/blue)
   - Collapsible `<details>` for dense content
   - Responsive grid layout
   - Dark/light theme support
4. Write to `/tmp/visual-explainer/<topic-slug>.html`, open in browser

**Key principle:** Extract structure from unstructured conversation. Group related items. Surface key takeaways. Make scannable what would otherwise be a wall of chat text.

**Examples:**
- Meal plan conversation → days as sections, meals as cards with ingredient tags
- Learning session → concept groups with definitions, examples, relationships
- Research → findings organized by theme with source citations
- Brainstorm → ideas clustered by category with priority indicators
- Tool comparison → side-by-side feature matrix with status badges

## HTML Base Structure

Every generated file follows this skeleton:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>[Title]</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=[Font Pair]&display=swap" rel="stylesheet">
  <style>
    :root { /* light theme variables */ }
    @media (prefers-color-scheme: dark) { :root { /* dark theme variables */ } }
    /* page styles */
  </style>
</head>
<body>
  <!-- content -->
  <script type="module">
    // Mermaid init, zoom controls, scroll spy, theme toggle
  </script>
</body>
</html>
```

Self-contained. No external CSS files. All libraries via CDN. Inline everything.
