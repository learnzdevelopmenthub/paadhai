---
issue: 2
title: Add plugin homepage using GitHub Pages
branch: feature/2-plugin-homepage-github-pages
---

## Progress

| Step | Description | Status |
|------|-------------|--------|
| 1 | Create and push `gh-pages` branch | done |
| 2 | Scaffold `index.html` | done |
| 3 | Write `assets/css/style.css` | done |
| 4 | Write `assets/js/main.js` | done |
| 5 | Enable GitHub Pages via API | done |
| 6 | Commit and push to `gh-pages` | done |

---

## Step 1 — Create and push `gh-pages` branch

```bash
git checkout main
git checkout -b gh-pages
git push -u origin gh-pages
git checkout feature/2-plugin-homepage-github-pages
```

**Expected:** Branch `gh-pages` exists on `origin`. Return to feature branch.

---

## Step 2 — Scaffold `index.html`

Create `index.html` in the root of the `gh-pages` branch. Since we work on the feature branch and commit to `gh-pages` at the end, create this file now in a staging area, then push in Step 6.

Create file `index.html` with this exact content:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta name="description" content="Paadhai — AI-native SDLC pipeline. 21 skills covering every stage of software development for Claude Code, Cursor, Codex CLI, and Gemini CLI." />
  <title>Paadhai — AI-native SDLC Pipeline</title>
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet" />
  <link rel="stylesheet" href="assets/css/style.css" />
