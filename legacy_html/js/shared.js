/* =============================================
   URBIZZI - Shared Data & Components
   ============================================= */

// --- Lot Data Store ---
const LOTS_DATA = [
  { id: 1,  number: '01', quadra: 'A', loteamento: 'Biopark',             area: 280,   price: 148000,  status: 'Disponível',    responsible: null,              client: null },
  { id: 2,  number: '02', quadra: 'A', loteamento: 'Biopark',             area: 300,   price: 155000,  status: 'Disponível',    responsible: null,              client: null },
  { id: 3,  number: '03', quadra: 'E', loteamento: 'Araucárias',          area: 520,   price: 268000,  status: 'Cancelado',     responsible: 'João Vitor Salles', client: 'Sandra Bertoldi' },
  { id: 4,  number: '04', quadra: 'B', loteamento: 'Biopark',             area: 360,   price: 189900,  status: 'Em aprovação',  responsible: 'Carla Menezes',   client: 'Fernanda Kliemann' },
  { id: 5,  number: '05', quadra: 'B', loteamento: 'Biopark',             area: 360,   price: 192000,  status: 'Reservado',     responsible: 'João Vitor Salles', client: 'Ricardo Bomfim' },
  { id: 6,  number: '06', quadra: 'C', loteamento: 'Biopark',             area: 310,   price: 160000,  status: 'Disponível',    responsible: null,              client: null },
  { id: 7,  number: '07', quadra: 'C', loteamento: 'Vista Verde',         area: 275,   price: 118000,  status: 'Vendido',       responsible: 'Carla Menezes',   client: 'Otávio Lins' },
  { id: 8,  number: '08', quadra: 'C', loteamento: 'Vista Verde',         area: 250,   price: 121000,  status: 'Disponível',    responsible: null,              client: null },
  { id: 9,  number: '09', quadra: 'D', loteamento: 'Vista Verde',         area: 290,   price: 135000,  status: 'Disponível',    responsible: null,              client: null },
  { id: 10, number: '10', quadra: 'D', loteamento: 'Araucárias',          area: 330,   price: 198500,  status: 'Disponível',    responsible: null,              client: null },
  { id: 11, number: '11', quadra: 'F', loteamento: 'Araucárias',          area: 400,   price: 201000,  status: 'Vendido',       responsible: 'Diego Prado',     client: 'Helena e Paulo Ramos' },
  { id: 12, number: '12', quadra: 'A', loteamento: 'Biopark',             area: 300,   price: 150000,  status: 'Disponível',    responsible: null,              client: null },
  { id: 13, number: '13', quadra: 'A', loteamento: 'Biopark',             area: 312.5, price: 162500,  status: 'Reservado',     responsible: 'Carla Menezes',   client: 'Marina Duarte' },
  { id: 14, number: '14', quadra: 'B', loteamento: 'Biopark',             area: 340,   price: 175000,  status: 'Vendido',       responsible: null,              client: null },
  { id: 15, number: '15', quadra: 'D', loteamento: 'Vista Verde',         area: 380,   price: 210000,  status: 'Disponível',    responsible: null,              client: null },
  { id: 16, number: '16', quadra: 'E', loteamento: 'Araucárias',          area: 450,   price: 245000,  status: 'Bloqueado',     responsible: null,              client: null },
  { id: 17, number: '22', quadra: 'D', loteamento: 'Vista Verde',         area: 400,   price: 226000,  status: 'Em aprovação',  responsible: 'Diego Prado',     client: 'Construtora Alvorada Ltda.' },
  { id: 18, number: '02', quadra: 'A', loteamento: 'Araucárias',          area: 480,   price: 289000,  status: 'Disponível',    responsible: null,              client: null },
];

