/* =============================================
   URBIZZI - Mapa Interativo (map.js)
   ============================================= */

document.addEventListener('DOMContentLoaded', () => {
  renderSidebar('mapa');
  renderStatsBar();
  renderMap();
  selectLot(LOTS_DATA[0]); // Select Lote 01 by default
});

function renderStatsBar() {
  const container = document.getElementById('statsBar');
  const counts = getStatusCounts();
  const statuses = ['Disponível', 'Reservado', 'Em aprovação', 'Bloqueado', 'Vendido', 'Cancelado'];

  container.innerHTML = statuses.map(status => `
    <div class="stat-item">
      <span class="stat-dot" style="background: ${getStatusColor(status)}"></span>
      <span>${status}</span>
      <span class="stat-count">${counts[status] || 0}</span>
    </div>
  `).join('');
}

function renderMap() {
  const svg = document.getElementById('mapSvg');
  const lots = LOTS_DATA;

  // Layout: 3 rows of lots arranged in a grid
  const cols = 6;
  const lotWidth = 110;
  const lotHeight = 80;
  const gapX = 16;
  const gapY = 16;
  const offsetX = 30;
  const offsetY = 50;

  // Title
  const title = document.createElementNS('http://www.w3.org/2000/svg', 'text');
  title.setAttribute('x', '400');
  title.setAttribute('y', '25');
  title.setAttribute('text-anchor', 'middle');
  title.setAttribute('font-size', '14');
  title.setAttribute('font-weight', '600');
  title.setAttribute('fill', '#64748b');
  title.setAttribute('font-family', 'Inter, sans-serif');
  title.textContent = 'Gleba 1 — Biopark / Vista Verde / Araucárias';
  svg.appendChild(title);

  // Draw quadra labels
  const quadras = ['A', 'B', 'C', 'D', 'E', 'F'];
  const quadraPositions = {};

  lots.forEach((lot, i) => {
    const col = i % cols;
    const row = Math.floor(i / cols);
    const x = offsetX + col * (lotWidth + gapX);
    const y = offsetY + row * (lotHeight + gapY);

    // Store position for reference
    lot._x = x;
    lot._y = y;

    // Create lot group
    const g = document.createElementNS('http://www.w3.org/2000/svg', 'g');
    g.setAttribute('data-lot-id', lot.id);
    g.style.cursor = 'pointer';

    // Rectangle
    const rect = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
    rect.setAttribute('x', x);
    rect.setAttribute('y', y);
    rect.setAttribute('width', lotWidth);
    rect.setAttribute('height', lotHeight);
    rect.setAttribute('rx', '8');
    rect.setAttribute('ry', '8');
    rect.setAttribute('fill', getStatusFill(lot.status));
    rect.setAttribute('class', 'lot-polygon');
    rect.setAttribute('id', `lot-rect-${lot.id}`);

    // Lot number label
    const label = document.createElementNS('http://www.w3.org/2000/svg', 'text');
    label.setAttribute('x', x + lotWidth / 2);
    label.setAttribute('y', y + lotHeight / 2 - 6);
    label.setAttribute('class', 'lot-label');
    label.setAttribute('font-family', 'Inter, sans-serif');
    label.textContent = `Lote ${lot.number}`;

    // Quadra label
    const qLabel = document.createElementNS('http://www.w3.org/2000/svg', 'text');
    qLabel.setAttribute('x', x + lotWidth / 2);
    qLabel.setAttribute('y', y + lotHeight / 2 + 10);
    qLabel.setAttribute('font-size', '9');
    qLabel.setAttribute('fill', 'rgba(255,255,255,0.8)');
    qLabel.setAttribute('text-anchor', 'middle');
    qLabel.setAttribute('pointer-events', 'none');
    qLabel.setAttribute('font-family', 'Inter, sans-serif');
    qLabel.textContent = `Qd. ${lot.quadra}`;

    g.appendChild(rect);
    g.appendChild(label);
    g.appendChild(qLabel);

    // Click handler
    g.addEventListener('click', () => selectLot(lot));

    // Hover effects
    g.addEventListener('mouseenter', () => {
      rect.style.filter = 'brightness(0.85)';
      rect.style.strokeWidth = '3';
      rect.style.stroke = '#0f172a';
    });
    g.addEventListener('mouseleave', () => {
      const isSelected = rect.classList.contains('selected');
      if (!isSelected) {
        rect.style.filter = '';
        rect.style.strokeWidth = '2';
        rect.style.stroke = '#fff';
      }
    });

    svg.appendChild(g);
  });

  // Update viewBox to fit
  const totalRows = Math.ceil(lots.length / cols);
  const svgWidth = offsetX * 2 + cols * (lotWidth + gapX) - gapX;
  const svgHeight = offsetY + totalRows * (lotHeight + gapY) + 20;
  svg.setAttribute('viewBox', `0 0 ${svgWidth} ${svgHeight}`);
}

