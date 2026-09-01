import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/home/presentation/home_page.dart';
import '../../features/lots/presentation/lots_list_page.dart';
import '../../features/proposals/presentation/proposals_page.dart';
import '../../features/audit/presentation/audit_page.dart';
import '../../features/vitrine/presentation/vitrine_page.dart';
import '../../features/reservations/presentation/reservations_page.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../routing/app_routes.dart';
import '../theme/app_colors.dart';

// --- Definição dos itens de navegação ---

class _NavItem {
  final IconData icon;
  final String label;
  final String? badge; // ex.: 'SLA 7 dias'
  const _NavItem({required this.icon, required this.label, this.badge});
}

const _navItems = [
  _NavItem(icon: Icons.map_outlined, label: 'Mapa Interativo'),
  _NavItem(icon: Icons.format_list_bulleted_outlined, label: 'Lista de Lotes'),
  _NavItem(icon: Icons.view_kanban_outlined, label: 'Propostas', badge: 'SLA 7 dias'),
  _NavItem(icon: Icons.event_available_outlined, label: 'Reservas Pendentes'),
  _NavItem(icon: Icons.history_outlined, label: 'Histórico/Auditoria'),
  _NavItem(icon: Icons.public_outlined, label: 'Vitrine Pública'),
];

// Títulos e subtítulos de cada seção para o header
const _pageTitles = [
  ('Mapa Interativo', 'Loteamento Morada do Sol · 15 quadras · 192 lotes'),
  ('Lista de Lotes', 'Loteamento Morada do Sol'),
  ('Propostas', 'SLA de 7 dias por proposta'),
  ('Reservas Pendentes', 'Aprovação de reservas de lotes'),
  ('Histórico / Auditoria', 'Registro completo de eventos'),
  ('Vitrine Pública', 'Página pública do loteamento'),
];

// --- App Shell ---

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _selectedIndex = 0;
  bool _sidebarOpen = false; // para mobile
  late final PageController _pageController;

  final List<Widget> _pages = const [
    HomePage(),
    LotsListPage(),
    ProposalsPage(),
    ReservationsPage(),
    AuditPage(),
    VitrinePage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final isLarge = MediaQuery.of(context).size.width >= 1024;
    final authState = ref.watch(authControllerProvider);
    final isAuthenticated = authState.value != null;
    final showSidebar = isAuthenticated && isLarge;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // --- Conteúdo principal com padding para sidebar ---
          AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: EdgeInsets.only(left: showSidebar ? 280 : 0),
            child: Column(
              children: [
                _AppHeader(
                  title: _pageTitles[_selectedIndex].$1,
                  subtitle: _pageTitles[_selectedIndex].$2,
                  isAuthenticated: isAuthenticated,
                  onMenuTap: (isAuthenticated && !isLarge) ? () => setState(() => _sidebarOpen = true) : null,
                  onLogout: () async {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                    }
                  },
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: _pages,
                  ),
                ),
              ],
            ),
          ),

          // --- Overlay mobile ---
          if (isAuthenticated && !isLarge && _sidebarOpen)
            GestureDetector(
              onTap: () => setState(() => _sidebarOpen = false),
              child: Container(color: Colors.black54),
            ),

          // --- Sidebar ---
          if (isAuthenticated)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: showSidebar ? 0 : (_sidebarOpen ? 0 : -280),
              top: 0,
              bottom: 0,
              width: 280,
              child: _Sidebar(
                selectedIndex: _selectedIndex,
                onSelect: (i) {
                  setState(() {
                    _selectedIndex = i;
                    _sidebarOpen = false;
                  });
                  _pageController.jumpToPage(i);
                },
                onClose: isLarge ? null : () => setState(() => _sidebarOpen = false),
              ),
            ),
        ],
      ),
    );
  }
}

// --- Sidebar ---

