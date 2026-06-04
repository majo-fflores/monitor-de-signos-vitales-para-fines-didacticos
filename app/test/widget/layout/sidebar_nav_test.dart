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
            path: '/historial',
            builder: (context, state) => const Scaffold(body: Text('Historial Page')),
          ),
          GoRoute(
            path: '/sesiones',
            builder: (context, state) => const Scaffold(body: Text('Sesiones Page')),
          ),
          GoRoute(
            path: '/alertas',
            builder: (context, state) => const Scaffold(body: Text('Alertas Page')),
          ),
          GoRoute(
            path: '/configuracion',
            builder: (context, state) => const Scaffold(body: Text('Configuracion Page')),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      // Verify that all Elements are rendered (tooltips exist)
      expect(find.byType(Tooltip), findsNWidgets(5));

      // Tap on Historial item (index 1)
      final items = find.byType(InkWell);
      expect(items, findsNWidgets(5));
      
      await tester.tap(items.at(1));
      await tester.pumpAndSettle();

      // Should have navigated to /historial
      expect(find.text('Historial Page'), findsOneWidget);
    });
  });
}