// --- Proposals Data Store ---
const PROPOSALS_DATA = [
  { id: 1, client: 'Marina Duarte',               lotNumber: '13', quadra: 'A', loteamento: 'Biopark',    price: 162500, status: 'reserva_ativa', responsible: 'Carla Menezes' },
  { id: 2, client: 'Ricardo Bomfim',               lotNumber: '05', quadra: 'B', loteamento: 'Biopark',    price: 192000, status: 'reserva_ativa', responsible: 'João Vitor Salles' },
  { id: 3, client: 'Fernanda Kliemann',            lotNumber: '04', quadra: 'B', loteamento: 'Biopark',    price: 189900, status: 'em_analise',    responsible: 'Carla Menezes' },
  { id: 4, client: 'Construtora Alvorada Ltda.',   lotNumber: '22', quadra: 'D', loteamento: 'Vista Verde', price: 226000, status: 'em_analise',    responsible: 'Diego Prado' },
  { id: 5, client: 'Helena e Paulo Ramos',         lotNumber: '11', quadra: 'F', loteamento: 'Araucárias', price: 201000, status: 'aprovada',      responsible: 'Diego Prado' },
  { id: 6, client: 'Otávio Lins',                  lotNumber: '07', quadra: 'C', loteamento: 'Vista Verde', price: 118000, status: 'aprovada',      responsible: 'Carla Menezes' },
  { id: 7, client: 'Sandra Bertoldi',              lotNumber: '03', quadra: 'E', loteamento: 'Araucárias', price: 268000, status: 'rejeitada',     responsible: 'João Vitor Salles' },
];

// --- Audit Log Data ---
const AUDIT_DATA = [
  { id: 1, date: '12/08/2026', time: '14:32', person: 'Carla Menezes',      role: 'Comercial',      action: 'Criou reserva',                  lot: 'Biopark · Lote 13 / Quadra A',          from: 'Disponível',     to: 'Reservado' },
  { id: 2, date: '12/08/2026', time: '11:07', person: 'Diego Prado',        role: 'Gestor',         action: 'Enviou proposta para análise',    lot: 'Vista Verde · Lote 22 / Quadra D',       from: 'Reservado',      to: 'Em aprovação' },
  { id: 3, date: '11/08/2026', time: '17:45', person: 'Ana Ferrarezi',      role: 'Administrador',  action: 'Bloqueou lote',                  lot: 'Vista Verde · Lote 21 / Quadra D',       from: 'Disponível',     to: 'Bloqueado' },
  { id: 4, date: '10/08/2026', time: '09:14', person: 'João Vitor Salles',  role: 'Comercial',      action: 'Cancelou negociação',             lot: 'Araucárias · Lote 03 / Quadra E',        from: 'Em aprovação',   to: 'Cancelado' },
  { id: 5, date: '08/08/2026', time: '16:02', person: 'Ana Ferrarezi',      role: 'Administrador',  action: 'Registrou venda',                lot: 'Araucárias · Lote 11 / Quadra F',        from: 'Em aprovação',   to: 'Vendido' },
  { id: 6, date: '05/08/2026', time: '10:22', person: 'Diego Prado',        role: 'Gestor',         action: 'Atualizou valor de tabela',      lot: 'Biopark · Lote 12 / Quadra A',           from: 'R$ 145.000,00',  to: 'R$ 150.000,00' },
];

// --- Helper Functions ---
function formatCurrency(value) {
  return value.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
}

function getStatusKey(status) {
  const map = {
    'Disponível':    'disponivel',
    'Reservado':     'reservado',
    'Em aprovação':  'em-aprovacao',
    'Bloqueado':     'bloqueado',
    'Vendido':       'vendido',
    'Cancelado':     'cancelado',
  };
  return map[status] || 'disponivel';
}

function getStatusColor(status) {
  const map = {
    'Disponível':    '#22c55e',
    'Reservado':     '#f59e0b',
    'Em aprovação':  '#3b82f6',
    'Bloqueado':     '#6b7280',
    'Vendido':       '#ef4444',
    'Cancelado':     '#9ca3af',
  };
  return map[status] || '#6b7280';
}

function getStatusFill(status) {
  const map = {
    'Disponível':    '#22c55e',
    'Reservado':     '#f59e0b',
    'Em aprovação':  '#3b82f6',
    'Bloqueado':     '#6b7280',
    'Vendido':       '#ef4444',
    'Cancelado':     '#d1d5db',
  };
  return map[status] || '#6b7280';
}

function getStatusBadgeHTML(status) {
  const key = getStatusKey(status);
  return `<span class="badge badge-${key}"><span class="badge-dot"></span>${status}</span>`;
}

