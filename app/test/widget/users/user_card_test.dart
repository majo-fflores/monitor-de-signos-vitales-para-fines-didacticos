import 'package:datavital_flutter/features/users/widgets/user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('UserCard Widget Tests', () {
    testWidgets('should render user information and handle tap', (
      tester,
    ) async {
      final user = TestData.user1;
      bool tapped = false;

      await tester.pumpWidget(
        createTestableWidget(
          child: UserCard(
            user: user,
            isSelected: false,
            sessionCount: 5,
            onTap: () {
              tapped = true;
            },
            onDelete: () {},
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
      expect(find.text('JD'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);

      await tester.tap(find.text('John Doe'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('should show dialog and call onDelete when confirmed', (
      tester,
    ) async {
      final user = TestData.user1;
      bool deleted = false;

      await tester.pumpWidget(
        createTestableWidget(
          child: UserCard(
            user: user,
            isSelected: true,
            sessionCount: 0,
            onTap: () {},
            onDelete: () {
              deleted = true;
            },
          ),
        ),
      );

      final deleteBtnFinder = find.byType(IconButton);
      expect(deleteBtnFinder, findsOneWidget);

      await tester.tap(deleteBtnFinder);
      await tester.pumpAndSettle();

      expect(find.text('¿Eliminar usuario?'), findsOneWidget);
      expect(
        find.text(
          'Se eliminará permanentemente a John Doe y todo su historial local.',
        ),
        findsOneWidget,
      );

      final confirmBtnFinder = find.widgetWithText(FilledButton, 'Eliminar');
      expect(confirmBtnFinder, findsOneWidget);

      await tester.tap(confirmBtnFinder);
      await tester.pumpAndSettle();

      expect(deleted, isTrue);
    });
  });
}