class _Sidebar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onSelect;
  final VoidCallback? onClose;

  const _Sidebar({
    required this.selectedIndex,
    required this.onSelect,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(right: BorderSide(color: AppColors.sidebarBorder, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo header
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            // Removed bottom border from logo container
            child: Row(
              children: [
                // Logo "U"
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.sidebarPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'U',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Urbizzi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1,
                  ),
                ),
                const Spacer(),
                if (onClose != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: AppColors.sidebarFg),
                    onPressed: onClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Fechar navegação',
                  ),
              ],
            ),
          ),

          // Nav items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rótulo de seção
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 8),
                    child: Text(
                      'GESTÃO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.4,
                        color: AppColors.sidebarFg.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  ...List.generate(_navItems.length, (i) {
                    return _SidebarItem(
                      item: _navItems[i],
                      selected: selectedIndex == i,
                      onTap: () => onSelect(i),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.sidebarBorder, width: 1)),
            ),
            child: Text(
              'Urbizzi · Gestão de Loteamentos\nversão 1.4.2',
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.sidebarFg.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: AppColors.sidebarAccent.withValues(alpha: 0.6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 18,
                  color: selected ? AppColors.primary : AppColors.sidebarFg.withValues(alpha: 0.75),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.badge != null ? item.label : item.label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? AppColors.primary : AppColors.sidebarFg.withValues(alpha: 0.75),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (item.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.sidebarAccent,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.sidebarBorder),
                    ),
                    child: Text(
                      item.badge!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.sidebarFg.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Header fixo do conteúdo ---

class _AppHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isAuthenticated;
  final VoidCallback? onMenuTap;
  final VoidCallback onLogout;

  const _AppHeader({
    required this.title,
    required this.subtitle,
    required this.isAuthenticated,
    this.onMenuTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(bottom: BorderSide(color: AppColors.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Menu hamburguer (mobile)
          if (onMenuTap != null) ...[
            InkWell(
              onTap: onMenuTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.menu_rounded, size: 18, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Título + subtítulo
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                if (MediaQuery.of(context).size.width >= 600)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          if (isAuthenticated) ...[
            // Notificações
            const _NotificationMenu(),
            const SizedBox(width: 8),
            // Avatar / usuário
            _UserMenu(onLogout: onLogout),
          ] else ...[
            TextButton.icon(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.login),
              icon: const Icon(Icons.login, size: 18),
              label: const Text('Área do Corretor/Admin', style: TextStyle(fontWeight: FontWeight.w600)),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final bool hasDot;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderIconBtn({
    required this.icon,
    this.hasDot = false,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondary),
              if (hasDot)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.vendido,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserMenu extends ConsumerWidget {
  final VoidCallback onLogout;
  const _UserMenu({required this.onLogout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authControllerProvider);
    final user = userState.value;

    final name = user?.name ?? 'Usuário Local';
    final role = user?.roleStr.toUpperCase() ?? 'ADMINISTRADOR';
    
    // Calcula as iniciais
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    String initials = 'U';
    if (parts.isNotEmpty) {
      initials = parts.first[0].toUpperCase();
      if (parts.length > 1) {
        initials += parts.last[0].toUpperCase();
      }
    }

    return PopupMenuButton<String>(
      tooltip: 'Menu do usuário',
      offset: const Offset(0, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'logout') onLogout();
      },
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.2),
                ),
                Text(
                  role,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.2),
                ),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: const [
              Icon(Icons.logout_rounded, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Text('Sair', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}
class _NotificationMenu extends StatefulWidget {
  const _NotificationMenu();

  @override
  State<_NotificationMenu> createState() => _NotificationMenuState();
}

class _NotificationMenuState extends State<_NotificationMenu> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'title': 'SLA Perto do Fim',
      'body': 'A proposta de Ricardo Bomfim expira em 2 dias.',
      'read': false,
      'time': 'Há 2 horas',
      'icon': Icons.warning_amber_rounded,
      'color': AppColors.vendido,
    },
    {
      'id': 2,
      'title': 'Nova Proposta',
      'body': 'Nova proposta recebida no Lote 13 da Quadra A.',
      'read': false,
      'time': 'Há 5 horas',
      'icon': Icons.description_outlined,
      'color': AppColors.primary,
    },
    {
      'id': 3,
      'title': 'Venda Concluída',
      'body': 'Lote 07 (Quadra C) foi assinado e finalizado.',
      'read': true,
      'time': 'Ontem',
      'icon': Icons.check_circle_outline,
      'color': AppColors.disponivel,
    },
  ];

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n['read'] = true;
      }
    });
  }

  void _markAsRead(int id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) _notifications[index]['read'] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n['read']).length;

    return PopupMenuButton<int>(
      tooltip: 'Notificações',
      offset: const Offset(0, 48),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      icon: _HeaderIconBtn(
        icon: Icons.notifications_none,
        hasDot: unreadCount > 0,
        tooltip: 'Notificações',
        onTap: () {}, // Let the popup menu handle the tap
      ), // Render the container visually
      itemBuilder: (context) {
        return [
          // Header
          PopupMenuItem<int>(
            enabled: false,
            child: Container(
              width: 320,
              padding: const EdgeInsets.only(bottom: 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Notificações', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  if (unreadCount > 0)
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _markAllAsRead();
                      },
                      child: const Text('Ler todas', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ),
          ),
          // Itens
          ..._notifications.map((n) {
            final bool isRead = n['read'];
            return PopupMenuItem<int>(
              value: n['id'],
              padding: EdgeInsets.zero,
              onTap: () => _markAsRead(n['id']),
              child: Container(
                width: 320,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: isRead ? Colors.transparent : AppColors.primary.withValues(alpha: 0.05),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: n['color'].withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(n['icon'], size: 16, color: n['color']),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n['title'], style: TextStyle(fontSize: 13, fontWeight: isRead ? FontWeight.w500 : FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          Text(n['body'], style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 6),
                          Text(n['time'], style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    if (!isRead)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      ),
                  ],
                ),
              ),
            );
          }),
          // Footer
          if (_notifications.isEmpty)
            const PopupMenuItem<int>(
              enabled: false,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('Nenhuma notificação', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
              ),
            ),
        ];
      },
    );
  }
}