</head>
<body>

  <!-- NAV -->
  <div class="scroll-progress" id="scrollProgress"></div>
  <nav class="nav" id="nav">
    <div class="nav-inner">
      <a href="#" class="nav-logo">
        <span class="logo-text">பாதை</span>
        <span class="logo-sub">paadhai</span>
      </a>
      <ul class="nav-links">
        <li><a href="#how-it-works">How it works</a></li>
        <li><a href="#skills">Skills</a></li>
        <li><a href="#install">Install</a></li>
        <li><a href="#quickstart">Quick Start</a></li>
      </ul>
      <a href="https://github.com/learnzdevelopmenthub/paadhai" class="btn btn-outline" target="_blank" rel="noopener">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0 0 24 12c0-6.63-5.37-12-12-12z"/></svg>
        GitHub
      </a>
    </div>
  </nav>

  <!-- HERO -->
  <section class="hero" id="hero">
    <div class="hero-bg">
      <div class="hero-grid"></div>
      <div class="hero-glow"></div>
    </div>
    <div class="container hero-content">
      <div class="hero-badge animate-fade-up">Open Source · MIT License</div>
      <h1 class="hero-title animate-fade-up delay-1">
        <span class="title-tamil">பாதை</span>
        <span class="title-divider"></span>
        <span class="title-main">Paadhai</span>
      </h1>
      <p class="hero-tagline animate-fade-up delay-2">
        <span id="typewriter"></span><span class="cursor">|</span>
      </p>
      <p class="hero-sub animate-fade-up delay-3">21 skills. Every stage of software development. Zero improvisation.</p>
      <div class="hero-agents animate-fade-up delay-4">
        <span class="agent-chip">Claude Code</span>
        <span class="agent-chip">Cursor</span>
        <span class="agent-chip">Codex CLI</span>
        <span class="agent-chip">Gemini CLI</span>
        <span class="agent-chip">OpenCode</span>
      </div>
      <div class="hero-cta animate-fade-up delay-5">
        <a href="#install" class="btn btn-primary">Get Started</a>
        <a href="#how-it-works" class="btn btn-ghost">See how it works →</a>
      </div>
    </div>
    <div class="hero-scroll-hint animate-fade-up delay-5">
      <span>scroll</span>
      <div class="scroll-line"></div>
    </div>
  </section>

  <!-- HOW IT WORKS -->
  <section class="section" id="how-it-works">
    <div class="container">
      <div class="section-header reveal">
        <p class="section-label">The Pipeline</p>
        <h2 class="section-title">Structured from day one to production</h2>
        <p class="section-desc">Every skill knows its place. Every handoff is explicit. No improvisation where consistency matters.</p>
      </div>
      <div class="pipelines reveal">

        <div class="pipeline-track">
          <div class="pipeline-card" data-pipeline="setup">
            <div class="pipeline-tag">SETUP</div>
            <div class="pipeline-steps">
              <div class="pipe-step">/project-init</div>
              <div class="pipe-arrow">→</div>
              <div class="pipe-step">/project-plan</div>
              <div class="pipe-arrow">→</div>
              <div class="pipe-step">/release-plan</div>
            </div>
            <p class="pipeline-desc">Once per project — scaffold config, generate SRS, create GitHub milestones and issues.</p>
          </div>

          <div class="pipeline-card featured" data-pipeline="dev">
            <div class="pipeline-tag tag-gold">DEV LOOP</div>
            <div class="pipeline-steps">
              <div class="pipe-step">/dev-start</div>
              <div class="pipe-arrow">→</div>
              <div class="pipe-step">/dev-plan</div>
              <div class="pipe-arrow">→</div>
              <div class="pipe-step">/dev-test</div>
              <div class="pipe-arrow">→</div>
              <div class="pipe-step">/dev-implement</div>
              <div class="pipe-arrow">→</div>
              <div class="pipe-step">/dev-pr</div>
              <div class="pipe-arrow">→</div>
              <div class="pipe-step">/dev-audit</div>
              <div class="pipe-arrow">→</div>
              <div class="pipe-step">/dev-ship</div>
            </div>
            <p class="pipeline-desc">Once per issue — branch creation through merge with security review and board sync.</p>
          </div>

          <div class="pipeline-card" data-pipeline="release">
            <div class="pipeline-tag">RELEASE</div>
            <div class="pipeline-steps">
              <div class="pipe-step">/dev-release</div>
            </div>
            <p class="pipeline-desc">Tag version, generate changelog, publish GitHub Release, close milestone.</p>
          </div>

          <div class="pipeline-card" data-pipeline="emergency">
            <div class="pipeline-tag tag-red">EMERGENCY</div>
            <div class="pipeline-steps">
              <div class="pipe-step">/dev-hotfix</div>
              <div class="pipe-arrow">→</div>
              <div class="pipe-step">/dev-pr</div>
              <div class="pipe-arrow">→</div>
              <div class="pipe-step">/dev-ship</div>
              <div class="pipe-arrow">→</div>
              <div class="pipe-step">/dev-release</div>
            </div>
            <p class="pipeline-desc">Fast-path for urgent production fixes — branch from main, minimal fix, direct to production.</p>
          </div>
        </div>

      </div>
    </div>
  </section>

  <!-- SKILLS -->
  <section class="section section-dark" id="skills">
    <div class="container">
      <div class="section-header reveal">
        <p class="section-label">21 Skills</p>
        <h2 class="section-title">Every stage covered</h2>
        <p class="section-desc">Self-contained workflows. Each skill knows what comes before it and what comes next.</p>
      </div>
      <div class="skills-grid reveal">
        <div class="skill-card"><span class="skill-cmd">/project-init</span><p>Initialize repo, write config, create branches</p></div>
        <div class="skill-card"><span class="skill-cmd">/project-plan</span><p>Generate SRS from your product idea</p></div>
        <div class="skill-card"><span class="skill-cmd">/release-plan</span><p>Create GitHub milestones and issues</p></div>
        <div class="skill-card skill-gold"><span class="skill-cmd">/dev-start</span><p>Pick issue, create branch, sync board</p></div>
        <div class="skill-card skill-gold"><span class="skill-cmd">/dev-plan</span><p>Security assessment, design review, implementation plan</p></div>
        <div class="skill-card skill-gold"><span class="skill-cmd">/dev-test</span><p>Test plan + stubs from acceptance criteria</p></div>
        <div class="skill-card skill-gold"><span class="skill-cmd">/dev-implement</span><p>Execute plan step by step with code review</p></div>
        <div class="skill-card skill-gold"><span class="skill-cmd">/dev-pr</span><p>Push branch, open PR, poll CI</p></div>
        <div class="skill-card skill-gold"><span class="skill-cmd">/dev-audit</span><p>Architecture + security + compatibility review</p></div>
        <div class="skill-card skill-gold"><span class="skill-cmd">/dev-ship</span><p>Merge PR, update board, clean up branch</p></div>
        <div class="skill-card"><span class="skill-cmd">/dev-release</span><p>Tag, changelog, GitHub Release, close milestone</p></div>
        <div class="skill-card skill-red"><span class="skill-cmd">/dev-hotfix</span><p>Emergency fix — fast-path from main</p></div>
        <div class="skill-card skill-red"><span class="skill-cmd">/dev-rollback</span><p>Recover from a bad release</p></div>
        <div class="skill-card"><span class="skill-cmd">/dev-debug</span><p>4-phase systematic debugging with escalation</p></div>
        <div class="skill-card"><span class="skill-cmd">/dev-unblock</span><p>Fix CI failures and merge conflicts</p></div>
        <div class="skill-card"><span class="skill-cmd">/dev-parallel</span><p>Dispatch independent tasks to parallel subagents</p></div>
        <div class="skill-card"><span class="skill-cmd">/dev-deps</span><p>CVE scan, license check, outdated packages</p></div>
        <div class="skill-card"><span class="skill-cmd">/dev-docs</span><p>Generate API, user, and architecture docs</p></div>
        <div class="skill-card"><span class="skill-cmd">/dev-adr</span><p>Record Architecture Decision Records</p></div>
        <div class="skill-card"><span class="skill-cmd">/dev-status</span><p>Read-only project progress dashboard</p></div>
        <div class="skill-card"><span class="skill-cmd">/paadhai-skill</span><p>Scaffold and register new skills</p></div>
      </div>
    </div>
  </section>

  <!-- INSTALL -->
  <section class="section" id="install">
    <div class="container">
      <div class="section-header reveal">
        <p class="section-label">Installation</p>
        <h2 class="section-title">Works with your AI agent</h2>
        <p class="section-desc">One command. Any agent.</p>
      </div>
      <div class="install-tabs reveal">
        <div class="tab-buttons">
          <button class="tab-btn active" data-tab="claude">Claude Code</button>
          <button class="tab-btn" data-tab="cursor">Cursor</button>
          <button class="tab-btn" data-tab="codex">Codex CLI</button>
          <button class="tab-btn" data-tab="gemini">Gemini CLI</button>
        </div>
        <div class="tab-panels">
          <div class="tab-panel active" id="tab-claude">
            <div class="code-block">
              <button class="copy-btn" title="Copy">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                <span>Copy</span>
              </button>
              <pre><code>/plugin install paadhai</code></pre>
            </div>
            <p class="install-note">Or manually: <code>cp -r paadhai/.claude/skills/* ~/.claude/skills/</code></p>
          </div>
          <div class="tab-panel" id="tab-cursor">
            <p class="install-note">Search <strong>"Paadhai"</strong> in the Cursor plugin marketplace, or:</p>
            <div class="code-block">
              <button class="copy-btn" title="Copy">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                <span>Copy</span>
              </button>
              <pre><code>git clone https://github.com/learnzdevelopmenthub/paadhai.git
cp -r paadhai/.cursor-plugin/ your-project/</code></pre>
            </div>
          </div>
          <div class="tab-panel" id="tab-codex">
            <div class="code-block">
              <button class="copy-btn" title="Copy">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                <span>Copy</span>
              </button>
              <pre><code>git clone https://github.com/learnzdevelopmenthub/paadhai.git
cp -r paadhai/.codex-plugin/ your-project/
cp paadhai/AGENTS.md your-project/</code></pre>
            </div>
          </div>
          <div class="tab-panel" id="tab-gemini">
            <div class="code-block">
              <button class="copy-btn" title="Copy">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                <span>Copy</span>
              </button>
              <pre><code>gemini extensions install paadhai</code></pre>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- QUICK START -->
  <section class="section section-dark" id="quickstart">
    <div class="container">
      <div class="section-header reveal">
        <p class="section-label">Quick Start</p>
        <h2 class="section-title">From idea to production</h2>
        <p class="section-desc">Three pipelines. One config file. No guesswork.</p>
      </div>
      <div class="quickstart-block reveal">
        <div class="code-block code-block-lg">
          <button class="copy-btn" title="Copy">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
            <span>Copy</span>
          </button>
          <pre><code><span class="c-comment"># 1. Set up your project (once)</span>
/project-init     <span class="c-comment"># creates .paadhai.json</span>
/project-plan     <span class="c-comment"># generates docs/srs.md</span>
/release-plan     <span class="c-comment"># creates GitHub milestones + issues</span>

<span class="c-comment"># 2. Start a feature (per issue)</span>
/dev-start <span class="c-num">#1</span>     <span class="c-comment"># branch: feature/1-my-feature</span>
/dev-plan         <span class="c-comment"># security analysis + implementation plan</span>
/dev-test         <span class="c-comment"># test plan + stubs</span>
/dev-implement    <span class="c-comment"># execute the plan</span>
/dev-pr           <span class="c-comment"># open PR, poll CI</span>
/dev-audit        <span class="c-comment"># architecture + security review</span>
/dev-ship         <span class="c-comment"># merge + board updated</span>

<span class="c-comment"># 3. Release</span>
/dev-release      <span class="c-comment"># tag, changelog, GitHub Release</span></code></pre>
        </div>
      </div>
    </div>
  </section>

  <!-- FOOTER -->
  <footer class="footer">
    <div class="container footer-inner">
      <div class="footer-brand">
        <span class="logo-text">பாதை</span>
        <span class="footer-tagline">The path through your SDLC.</span>
      </div>
      <div class="footer-links">
        <a href="https://github.com/learnzdevelopmenthub/paadhai" target="_blank" rel="noopener">GitHub</a>
        <a href="https://github.com/learnzdevelopmenthub/paadhai/blob/main/CONTRIBUTING.md" target="_blank" rel="noopener">Contributing</a>
        <a href="https://github.com/learnzdevelopmenthub/paadhai/blob/main/LICENSE" target="_blank" rel="noopener">MIT License</a>
      </div>
      <p class="footer-copy">Built with Paadhai · © 2026 Learnz Development Hub</p>
    </div>
  </footer>

  <script src="assets/js/main.js"></script>
</body>
</html>
```

**Expected:** File created. Open in browser — page renders with placeholder styling.

---

## Step 3 — Write `assets/css/style.css`

Create `assets/css/style.css` with this exact content:

```css
/* ===========================
   RESET & BASE
   =========================== */
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

