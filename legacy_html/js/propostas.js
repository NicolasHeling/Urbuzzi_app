/* =============================================
   URBIZZI - Propostas Kanban (propostas.js)
   ============================================= */

document.addEventListener('DOMContentLoaded', () => {
  renderSidebar('propostas');
  renderKanban();
});

function renderKanban() {
  const board = document.getElementById('kanbanBoard');

  const columns = [
    { key: 'reserva_ativa', title: 'Reserva Ativa',                  color: '#f59e0b' },
    { key: 'em_analise',    title: 'Em Análise Interna (SLA 7 Dias)', color: '#3b82f6' },
    { key: 'aprovada',      title: 'Aprovada',                       color: '#22c55e' },
    { key: 'rejeitada',     title: 'Rejeitada',                      color: '#ef4444' },
  ];

  board.innerHTML = columns.map(col => {
    const cards = PROPOSALS_DATA.filter(p => p.status === col.key);

    return `
      <div class="kanban-column">
        <div class="kanban-header">
          <div class="kanban-header-left">
            <div class="kanban-accent" style="background: ${col.color}"></div>
            <span class="kanban-title">${col.title}</span>
          </div>
          <span class="kanban-count">${cards.length}</span>
        </div>
        <div class="kanban-cards">
          ${cards.map(card => `
            <div class="kanban-card" onclick="alert('Detalhes da proposta de ${card.client}')">
              <div class="kanban-card-client">${card.client}</div>
              <div class="kanban-card-lot">Lote ${card.lotNumber} · Quadra ${card.quadra} · ${card.loteamento}</div>
              <div class="kanban-card-price">${formatCurrency(card.price)}</div>
              <div class="kanban-card-responsible">
                <div class="avatar-initials">${getInitials(card.responsible)}</div>
                <span class="kanban-card-responsible-name">${card.responsible}</span>
              </div>
            </div>
          `).join('')}
        </div>
      </div>
    `;
  }).join('');
}
