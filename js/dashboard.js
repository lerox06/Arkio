/**
 * dashboard.js — Gestion Foncière Premium
 * Interactions UI : filtres, recherche, sidebar responsive
 */

document.addEventListener('DOMContentLoaded', () => {

  /* ── Sidebar mobile ─────────────────────────────────── */
  const burger  = document.getElementById('burger');
  const sidebar = document.getElementById('sidebar');
  const overlay = document.getElementById('sidebarOverlay');

  function toggleSidebar() {
    sidebar.classList.toggle('open');
    overlay.classList.toggle('show');
  }

  if (burger)  burger.addEventListener('click', toggleSidebar);
  if (overlay) overlay.addEventListener('click', toggleSidebar);

  /* ── Filtre onglets Promotion / MOA ─────────────────── */
  const tabBtns = document.querySelectorAll('[data-tab]');
  const tabPanes = document.querySelectorAll('[data-pane]');

  tabBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      const target = btn.dataset.tab;

      tabBtns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');

      tabPanes.forEach(pane => {
        pane.style.display = pane.dataset.pane === target ? '' : 'none';
      });
    });
  });

  /* ── Recherche dynamique dans le tableau ────────────── */
  const searchInput = document.getElementById('tableSearch');
  const tableRows   = document.querySelectorAll('#projetTable tbody tr');

  if (searchInput) {
    searchInput.addEventListener('input', () => {
      const q = searchInput.value.trim().toLowerCase();

      tableRows.forEach(row => {
        const text = row.textContent.toLowerCase();
        row.style.display = text.includes(q) ? '' : 'none';
      });

      updateRowCount();
    });
  }

  function updateRowCount() {
    const visible = [...tableRows].filter(r => r.style.display !== 'none').length;
    const counter = document.getElementById('rowCount');
    if (counter) counter.textContent = `${visible} projet(s) affiché(s)`;
  }

  /* ── Animation barres de progression piliers ────────── */
  function animateProgressBars() {
    document.querySelectorAll('.pillar-bar-fill').forEach(bar => {
      const target = bar.dataset.width || '0';
      bar.style.width = '0%';
      requestAnimationFrame(() => {
        setTimeout(() => { bar.style.width = target + '%'; }, 100);
      });
    });
  }

  animateProgressBars();

  /* ── Compteurs animés des stat-cards ────────────────── */
  function animateCounter(el) {
    const target = parseFloat(el.dataset.target || el.textContent.replace(/[^0-9.]/g, ''));
    const isFloat = String(target).includes('.');
    const duration = 1200;
    const start = performance.now();

    function step(now) {
      const elapsed  = now - start;
      const progress = Math.min(elapsed / duration, 1);
      const ease     = 1 - Math.pow(1 - progress, 3); // ease-out cubic
      const current  = target * ease;

      if (isFloat) {
        el.textContent = current.toLocaleString('fr-FR', { maximumFractionDigits: 1 });
      } else {
        el.textContent = Math.floor(current).toLocaleString('fr-FR');
      }

      if (progress < 1) requestAnimationFrame(step);
    }

    requestAnimationFrame(step);
  }

  document.querySelectorAll('.stat-value[data-target]').forEach(el => {
    // Observer pour lancer l'animation quand visible
    const observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          animateCounter(el);
          observer.unobserve(el);
        }
      });
    }, { threshold: 0.5 });
    observer.observe(el);
  });

  /* ── Tooltip budget ─────────────────────────────────── */
  document.querySelectorAll('[data-tooltip]').forEach(el => {
    el.style.position = 'relative';
    el.style.cursor   = 'help';

    el.addEventListener('mouseenter', (e) => {
      const tip = document.createElement('div');
      tip.className = 'custom-tooltip';
      tip.textContent = el.dataset.tooltip;
      Object.assign(tip.style, {
        position: 'fixed',
        background: '#1A1816',
        border: '1px solid rgba(201,168,76,0.3)',
        color: '#C9A84C',
        padding: '0.4rem 0.75rem',
        fontSize: '0.72rem',
        letterSpacing: '0.05em',
        whiteSpace: 'nowrap',
        zIndex: '9000',
        pointerEvents: 'none',
        top: (e.clientY - 36) + 'px',
        left: (e.clientX + 10) + 'px'
      });
      document.body.appendChild(tip);
      el._tooltip = tip;
    });

    el.addEventListener('mousemove', (e) => {
      if (el._tooltip) {
        el._tooltip.style.top  = (e.clientY - 36) + 'px';
        el._tooltip.style.left = (e.clientX + 10) + 'px';
      }
    });

    el.addEventListener('mouseleave', () => {
      if (el._tooltip) {
        el._tooltip.remove();
        el._tooltip = null;
      }
    });
  });

  /* ── Active nav link ────────────────────────────────── */
  const currentHash = window.location.hash || '#dashboard';
  document.querySelectorAll('.nav-link').forEach(link => {
    if (link.getAttribute('href') === currentHash) {
      link.classList.add('active');
    }
    link.addEventListener('click', function () {
      document.querySelectorAll('.nav-link').forEach(l => l.classList.remove('active'));
      this.classList.add('active');
    });
  });

});
