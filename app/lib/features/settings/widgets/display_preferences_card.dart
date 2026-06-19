import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../shared/providers/theme_provider.dart';

class DisplayPreferencesCard extends ConsumerStatefulWidget {
  final Color subtitleColor;
  final Color borderColor;

  const DisplayPreferencesCard({
    super.key,
    required this.subtitleColor,
    required this.borderColor,
  });

  @override
  ConsumerState<DisplayPreferencesCard> createState() =>
      _DisplayPreferencesCardState();
}

class _DisplayPreferencesCardState
    extends ConsumerState<DisplayPreferencesCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeMode = ref.watch(themeNotifierProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.palette, color: theme.colorScheme.primary),
              const Gap(10),
              Text(
                'Preferencias de Visualización',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(8),
          Text(
            'Personalice el tema visual de la aplicación y las unidades de medida.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: widget.subtitleColor,
            ),
          ),
          const Gap(24),

          // Selector de Tema
          Text(
            'Tema de la Aplicación',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(10),
          LayoutBuilder(
            builder: (context, constraints) {
              final esAncho = constraints.maxWidth > 500;
              return esAncho
                  ? SegmentedButton<ThemeMode>(
                      segments: const <ButtonSegment<ThemeMode>>[
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.light,
                          label: Text('Modo Claro'),
                          icon: Icon(LucideIcons.sun, size: 16),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.dark,
                          label: Text('Modo Oscuro'),
                          icon: Icon(LucideIcons.moon, size: 16),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.system,
                          label: Text('Sistema'),
                          icon: Icon(LucideIcons.monitor, size: 16),
                        ),
                      ],
                      selected: <ThemeMode>{themeMode},
                      onSelectionChanged: (Set<ThemeMode> newSelection) {
                        ref
                            .read(themeNotifierProvider.notifier)
                            .changeTheme(newSelection.first);
                      },
                      style: SegmentedButton.styleFrom(
                        visualDensity: VisualDensity.comfortable,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ThemeOptionTile(
                          icon: LucideIcons.sun,
                          label: 'Modo Claro',
                          isSelected: themeMode == ThemeMode.light,
                          onTap: () => ref
                              .read(themeNotifierProvider.notifier)
                              .changeTheme(ThemeMode.light),
                          borderColor: widget.borderColor,
                          isDark: isDark,
                        ),
                        const Gap(8),
                        _ThemeOptionTile(
                          icon: LucideIcons.moon,
                          label: 'Modo Oscuro',
                          isSelected: themeMode == ThemeMode.dark,
                          onTap: () => ref
                              .read(themeNotifierProvider.notifier)
                              .changeTheme(ThemeMode.dark),
                          borderColor: widget.borderColor,
                          isDark: isDark,
                        ),
                        const Gap(8),
                        _ThemeOptionTile(
                          icon: LucideIcons.monitor,
                          label: 'Tema del Sistema',
                          isSelected: themeMode == ThemeMode.system,
                          onTap: () => ref
                              .read(themeNotifierProvider.notifier)
                              .changeTheme(ThemeMode.system),
                          borderColor: widget.borderColor,
                          isDark: isDark,
                        ),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color borderColor;
  final bool isDark;

  const _ThemeOptionTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.borderColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : borderColor,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.iconTheme.color,
            ),
            const Gap(12),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? theme.colorScheme.primary : null,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                LucideIcons.check,
                size: 16,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
