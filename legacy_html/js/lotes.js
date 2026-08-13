/* =============================================
   URBIZZI - Lista de Lotes (lotes.js)
   ============================================= */

document.addEventListener('DOMContentLoaded', () => {
  renderSidebar('lotes');
  renderFilterPills();
  renderTable(LOTS_DATA);

  document.getElementById('searchInput').addEventListener('input', applyFilters);
});

let activeFilter = 'Todos';

function renderFilterPills() {
  const container = document.getElementById('filterPills');
  const counts = getStatusCounts();
  const filters = ['Todos', 'Disponível', 'Reservado', 'Em aprovação', 'Bloqueado', 'Vendido', 'Cancelado'];

  container.innerHTML = filters.map(f => {
    const count = f === 'Todos' ? LOTS_DATA.length : (counts[f] || 0);
    return `
      <button class="filter-pill ${f === activeFilter ? 'active' : ''}" data-filter="${f}" onclick="setFilter('${f}')">
        ${f}
        <span class="pill-count">${count}</span>
      </button>
    `;
  }).join('');
}

function setFilter(filter) {
  activeFilter = filter;
  renderFilterPills();
  applyFilters();
}

function applyFilters() {
  const search = document.getElementById('searchInput').value.toLowerCase().trim();
  let filtered = LOTS_DATA;

  if (activeFilter !== 'Todos') {
    filtered = filtered.filter(lot => lot.status === activeFilter);
  }

  if (search) {
    filtered = filtered.filter(lot =>
      lot.number.toLowerCase().includes(search) ||
      lot.quadra.toLowerCase().includes(search) ||
      lot.loteamento.toLowerCase().includes(search) ||
      (lot.responsible && lot.responsible.toLowerCase().includes(search)) ||
      (lot.client && lot.client.toLowerCase().includes(search))
    );
  }

  renderTable(filtered);
}

function renderTable(lots) {
  const tbody = document.getElementById('lotTableBody');
  const empty = document.getElementById('tableEmpty');
  const displayCount = document.getElementById('lotDisplayCount');

  displayCount.textContent = lots.length;

  if (lots.length === 0) {
    tbody.innerHTML = '';
    empty.style.display = 'block';
    return;
  }

  empty.style.display = 'none';

  tbody.innerHTML = lots.map(lot => {
    let actionBtn = '';
    if (lot.status === 'Disponível') {
      actionBtn = `<button class="btn btn-primary btn-sm" onclick="alert('Reservar Lote ${lot.number}')">Reservar</button>`;
    } else if (lot.status === 'Reservado') {
      actionBtn = `<button class="btn btn-outline btn-sm" onclick="alert('Ver proposta Lote ${lot.number}')">Ver proposta</button>`;
    } else {
      actionBtn = `<button class="btn btn-outline btn-sm" onclick="alert('Detalhes Lote ${lot.number}')">Detalhes</button>`;
    }

    return `
      <tr>
        <td><strong>Lote ${lot.number}</strong></td>
        <td>${lot.quadra}</td>
        <td>${lot.loteamento}</td>
        <td>${lot.area} m²</td>
        <td>${formatCurrency(lot.price)}</td>
        <td>${getStatusBadgeHTML(lot.status)}</td>
        <td>${lot.responsible || '—'}</td>
        <td>${actionBtn}</td>
      </tr>
    `;
  }).join('');
}

// Expose to global scope for onclick
window.setFilter = setFilter;
