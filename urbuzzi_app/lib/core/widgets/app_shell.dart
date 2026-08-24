import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/home/presentation/home_page.dart';
import '../../features/lots/presentation/lots_list_page.dart';
import '../../features/proposals/presentation/proposals_page.dart';
import '../../features/audit/presentation/audit_page.dart';
import '../../features/vitrine/presentation/vitrine_page.dart';
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
  _NavItem(icon: Icons.view_list_rounded, label: 'Lista de Lotes'),
  _NavItem(icon: Icons.space_dashboard_outlined, label: 'Propostas', badge: 'SLA 7 dias'),
  _NavItem(icon: Icons.history_rounded, label: 'Histórico/Auditoria'),
  _NavItem(icon: Icons.language_rounded, label: 'Vitrine Pública'),
];

// Títulos e subtítulos de cada seção para o header
const _pageTitles = [
  ('Mapa Interativo', 'Loteamento Morada do Sol · 15 quadras'),
  ('Lista de Lotes', 'Loteamento Morada do Sol'),
  ('Propostas', 'SLA de 7 dias por proposta'),
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

  final List<Widget> _pages = const [
    HomePage(),
    LotsListPage(),
    ProposalsPage(),
    AuditPage(),
    VitrinePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isLarge = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // --- Conteúdo principal com padding para sidebar ---
          AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: EdgeInsets.only(left: isLarge ? 280 : 0),
            child: Column(
              children: [
                _AppHeader(
                  title: _pageTitles[_selectedIndex].$1,
                  subtitle: _pageTitles[_selectedIndex].$2,
                  onMenuTap: isLarge ? null : () => setState(() => _sidebarOpen = true),
                  onLogout: () async {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                    }
                  },
                ),
                Expanded(
                  child: _pages[_selectedIndex],
                ),
              ],
            ),
          ),

          // --- Overlay mobile ---
          if (!isLarge && _sidebarOpen)
            GestureDetector(
              onTap: () => setState(() => _sidebarOpen = false),
              child: Container(color: Colors.black54),
            ),

          // --- Sidebar ---
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            left: isLarge ? 0 : (_sidebarOpen ? 0 : -280),
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
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.sidebarBorder, width: 1)),
            ),
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
        color: selected ? AppColors.sidebarAccent : Colors.transparent,
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
                  color: selected ? AppColors.sidebarPrimary : AppColors.sidebarFg.withValues(alpha: 0.75),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.badge != null ? item.label : item.label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? Colors.white : AppColors.sidebarFg.withValues(alpha: 0.75),
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
  final VoidCallback? onMenuTap;
  final VoidCallback onLogout;

  const _AppHeader({
    required this.title,
    required this.subtitle,
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

          // Notificações
          _HeaderIconBtn(
            icon: Icons.notifications_none_rounded,
            hasDot: true,
            tooltip: 'Notificações',
            onTap: () {},
          ),
          const SizedBox(width: 8),

          // Avatar / usuário
          _UserMenu(onLogout: onLogout),
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
                      color: Color(0xFFDC2626),
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

class _UserMenu extends StatelessWidget {
  final VoidCallback onLogout;
  const _UserMenu({required this.onLogout});

  @override
  Widget build(BuildContext context) {
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
              child: const Text(
                'U',
                style: TextStyle(
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
              children: const [
                Text(
                  'Usuário',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.2),
                ),
                Text(
                  'Administrador',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.2),
                ),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textSecondary),
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
