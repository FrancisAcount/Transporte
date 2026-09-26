import 'package:flutter/material.dart';

import '../models/menu_item.dart';
import '../theme/app_colors.dart';
import '../views/alerts_view.dart';
import '../views/dashboard_view.dart';
import '../views/drivers_view.dart';
import '../views/fleet_view.dart';
import '../views/routes_view.dart';
import '../views/settings_view.dart';
import '../views/students_view.dart';
import '../widgets/app_sidebar.dart';

/// Pantalla principal: sidebar + cabecera + contenido del módulo activo.
/// Es el único punto que controla qué apartado se muestra.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Módulo activo (0..6)
  bool _sidebarCollapsed = false; // Modo compacto en pantallas pequeñas
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Mapa índice → widget de cada apartado. Mantiene el diseño desacoplado.
  static const List<Widget> _views = [
    DashboardView(),
    RoutesView(),
    FleetView(),
    DriversView(),
    StudentsView(),
    AlertsView(),
    SettingsView(),
  ];

  void _selectModule(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    // Cierra el drawer lateral en móvil al navegar.
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = AppMenu.byIndex(_selectedIndex);
    final isMobile = MediaQuery.sizeOf(context).width < 900;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      // Drawer para móvil (web y escritorio usan el sidebar fijo).
      drawer: isMobile
          ? Drawer(
              child: SafeArea(
                child: AppSidebar(
                  selectedIndex: _selectedIndex,
                  onSelected: _selectModule,
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar fijo en escritorio / web
            if (!isMobile)
              AppSidebar(
                selectedIndex: _selectedIndex,
                onSelected: _selectModule,
                collapsed: _sidebarCollapsed,
              ),
            Expanded(child: _buildContent(item)),
          ],
        ),
      ),
    );
  }
  /// Columna central: cabecera blanca + contenido del módulo.
  Widget _buildContent(MenuItem item) {
    return Column(
      children: [
        _buildHeader(item),
        const Divider(height: 1),
        // AnimatedSwitcher da la transición instantánea y fluida entre apartados.
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, 0.02), end: Offset.zero).animate(animation),
                child: child,
              ),
            ),
            child: KeyedSubtree(
              key: ValueKey(_selectedIndex),
              child: _views[_selectedIndex],
            ),
          ),
        ),
      ],
    );
  }

  /// Cabecera: botón de menú (móvil), título del módulo y acciones.
  Widget _buildHeader(MenuItem item) {
    final isMobile = MediaQuery.sizeOf(context).width < 900;
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              color: AppColors.sidebarBg,
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            )
          else
            IconButton(
              tooltip: _sidebarCollapsed ? 'Expandir menú' : 'Contraer menú',
              icon: Icon(_sidebarCollapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded),
              color: AppColors.textSecondary,
              onPressed: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(item.subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          // Fecha actual
          if (!isMobile)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
              child: const Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 15, color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Text('Lunes, 28 de septiembre', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          const SizedBox(width: 12),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                color: AppColors.textSecondary,
                onPressed: () => ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Notificaciones simuladas'))),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  height: 9,
                  width: 9,
                  decoration: const BoxDecoration(color: AppColors.guindo, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
