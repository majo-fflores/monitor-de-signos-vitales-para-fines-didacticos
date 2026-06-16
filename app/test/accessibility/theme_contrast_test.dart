import 'package:datavital_flutter/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ThemeContrast Accessibility Tests (WCAG Ratios)', () {
    // Calculates contrast ratio between two colors using WCAG formula:
    // (L1 + 0.05) / (L2 + 0.05) where L1 is lighter and L2 is darker
    double calculateContrastRatio(Color c1, Color c2) {
      final double l1 = c1.computeLuminance();
      final double l2 = c2.computeLuminance();
      final double lighter = l1 > l2 ? l1 : l2;
      final double darker = l1 > l2 ? l2 : l1;
      return (lighter + 0.05) / (darker + 0.05);
    }

    group('Light Theme Contrast Ratios', () {
      test('Background vs Foreground contrast should meet WCAG AA (>= 4.5)', () {
        final ratio = calculateContrastRatio(
          ColoresClaros.background,
          ColoresClaros.foreground,
        );
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason:
              'Background and Foreground contrast should be >= 4.5:1 (Got ${ratio.toStringAsFixed(2)})',
        );
      });

      test('Card vs CardForeground contrast should meet WCAG AA (>= 4.5)', () {
        final ratio = calculateContrastRatio(
          ColoresClaros.card,
          ColoresClaros.cardForeground,
        );
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason:
              'Card and CardForeground contrast should be >= 4.5:1 (Got ${ratio.toStringAsFixed(2)})',
        );
      });

      test(
        'Primary vs PrimaryForeground contrast should meet WCAG AA (>= 4.5)',
        () {
          final ratio = calculateContrastRatio(
            ColoresClaros.primary,
            ColoresClaros.primaryForeground,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason:
                'Primary and PrimaryForeground contrast should be >= 4.5:1 (Got ${ratio.toStringAsFixed(2)})',
          );
        },
      );

      test(
        'Sidebar vs SidebarForeground contrast should meet WCAG AA (>= 4.5)',
        () {
          final ratio = calculateContrastRatio(
            ColoresClaros.sidebar,
            ColoresClaros.sidebarForeground,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason:
                'Sidebar and SidebarForeground contrast should be >= 4.5:1 (Got ${ratio.toStringAsFixed(2)})',
          );
        },
      );
    });

    group('Dark Theme Contrast Ratios', () {
      test('Background vs Foreground contrast should meet WCAG AA (>= 4.5)', () {
        final ratio = calculateContrastRatio(
          ColoresOscuros.background,
          ColoresOscuros.foreground,
        );
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason:
              'Background and Foreground contrast should be >= 4.5:1 (Got ${ratio.toStringAsFixed(2)})',
        );
      });

      test('Card vs CardForeground contrast should meet WCAG AA (>= 4.5)', () {
        final ratio = calculateContrastRatio(
          ColoresOscuros.card,
          ColoresOscuros.cardForeground,
        );
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason:
              'Card and CardForeground contrast should be >= 4.5:1 (Got ${ratio.toStringAsFixed(2)})',
        );
      });

      test(
        'Primary vs PrimaryForeground contrast should meet WCAG AA (>= 4.5)',
        () {
          final ratio = calculateContrastRatio(
            ColoresOscuros.primary,
            ColoresOscuros.primaryForeground,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason:
                'Primary and PrimaryForeground contrast should be >= 4.5:1 (Got ${ratio.toStringAsFixed(2)})',
          );
        },
      );

      test(
        'Sidebar vs SidebarForeground contrast should meet WCAG AA (>= 4.5)',
        () {
          final ratio = calculateContrastRatio(
            ColoresOscuros.sidebar,
            ColoresOscuros.sidebarForeground,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason:
                'Sidebar and SidebarForeground contrast should be >= 4.5:1 (Got ${ratio.toStringAsFixed(2)})',
          );
        },
      );
    });

    group('Sensor Color Text Contrast Ratios', () {
      test(
        'Green Clinical Status vs White Background contrast should be readable',
        () {
          final ratio = calculateContrastRatio(
            ColoresSensores.statusConectado,
            Colors.white,
          );
          // Note: green on white is usually at least 2.5:1
          expect(
            ratio,
            greaterThanOrEqualTo(2.5),
            reason:
                'Green clinical status on white should have contrast >= 2.5:1',
          );
        },
      );

      test(
        'Red Critical Status vs White Background contrast should meet WCAG AA (>= 4.5)',
        () {
          final ratio = calculateContrastRatio(
            ColoresSensores.criticoClaro,
            Colors.white,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason:
                'Red clinical status on white should have contrast >= 4.5:1',
          );
        },
      );
    });
  });
}
