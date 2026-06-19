import 'package:datavital_flutter/shared/widgets/layout/sidebar_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('SidebarNav Widget Tests', () {
    testWidgets('should render all nav items and handle taps', (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: SidebarNav()),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) =>
                const Scaffold(body: Text('Reportes Page')),
          ),
          GoRoute(
            path: '/sessions',
            builder: (context, state) =>
                const Scaffold(body: Text('Sesiones Page')),
          ),
          GoRoute(
            path: '/alerts',
            builder: (context, state) =>
                const Scaffold(body: Text('Alertas Page')),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) =>
                const Scaffold(body: Text('Configuracion Page')),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      // Verify that all Elements are rendered (tooltips exist)
      expect(find.byType(Tooltip), findsNWidgets(5));

      // Tap on Historial item (index 2)
      final items = find.byType(InkWell);
      expect(items, findsNWidgets(5));

      await tester.tap(items.at(2));
      await tester.pumpAndSettle();

      // Should have navigated to /historial
      expect(find.text('Reportes Page'), findsOneWidget);
    });
  });
}
