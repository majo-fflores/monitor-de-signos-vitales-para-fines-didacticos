import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/alerts/views/alerts_view.dart';
import '../../features/dashboard/views/dashboard_view.dart';
import '../../features/history/views/history_view.dart';
import '../../features/history/views/pdf_preview_view.dart';
import '../../features/sessions/views/sessions_history_view.dart';
import '../../features/settings/views/settings_view.dart';
import '../../features/users/views/user_selection_view.dart';
import '../../shared/providers/usuario_provider.dart';
import '../../shared/utils/report_pdf_helper.dart';
import '../../shared/widgets/layout/main_layout.dart';

/// Listenable para indicarle a GoRouter que re-ejecute redirecciones
/// cuando cambie el estado de los usuarios (login/logout/cambio).
class RouterRefreshListenable extends ChangeNotifier {
  RouterRefreshListenable(Ref ref) {
    ref.listen(
      notificadorUsuariosProvider.select((s) => s.usuarioActivo),
      (_, __) => notifyListeners(),
    );
  }
}

/// Proveedor del router de la aplicación.
/// Permite inyectar dependencias y usar guards reactivos con Riverpod.
final routerProvider = Provider<GoRouter>((ref) {
  final listenable = RouterRefreshListenable(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: listenable,
    redirect: (context, state) {
      final usuariosState = ref.read(notificadorUsuariosProvider);
      final usuarioActivo = usuariosState.usuarioActivo;
      final enPantallaUsuarios = state.matchedLocation == '/usuarios';

      if (usuarioActivo == null) {
        // Obligatorio ir a la pantalla de selección de usuario (evita mostrar el dashboard en carga)
        return '/usuarios';
      }

      if (enPantallaUsuarios) {
        // Si ya seleccionó usuario, ir al dashboard
        return '/';
      }

      return null;
    },
    routes: [
      // Ruta de selección de usuario (fuera del ShellRoute principal para no mostrar sidebar/header)
      GoRoute(
        path: '/usuarios',
        builder: (context, state) => const UserSelectionView(),
      ),
      
      // Rutas de la app envueltas en el Layout principal
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardView(),
            ),
          ),
          GoRoute(
            path: '/historial',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HistoryView(),
            ),
            routes: [
              GoRoute(
                path: 'preview-pdf',
                builder: (context, state) {
                  final datos = state.extra as ReporteDatos;
                  return PdfPreviewView(datos: datos);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/sesiones',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SessionsHistoryView(),
            ),
          ),
          GoRoute(
            path: '/alertas',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AlertsView(),
            ),
          ),
          GoRoute(
            path: '/configuracion',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsView(),
            ),
          ),
        ],
      ),
    ],
  );
});