:root {
  --bg:        #0d1117;
  --bg-2:      #161b22;
  --bg-3:      #21262d;
  --border:    #30363d;
  --text:      #e6edf3;
  --text-muted:#8b949e;
  --gold:      #f0a500;
  --gold-dim:  #f0a50022;
  --gold-glow: #f0a50044;
  --red:       #f85149;
  --red-dim:   #f8514922;
  --green:     #3fb950;
  --radius:    12px;
  --radius-sm: 8px;
  --font:      'Inter', system-ui, sans-serif;
  --mono:      'JetBrains Mono', 'Fira Code', monospace;
  --nav-h:     64px;
  --transition: 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

html { scroll-behavior: smooth; font-size: 16px; }

body {
  background: var(--bg);
  color: var(--text);
  font-family: var(--font);
  line-height: 1.6;
  overflow-x: hidden;
}

a { color: inherit; text-decoration: none; }
img { max-width: 100%; }

/* ===========================
   SCROLL PROGRESS
   =========================== */
.scroll-progress {
  position: fixed;
  top: 0; left: 0;
  height: 2px;
  width: 0%;
  background: linear-gradient(90deg, var(--gold), #ff8c00);
  z-index: 1000;
  transition: width 0.1s linear;
}

/* ===========================
   NAV
   =========================== */
.nav {
  position: fixed;
  top: 0; left: 0; right: 0;
  height: var(--nav-h);
  z-index: 100;
  transition: background var(--transition), border-color var(--transition);
  border-bottom: 1px solid transparent;
}

.nav.scrolled {
  background: rgba(13, 17, 23, 0.92);
  backdrop-filter: blur(12px);
  border-color: var(--border);
}

.nav-inner {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 24px;
  height: 100%;
  display: flex;
  align-items: center;
  gap: 32px;
}

.nav-logo {
  display: flex;
  align-items: baseline;
  gap: 8px;
  font-weight: 700;
}

.logo-text {
  font-size: 1.25rem;
  color: var(--gold);
  font-family: var(--font);
}

.logo-sub {
  font-size: 0.85rem;
  color: var(--text-muted);
  font-family: var(--mono);
}

.nav-links {
  display: flex;
  list-style: none;
  gap: 8px;
  margin-left: auto;
}

.nav-links a {
  color: var(--text-muted);
  font-size: 0.875rem;
  padding: 6px 12px;
  border-radius: var(--radius-sm);
  transition: color var(--transition), background var(--transition);
}

.nav-links a:hover {
  color: var(--text);
  background: var(--bg-3);
}

/* ===========================
   BUTTONS
   =========================== */
.btn {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 10px 20px;
  border-radius: var(--radius-sm);
  font-size: 0.875rem;
  font-weight: 600;
  cursor: pointer;
  transition: all var(--transition);
  border: none;
  font-family: var(--font);
  white-space: nowrap;
}

.btn-primary {
  background: var(--gold);
  color: #000;
}
.btn-primary:hover { background: #ffc233; transform: translateY(-1px); box-shadow: 0 4px 20px var(--gold-glow); }

.btn-outline {
  background: transparent;
  border: 1px solid var(--border);
  color: var(--text);
}
.btn-outline:hover { border-color: var(--gold); color: var(--gold); }

.btn-ghost {
  background: transparent;
  color: var(--text-muted);
}
.btn-ghost:hover { color: var(--text); }

/* ===========================
   HERO
   =========================== */
.hero {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
  padding: calc(var(--nav-h) + 60px) 24px 80px;
}

.hero-bg {
  position: absolute;
  inset: 0;
  pointer-events: none;
}

.hero-grid {
  position: absolute;
  inset: 0;
  background-image:
    linear-gradient(var(--border) 1px, transparent 1px),
    linear-gradient(90deg, var(--border) 1px, transparent 1px);
  background-size: 60px 60px;
  opacity: 0.3;
  mask-image: radial-gradient(ellipse 80% 60% at 50% 50%, black, transparent);
}

.hero-glow {
  position: absolute;
  width: 600px; height: 600px;
  top: 50%; left: 50%;
  transform: translate(-50%, -60%);
  background: radial-gradient(circle, var(--gold-glow) 0%, transparent 70%);
  animation: pulse-glow 4s ease-in-out infinite;
}

@keyframes pulse-glow {
  0%, 100% { opacity: 0.6; transform: translate(-50%, -60%) scale(1); }
  50% { opacity: 1; transform: translate(-50%, -60%) scale(1.1); }
}

.hero-content {
  position: relative;
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 24px;
}

.hero-badge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 6px 14px;
  border: 1px solid var(--border);
  border-radius: 100px;
  font-size: 0.8rem;
  color: var(--text-muted);
  background: var(--bg-2);
}

.hero-title {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

.title-tamil {
  font-size: clamp(3rem, 8vw, 6rem);
  font-weight: 700;
  color: var(--gold);
  line-height: 1;
  letter-spacing: -2px;
}

.title-divider {
  display: block;
  width: 60px;
  height: 2px;
  background: var(--border);
  margin: 8px 0;
}

.title-main {
  font-size: clamp(1.5rem, 4vw, 2.5rem);
  font-weight: 400;
  color: var(--text-muted);
  font-family: var(--mono);
  letter-spacing: 4px;
  text-transform: lowercase;
}

.hero-tagline {
  font-size: clamp(1.1rem, 2.5vw, 1.4rem);
  color: var(--text);
  font-weight: 500;
  min-height: 2em;
  display: flex;
  align-items: center;
  gap: 0;
}

.cursor {
  display: inline-block;
  color: var(--gold);
  animation: blink 1s step-end infinite;
  margin-left: 2px;
}

@keyframes blink { 0%, 100% { opacity: 1; } 50% { opacity: 0; } }

.hero-sub {
  color: var(--text-muted);
  font-size: 1rem;
  max-width: 480px;
}

.hero-agents {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  justify-content: center;
}

.agent-chip {
  padding: 6px 14px;
  border-radius: 100px;
  background: var(--bg-3);
  border: 1px solid var(--border);
  font-size: 0.8rem;
  color: var(--text-muted);
  font-family: var(--mono);
  transition: all var(--transition);
}

.agent-chip:hover {
  border-color: var(--gold);
  color: var(--gold);
}

.hero-cta {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  justify-content: center;
}

.hero-scroll-hint {
  position: absolute;
  bottom: 32px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  color: var(--text-muted);
  font-size: 0.7rem;
  letter-spacing: 2px;
  text-transform: uppercase;
}

.scroll-line {
  width: 1px;
  height: 40px;
  background: linear-gradient(to bottom, var(--text-muted), transparent);
  animation: scroll-drop 1.5s ease-in-out infinite;
}

@keyframes scroll-drop {
  0% { transform: scaleY(0); transform-origin: top; }
  50% { transform: scaleY(1); transform-origin: top; }
  51% { transform: scaleY(1); transform-origin: bottom; }
  100% { transform: scaleY(0); transform-origin: bottom; }
}

/* ===========================
   SECTIONS
   =========================== */
.section { padding: 100px 0; }
.section-dark { background: var(--bg-2); }

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 24px;
}

.section-header {
  text-align: center;
  margin-bottom: 64px;
}

.section-label {
  font-size: 0.8rem;
  font-family: var(--mono);
  letter-spacing: 3px;
  text-transform: uppercase;
  color: var(--gold);
  margin-bottom: 12px;
}

.section-title {
  font-size: clamp(1.75rem, 4vw, 2.5rem);
  font-weight: 700;
  margin-bottom: 16px;
  letter-spacing: -0.5px;
}

.section-desc {
  color: var(--text-muted);
  max-width: 520px;
  margin: 0 auto;
  font-size: 1.05rem;
}

/* ===========================
   PIPELINE
   =========================== */
.pipeline-track {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.pipeline-card {
  background: var(--bg-2);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 24px 28px;
  transition: all var(--transition);
}

.pipeline-card:hover {
  border-color: var(--border);
  transform: translateX(4px);
}

.pipeline-card.featured {
  border-color: var(--gold);
  background: linear-gradient(135deg, var(--bg-2), var(--gold-dim));
}

.pipeline-tag {
  font-size: 0.7rem;
  font-family: var(--mono);
  letter-spacing: 3px;
  text-transform: uppercase;
  color: var(--text-muted);
  margin-bottom: 12px;
}

.tag-gold { color: var(--gold); }
.tag-red { color: var(--red); }

.pipeline-steps {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 12px;
}

.pipe-step {
  background: var(--bg-3);
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  padding: 6px 12px;
  font-size: 0.8rem;
  font-family: var(--mono);
  color: var(--text);
  transition: all var(--transition);
}

.pipeline-card.featured .pipe-step {
  border-color: var(--gold-dim);
}

.pipeline-card:hover .pipe-step {
  border-color: var(--gold);
  color: var(--gold);
}

.pipe-arrow {
  color: var(--text-muted);
  font-size: 0.9rem;
}

.pipeline-desc {
  color: var(--text-muted);
  font-size: 0.9rem;
}

/* ===========================
   SKILLS GRID
   =========================== */
.skills-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 12px;
}

.skill-card {
  background: var(--bg);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 20px;
  transition: all var(--transition);
  cursor: default;
}

.skill-card:hover {
  border-color: var(--border);
  transform: translateY(-3px);
  box-shadow: 0 8px 24px rgba(0,0,0,0.3);
}

.skill-card.skill-gold:hover { border-color: var(--gold); box-shadow: 0 8px 24px var(--gold-dim); }
.skill-card.skill-red:hover { border-color: var(--red); box-shadow: 0 8px 24px var(--red-dim); }

.skill-cmd {
  display: block;
  font-family: var(--mono);
  font-size: 0.85rem;
  color: var(--gold);
  margin-bottom: 8px;
  font-weight: 500;
}

.skill-card.skill-red .skill-cmd { color: var(--red); }

.skill-card p {
  font-size: 0.85rem;
  color: var(--text-muted);
  line-height: 1.5;
}

/* ===========================
   INSTALL TABS
   =========================== */
.install-tabs {
  max-width: 720px;
  margin: 0 auto;
}

.tab-buttons {
  display: flex;
  gap: 4px;
  background: var(--bg-2);
  border: 1px solid var(--border);
  border-radius: var(--radius) var(--radius) 0 0;
  padding: 8px;
  overflow-x: auto;
}

.tab-btn {
  padding: 8px 16px;
  border-radius: var(--radius-sm);
  border: none;
  background: transparent;
  color: var(--text-muted);
  font-size: 0.875rem;
  font-family: var(--font);
  cursor: pointer;
  transition: all var(--transition);
  white-space: nowrap;
}

.tab-btn.active, .tab-btn:hover {
  background: var(--bg-3);
  color: var(--text);
}

.tab-btn.active { color: var(--gold); }

.tab-panels {
  border: 1px solid var(--border);
  border-top: none;
  border-radius: 0 0 var(--radius) var(--radius);
  background: var(--bg-2);
  overflow: hidden;
}

.tab-panel {
  display: none;
  padding: 24px;
}

.tab-panel.active { display: block; }

.install-note {
  color: var(--text-muted);
  font-size: 0.9rem;
  margin-bottom: 12px;
}

.install-note code {
  font-family: var(--mono);
  font-size: 0.85rem;
  background: var(--bg-3);
  padding: 2px 6px;
  border-radius: 4px;
  color: var(--text);
}

/* ===========================
   CODE BLOCKS
   =========================== */
.code-block {
  position: relative;
  background: var(--bg);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  overflow: hidden;
}

.code-block-lg { background: var(--bg-2); }

.code-block pre {
  padding: 20px 24px;
  overflow-x: auto;
}

.code-block code {
  font-family: var(--mono);
  font-size: 0.875rem;
  line-height: 1.7;
  color: var(--text);
}

.c-comment { color: var(--text-muted); }
.c-num { color: var(--green); }

.copy-btn {
  position: absolute;
  top: 10px; right: 10px;
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 6px 10px;
  background: var(--bg-3);
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  color: var(--text-muted);
  font-size: 0.75rem;
  font-family: var(--font);
  cursor: pointer;
  transition: all var(--transition);
}

.copy-btn:hover { color: var(--text); border-color: var(--gold); }
.copy-btn.copied { color: var(--green); border-color: var(--green); }

/* ===========================
   QUICK START
   =========================== */
.quickstart-block { max-width: 720px; margin: 0 auto; }

/* ===========================
   FOOTER
   =========================== */
.footer {
  border-top: 1px solid var(--border);
  padding: 48px 0;
}

.footer-inner {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
  text-align: center;
}

.footer-brand {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.footer-tagline {
  color: var(--text-muted);
  font-size: 0.9rem;
}

.footer-links {
  display: flex;
  gap: 24px;
  flex-wrap: wrap;
  justify-content: center;
}

.footer-links a {
  color: var(--text-muted);
  font-size: 0.875rem;
  transition: color var(--transition);
}

.footer-links a:hover { color: var(--gold); }

.footer-copy {
  color: var(--text-muted);
  font-size: 0.8rem;
}

/* ===========================
   ANIMATIONS
   =========================== */
.animate-fade-up {
  opacity: 0;
  transform: translateY(24px);
  animation: fade-up 0.7s ease forwards;
}

.delay-1 { animation-delay: 0.1s; }
.delay-2 { animation-delay: 0.25s; }
.delay-3 { animation-delay: 0.4s; }
.delay-4 { animation-delay: 0.55s; }
.delay-5 { animation-delay: 0.7s; }

@keyframes fade-up {
  to { opacity: 1; transform: translateY(0); }
}

.reveal {
  opacity: 0;
  transform: translateY(32px);
  transition: opacity 0.7s ease, transform 0.7s ease;
}

.reveal.visible {
  opacity: 1;
  transform: translateY(0);
}

/* ===========================
   RESPONSIVE
   =========================== */
@media (max-width: 768px) {
  .nav-links { display: none; }
  .hero-cta { flex-direction: column; align-items: center; }
  .section { padding: 72px 0; }
  .pipeline-steps { gap: 6px; }
  .pipe-step { font-size: 0.75rem; padding: 4px 10px; }
  .skills-grid { grid-template-columns: 1fr 1fr; }
  .tab-buttons { gap: 2px; }
}

@media (max-width: 480px) {
  .skills-grid { grid-template-columns: 1fr; }
  .hero-agents { gap: 6px; }
}
```

**Expected:** Fully styled page with dark theme, gold accents, responsive layout.

---

## Step 4 — Write `assets/js/main.js`

Create `assets/js/main.js` with this exact content:

```js
// ===========================
// SCROLL PROGRESS BAR
// ===========================
const scrollProgress = document.getElementById('scrollProgress');
const nav = document.getElementById('nav');

window.addEventListener('scroll', () => {
  const scrollTop = window.scrollY;
  const docHeight = document.documentElement.scrollHeight - window.innerHeight;
  const pct = docHeight > 0 ? (scrollTop / docHeight) * 100 : 0;
  scrollProgress.style.width = pct + '%';
  nav.classList.toggle('scrolled', scrollTop > 20);
});

// ===========================
// TYPEWRITER
// ===========================
const phrases = [
  'AI-native SDLC pipeline.',
  '21 skills. Zero improvisation.',
  'From idea to production.',
  'Every stage. Every agent.',
];

const typewriterEl = document.getElementById('typewriter');
let phraseIdx = 0;
let charIdx = 0;
let deleting = false;
let pause = false;

function type() {
  if (pause) return;
  const current = phrases[phraseIdx];

  if (!deleting) {
    typewriterEl.textContent = current.slice(0, ++charIdx);
    if (charIdx === current.length) {
      pause = true;
      setTimeout(() => { deleting = true; pause = false; type(); }, 2000);
      return;
    }
  } else {
    typewriterEl.textContent = current.slice(0, --charIdx);
    if (charIdx === 0) {
      deleting = false;
      phraseIdx = (phraseIdx + 1) % phrases.length;
    }
  }

  setTimeout(type, deleting ? 40 : 70);
}

type();

// ===========================
// REVEAL ON SCROLL
// ===========================
const revealEls = document.querySelectorAll('.reveal');

const observer = new IntersectionObserver((entries) => {
  entries.forEach((entry) => {
    if (entry.isIntersecting) {
      entry.target.classList.add('visible');
    }
  });
}, { threshold: 0.12 });

revealEls.forEach((el) => observer.observe(el));

// ===========================
// INSTALL TABS
// ===========================
const tabBtns = document.querySelectorAll('.tab-btn');
const tabPanels = document.querySelectorAll('.tab-panel');

tabBtns.forEach((btn) => {
  btn.addEventListener('click', () => {
    const target = btn.dataset.tab;
    tabBtns.forEach((b) => b.classList.remove('active'));
    tabPanels.forEach((p) => p.classList.remove('active'));
    btn.classList.add('active');
    const panel = document.getElementById('tab-' + target);
    if (panel) panel.classList.add('active');
  });
});

// ===========================
// COPY TO CLIPBOARD
// ===========================
document.querySelectorAll('.copy-btn').forEach((btn) => {
  btn.addEventListener('click', () => {
    const code = btn.closest('.code-block').querySelector('code');
    if (!code) return;

    // Strip HTML tags to get plain text
    const text = code.innerText || code.textContent;
    navigator.clipboard.writeText(text).then(() => {
      const span = btn.querySelector('span');
      const original = span.textContent;
      span.textContent = 'Copied!';
      btn.classList.add('copied');
      setTimeout(() => {
        span.textContent = original;
        btn.classList.remove('copied');
      }, 2000);
    });
  });
});
```

**Expected:** All interactive features work — typewriter cycles phrases, scroll progress bar moves, sections animate in, tabs switch, copy button flashes "Copied!".

---

## Step 5 — Enable GitHub Pages via API

```bash
gh api repos/learnzdevelopmenthub/paadhai/pages \
  --method POST \
  --field source='{"branch":"gh-pages","path":"/"}' \
  2>/dev/null || echo "Pages may already be enabled or requires manual setup"
```

If the API call fails (requires admin token scope), go to:
`https://github.com/learnzdevelopmenthub/paadhai/settings/pages`
→ Source: **Deploy from a branch** → Branch: `gh-pages` → Folder: `/ (root)` → Save.

**Expected:** GitHub Pages configured to serve from `gh-pages` branch root.

---

## Step 6 — Commit and push all files to `gh-pages`

```bash
# Switch to gh-pages branch
git checkout gh-pages

# Create assets directories
mkdir -p assets/css assets/js assets/img

# Copy files from feature branch (they were created there)
# Since files are created on gh-pages directly, just add and commit:
git add index.html assets/css/style.css assets/js/main.js
git commit -m "feat(homepage): add world-class animated landing page

- Dark theme with amber/gold accent (#0d1117 + #f0a500)
- Typewriter hero with animated grid background and glow
- 4-pipeline interactive flow section
- 21 skills responsive card grid with hover effects
- Tabbed installation guide (Claude Code, Cursor, Codex, Gemini)
- Quick start syntax-highlighted code block with copy button
- Scroll progress bar and IntersectionObserver reveal animations
- Fully responsive (mobile 375px+)

Refs #2"

git push origin gh-pages

# Return to feature branch
git checkout feature/2-plugin-homepage-github-pages
```

**Expected:** Files pushed to `gh-pages`. GitHub Pages deploys within ~60 seconds. Site live at `https://learnzdevelopmenthub.github.io/paadhai`.

---

## Deviations

_None yet._
```

**Expected:** Implementation doc written with all steps, exact file contents, and expected outputs.

---

## Deviations

_None. All steps executed as planned._