let selectedLotId = null;

function selectLot(lot) {
  // Remove previous selection
  if (selectedLotId) {
    const prevRect = document.getElementById(`lot-rect-${selectedLotId}`);
    if (prevRect) {
      prevRect.classList.remove('selected');
      prevRect.style.filter = '';
      prevRect.style.strokeWidth = '2';
      prevRect.style.stroke = '#fff';
    }
  }

  // Mark new selection
  selectedLotId = lot.id;
  const rect = document.getElementById(`lot-rect-${lot.id}`);
  if (rect) {
    rect.classList.add('selected');
    rect.style.filter = 'brightness(0.85)';
    rect.style.strokeWidth = '3';
    rect.style.stroke = '#0f172a';
  }

  // Update detail panel
  const body = document.getElementById('detailBody');
  const actions = document.getElementById('detailActions');

  body.innerHTML = `
    <div class="detail-lot-number">Lote ${lot.number} · Quadra ${lot.quadra}</div>
    <div class="detail-loteamento">${lot.loteamento}</div>
    <div class="detail-price">${formatCurrency(lot.price)}</div>
    <div class="detail-row">
      <span class="detail-label">Status</span>
      <span class="detail-value">${getStatusBadgeHTML(lot.status)}</span>
    </div>
    <div class="detail-row">
      <span class="detail-label">Área</span>
      <span class="detail-value">${lot.area} m²</span>
    </div>
    ${lot.responsible ? `
    <div class="detail-row">
      <span class="detail-label">Responsável</span>
      <span class="detail-value">${lot.responsible}</span>
    </div>` : ''}
    ${lot.client ? `
    <div class="detail-row">
      <span class="detail-label">Cliente</span>
      <span class="detail-value">${lot.client}</span>
    </div>` : ''}
  `;

  // Action buttons based on status
  actions.style.display = 'flex';
  if (lot.status === 'Disponível') {
    actions.innerHTML = `
      <button class="btn btn-primary" onclick="alert('Reservar Lote ${lot.number}')">Reservar Lote</button>
      <button class="btn btn-outline" onclick="alert('Bloquear Lote ${lot.number}')">Bloquear</button>
    `;
  } else if (lot.status === 'Reservado') {
    actions.innerHTML = `
      <button class="btn btn-primary" onclick="alert('Enviar proposta do Lote ${lot.number}')">Enviar Proposta</button>
      <button class="btn btn-outline" onclick="alert('Cancelar reserva do Lote ${lot.number}')">Cancelar Reserva</button>
    `;
  } else if (lot.status === 'Em aprovação') {
    actions.innerHTML = `
      <button class="btn btn-success" onclick="alert('Aprovar Lote ${lot.number}')">Aprovar</button>
      <button class="btn btn-danger btn-sm" onclick="alert('Rejeitar Lote ${lot.number}')">Rejeitar</button>
    `;
  } else {
    actions.innerHTML = `
      <button class="btn btn-outline" onclick="alert('Detalhes do Lote ${lot.number}')">Ver Histórico</button>
    `;
  }
}
