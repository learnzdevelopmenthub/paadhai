---
issue: 2
title: Add plugin homepage using GitHub Pages
branch: feature/2-plugin-homepage-github-pages
milestone: null
status: confirmed
confirmed_at: 2026-04-08
---

## Overview

Build a world-class, animated, interactive landing page for the Paadhai plugin, hosted on GitHub Pages via the `gh-pages` branch. The page uses pure HTML/CSS/JS (no frameworks, no build step) with smooth scroll animations, a typewriter hero, animated pipeline diagram, tabbed installation guide, and a responsive skills grid.

## Files to Create

- `index.html` — full page markup
- `assets/css/style.css` — all styles, animations, responsive layout
- `assets/js/main.js` — scroll animations, typewriter, tabs, pipeline interactivity
- `assets/img/` — (empty dir placeholder; no images needed initially — icons via inline SVG or Unicode)

## Files to Modify

None — all content lives on the `gh-pages` branch, isolated from `main`/`develop`.

## Implementation Steps

1. **Create and push `gh-pages` branch from `main`**
   - Expected: branch `gh-pages` exists on origin

2. **Scaffold `index.html`**
   - Full semantic HTML5 page with nav, hero, how-it-works, skills, install, quick-start, footer
   - Expected: valid HTML file, opens in browser

3. **Write `assets/css/style.css`**
   - Dark theme (`#0d1117` base), amber/gold accent (`#f0a500`)
   - CSS custom properties for theming
   - Smooth scroll, sticky nav with scroll-progress bar
   - Hero gradient text, typewriter cursor blink
   - Pipeline step cards with connector lines
   - Skills grid with hover lift effect
   - Install tabs
   - Fade-in / slide-up entry animations (CSS keyframes, triggered by class)
   - Mobile-responsive (single column below 768px)
   - Expected: styled page with no layout breaks

4. **Write `assets/js/main.js`**
   - Typewriter effect on hero tagline (vanilla JS, no library)
   - IntersectionObserver to add `.visible` class triggering CSS entry animations
   - Pipeline step sequential highlight on scroll
   - Install tab switcher (click to show/hide platform blocks)
   - Scroll progress bar update on `scroll` event
   - Copy-to-clipboard on code blocks (click icon → copy → show "Copied!" flash)
   - Expected: all interactions work, no console errors

5. **Enable GitHub Pages in repo settings**
   - Source: `gh-pages` branch, root `/`
   - Expected: site live at `https://learnzdevelopmenthub.github.io/paadhai`

6. **Commit and push all files to `gh-pages`**
   - Expected: GitHub Actions deploys page within ~60s

## Page Sections

| Section | Content |
|---------|---------|
| Nav | Logo, smooth-scroll links, GitHub star button |
| Hero | Animated name + tagline typewriter, agent logos row, CTA "Get Started" |
| How it Works | 4-pipeline animated flow (SETUP → DEV LOOP → RELEASE → EMERGENCY) |
| Skills | 21 skills in a responsive card grid with hover descriptions |
| Installation | Tabbed: Claude Code / Cursor / Codex CLI / Gemini CLI |
| Quick Start | Syntax-highlighted code block with copy button |
| Footer | License, GitHub link, "Built with Paadhai" |

## Security Considerations

> No security-relevant attack surfaces identified for this issue.

Static HTML/CSS/JS page with no user input, no server, no API calls, and no external dependencies beyond Google Fonts (optional). No sensitive data is exposed.

### Security Checklist
- [x] No user input — no forms, no data collection
- [x] No external JS CDN dependencies (vanilla only)
- [x] No sensitive data in source
- [x] CSP-compatible (no `eval`, no `innerHTML` with user data)

## AC Mapping

| AC | How Addressed |
|----|--------------|
| AC-1: Public-facing homepage exists | `gh-pages` branch served by GitHub Pages |
| AC-2: All major AI agents referenced | Install tabs for Claude Code, Cursor, Codex CLI, Gemini CLI |
| AC-3: Installation instructions visible | Tabbed installation section |
| AC-4: Professional appearance | Dark theme, animations, responsive layout |

## Definition of Done

- [ ] Page loads at `learnzdevelopmenthub.github.io/paadhai`
- [ ] All 4 install tabs work
- [ ] Typewriter animation plays on load
- [ ] Scroll animations trigger on all sections
- [ ] Copy-to-clipboard works on code blocks
- [ ] Mobile layout correct at 375px width
- [ ] No console errors in browser DevTools
- [ ] All 21 skills listed on page

## ADR

ADR: declined — no new architectural decisions; static site on gh-pages is an established pattern.
