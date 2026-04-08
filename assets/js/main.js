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
