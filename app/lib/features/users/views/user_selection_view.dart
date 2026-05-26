import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/usuario_provider.dart';
import '../../../../shared/utils/almacenamiento_local.dart';
import '../widgets/create_user_form.dart';
import '../widgets/user_card.dart';

/// Pantalla de selección de usuario (Gateway obligatorio).
/// Usa IndexedStack para cambio de pestaña instantáneo sin jank.
class UserSelectionView extends ConsumerStatefulWidget {
  const UserSelectionView({super.key});

  @override
  ConsumerState<UserSelectionView> createState() => _UserSelectionViewState();
}

class _UserSelectionViewState extends ConsumerState<UserSelectionView> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, int> _sessionCounts = {};
  bool _cargandoHistoriales = true;
  String _filtroBusqueda = '';
  int _tabActual = 0;

  @override
  void initState() {
    super.initState();
    _cargarConteosSesiones();
    _searchController.addListener(() {
      setState(() {
        _filtroBusqueda = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarConteosSesiones() async {
    try {
      final usuarios = ref.read(notificadorUsuariosProvider).usuarios;
      final Map<String, int> counts = {};
      for (final u in usuarios) {
        final registros = await AlmacenamientoLocal.obtenerRegistros(u.id);
        counts[u.id] = registros.length;
      }
      if (mounted) {
        setState(() {
          _sessionCounts = counts;
          _cargandoHistoriales = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _cargandoHistoriales = false);
      }
    }
  }

  void _crearUsuario(String nombre, String email, int edad) async {
    await ref
        .read(notificadorUsuariosProvider.notifier)
        .crearUsuario(nombre: nombre, email: email, edad: edad);
    await _cargarConteosSesiones();
    if (mounted) {
      context.go('/');
    }
  }

  void _seleccionarUsuario(dynamic usuario) {
    ref.read(notificadorUsuariosProvider.notifier).seleccionarUsuario(usuario);
    context.go('/');
  }

  void _eliminarUsuario(String id) async {
    await ref.read(notificadorUsuariosProvider.notifier).eliminarUsuario(id);
    _cargarConteosSesiones();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final esOscuro = theme.brightness == Brightness.dark;
    final estadoUsuarios = ref.watch(notificadorUsuariosProvider);

    if (estadoUsuarios.usuarios.length != _sessionCounts.length &&
        !_cargandoHistoriales) {
      _cargarConteosSesiones();
    }

    if (estadoUsuarios.cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final usuariosFiltrados = estadoUsuarios.usuarios.where((u) {
      return u.nombre.toLowerCase().contains(_filtroBusqueda) ||
          u.email.toLowerCase().contains(_filtroBusqueda);
    }).toList();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: esOscuro
                ? [const Color(0xFF111115), const Color(0xFF1E1E24)]
                : [const Color(0xFFF9FAFB), const Color(0xFFF3F4F6)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 680),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: esOscuro
                        ? const Color(0xFF333333)
                        : const Color(0xFFECECF0),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: esOscuro ? 0.3 : 0.05),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Header principal ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              LucideIcons.heartPulse,
                              color: theme.colorScheme.primary,
                              size: 32,
                            ),
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
                      ),
                      const Gap(32),

                      // ── Segmented Control (sin TabBar) ──
                      _SegmentedToggle(
                        selectedIndex: _tabActual,
                        labels: const ['Seleccionar Usuario', 'Registrar Nuevo'],
                        onChanged: (i) => setState(() => _tabActual = i),
                      ),
                      const Gap(24),

                      // ── Contenido de las pestañas (sin animación física) ──
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        alignment: Alignment.topCenter,
                        child: _tabActual == 0
                            ? _buildTabSeleccion(
                                theme, esOscuro, estadoUsuarios, usuariosFiltrados)
                            : _buildTabRegistro(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Tab 1: Seleccionar usuario ──
  Widget _buildTabSeleccion(
    ThemeData theme,
    bool esOscuro,
    EstadoUsuarios estadoUsuarios,
    List<dynamic> usuariosFiltrados,
  ) {
    if (estadoUsuarios.usuarios.isEmpty) {
      return SizedBox(
        height: 240,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.usersRound,
                size: 48,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              ),
              const Gap(12),
              Text(
                'No hay usuarios creados',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Gap(6),
              Text(
                'Crea un usuario en la pestaña de Registro.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: esOscuro
                      ? ColoresOscuros.mutedForeground
                      : ColoresClaros.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Buscador
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar por nombre o correo...',
            prefixIcon: const Icon(LucideIcons.search, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
        const Gap(16),
        // Lista (con altura máxima para no explotar verticalmente)
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 340),
          child: usuariosFiltrados.isEmpty
              ? SizedBox(
                  height: 120,
                  child: Center(
                    child: Text(
                      'Sin resultados para "$_filtroBusqueda"',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: esOscuro
                            ? ColoresOscuros.mutedForeground
                            : ColoresClaros.mutedForeground,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: usuariosFiltrados.length,
                  separatorBuilder: (_, __) => const Gap(10),
                  itemBuilder: (context, index) {
                    final u = usuariosFiltrados[index];
                    final esActivo = estadoUsuarios.usuarioActivo?.id == u.id;
                    final sesiones = _sessionCounts[u.id] ?? 0;

                    return TarjetaUsuario(
                      usuario: u,
                      esSeleccionado: esActivo,
                      cantidadSesiones: sesiones,
                      onTap: () => _seleccionarUsuario(u),
                      onDelete: () => _eliminarUsuario(u.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ── Tab 2: Registrar nuevo usuario ──
  Widget _buildTabRegistro() {
    return FormularioCrearUsuario(onSubmit: _crearUsuario);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget custom de toggle segmentado sin TabBar (0 jank, 0 physics)
// ─────────────────────────────────────────────────────────────────────────────
class _SegmentedToggle extends StatelessWidget {
  final int selectedIndex;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  const _SegmentedToggle({
    required this.selectedIndex,
    required this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final esOscuro = theme.brightness == Brightness.dark;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: esOscuro
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: esOscuro ? const Color(0xFF333333) : const Color(0xFFECECF0),
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(labels.length, (i) {
          final esActivo = selectedIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: esActivo ? theme.colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: esActivo
                        ? theme.colorScheme.onPrimary
                        : (esOscuro
                            ? ColoresOscuros.mutedForeground
                            : ColoresClaros.mutedForeground),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
