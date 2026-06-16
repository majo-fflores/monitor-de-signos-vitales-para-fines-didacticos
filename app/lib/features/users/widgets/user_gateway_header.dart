import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';

class UserGatewayHeader extends StatelessWidget {
  final bool esOscuro;

  const UserGatewayHeader({super.key, required this.esOscuro});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          esOscuro
              ? 'assets/svg/isotipo-dark.svg'
              : 'assets/svg/isotipo-light.svg',
          width: 40,
          height: 40,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DataVital',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            Text(
              'Monitoreo Médico Inteligente',
              style: theme.textTheme.bodySmall?.copyWith(
                color: esOscuro
                    ? ColoresOscuros.mutedForeground
                    : ColoresClaros.mutedForeground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
