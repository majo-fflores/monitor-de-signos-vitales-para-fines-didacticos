import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/layout/main_layout.dart';
import '../../features/dashboard/views/dashboard_view.dart';
import '../../features/alerts/views/alerts_view.dart';
import '../../features/history/views/history_view.dart';
import '../../features/settings/views/settings_view.dart';

/// Configuración de ruteo de la aplicación utilizando GoRouter.
/// Mapea la estructura anidada de React Router usando ShellRoute.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) => const DashboardView(),
        ),
        GoRoute(
          path: '/historial',
          builder: (BuildContext context, GoRouterState state) => const HistoryView(),
        ),
        GoRoute(
          path: '/alertas',
          builder: (BuildContext context, GoRouterState state) => const AlertsView(),
        ),
        GoRoute(
          path: '/configuracion',
          builder: (BuildContext context, GoRouterState state) => const SettingsView(),
        ),
      ],
    ),
  ],
);
