/* =============================================
   URBIZZI - Histórico/Auditoria (auditoria.js)
   ============================================= */

document.addEventListener('DOMContentLoaded', () => {
  renderSidebar('auditoria');
  renderTimeline();
});

function renderTimeline() {
  const container = document.getElementById('timeline');

  container.innerHTML = AUDIT_DATA.map((entry, i) => {
    // Determine badge classes for from/to
    const fromBadge = getBadgeForValue(entry.from);
    const toBadge = getBadgeForValue(entry.to);

    return `
      <div class="timeline-entry animate-in" style="animation-delay: ${i * 0.08}s">
        <div class="timeline-number">${i + 1}</div>
        <div class="timeline-card">
          <div class="timeline-date">${entry.date} ${entry.time}</div>
          <div class="timeline-person">${entry.person} · ${entry.role}</div>
          <div class="timeline-action">${entry.action}</div>
          <div class="timeline-lot">${entry.lot}</div>
          <div class="timeline-transition">
            ${fromBadge}
            <span class="timeline-arrow">→</span>
            ${toBadge}
          </div>
        </div>
      </div>
    `;
  }).join('');
}

function getBadgeForValue(value) {
  // Check if it's a known status
  const statuses = ['Disponível', 'Reservado', 'Em aprovação', 'Bloqueado', 'Vendido', 'Cancelado'];

  if (statuses.includes(value)) {
    return getStatusBadgeHTML(value);
  }

  // Otherwise it's a price or other value — render as neutral badge
  return `<span class="badge" style="background: #f1f5f9; color: #475569;">${value}</span>`;
}