function getInitials(name) {
  if (!name) return '??';
  const parts = name.split(' ');
  if (parts.length >= 2) {
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }
  return parts[0].substring(0, 2).toUpperCase();
}

function getStatusCounts() {
  const counts = {};
  LOTS_DATA.forEach(lot => {
    counts[lot.status] = (counts[lot.status] || 0) + 1;
  });
  return counts;
}

// --- Sidebar Renderer ---
function renderSidebar(activePage) {
  const sidebarHTML = `
    <div class="sidebar-overlay" id="sidebarOverlay"></div>
    <button class="hamburger" id="hamburgerBtn" aria-label="Menu">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <line x1="3" y1="6" x2="21" y2="6"></line>
        <line x1="3" y1="12" x2="21" y2="12"></line>
        <line x1="3" y1="18" x2="21" y2="18"></line>
      </svg>
    </button>
    <aside class="sidebar" id="sidebar">
      <div class="sidebar-logo">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path>
          <circle cx="12" cy="10" r="3"></circle>
        </svg>
        Urbuzzi
      </div>
      <div class="sidebar-section-label">Gestão</div>
      <ul class="sidebar-nav">
        <li>
          <a href="index.html" class="${activePage === 'mapa' ? 'active' : ''}">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="1 6 1 22 8 18 16 22 23 18 23 2 16 6 8 2 1 6"></polygon><line x1="8" y1="2" x2="8" y2="18"></line><line x1="16" y1="6" x2="16" y2="22"></line></svg>
            Mapa Interativo
          </a>
        </li>
        <li>
          <a href="lotes.html" class="${activePage === 'lotes' ? 'active' : ''}">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="8" y1="6" x2="21" y2="6"></line><line x1="8" y1="12" x2="21" y2="12"></line><line x1="8" y1="18" x2="21" y2="18"></line><line x1="3" y1="6" x2="3.01" y2="6"></line><line x1="3" y1="12" x2="3.01" y2="12"></line><line x1="3" y1="18" x2="3.01" y2="18"></line></svg>
            Lista de Lotes
          </a>
        </li>
        <li>
          <a href="propostas.html" class="${activePage === 'propostas' ? 'active' : ''}">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
            Propostas (SLA 7 dias)
          </a>
        </li>
        <li>
          <a href="auditoria.html" class="${activePage === 'auditoria' ? 'active' : ''}">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
            Histórico/Auditoria
          </a>
        </li>
        <li>
          <a href="vitrine.html" class="${activePage === 'vitrine' ? 'active' : ''}">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path><polyline points="9 22 9 12 15 12 15 22"></polyline></svg>
            Vitrine Pública
          </a>
        </li>
      </ul>
      <div class="sidebar-user">
        <div class="sidebar-user-avatar">AF</div>
        <div class="sidebar-user-info">
          <div class="sidebar-user-name">Ana Ferrarezi</div>
          <div class="sidebar-user-role">Administrador</div>
        </div>
      </div>
    </aside>
  `;

  document.body.insertAdjacentHTML('afterbegin', sidebarHTML);
  initMobileMenu();
}

// --- Mobile Menu ---
function initMobileMenu() {
  const hamburger = document.getElementById('hamburgerBtn');
  const sidebar = document.getElementById('sidebar');
  const overlay = document.getElementById('sidebarOverlay');

  if (!hamburger || !sidebar || !overlay) return;

  hamburger.addEventListener('click', () => {
    sidebar.classList.toggle('open');
    overlay.classList.toggle('active');
  });

  overlay.addEventListener('click', () => {
    sidebar.classList.remove('open');
    overlay.classList.remove('active');
  });
}

// Expose data globally
window.LOTS_DATA = LOTS_DATA;
window.PROPOSALS_DATA = PROPOSALS_DATA;
window.AUDIT_DATA = AUDIT_DATA;
window.formatCurrency = formatCurrency;
window.getStatusKey = getStatusKey;
window.getStatusColor = getStatusColor;
window.getStatusFill = getStatusFill;
window.getStatusBadgeHTML = getStatusBadgeHTML;
window.getInitials = getInitials;
window.getStatusCounts = getStatusCounts;
window.renderSidebar = renderSidebar;
