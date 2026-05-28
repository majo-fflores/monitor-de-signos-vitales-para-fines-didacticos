import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/providers/usuario_provider.dart';
import '../../../../shared/utils/almacenamiento_local.dart';
import '../widgets/create_user_form.dart';
import '../widgets/segmented_toggle.dart';
import '../widgets/user_gateway_header.dart';
import '../widgets/user_selection_tab.dart';

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
                      // ── Header principal componentizado ──
                      UserGatewayHeader(esOscuro: esOscuro),
                      const Gap(32),

                      // ── Segmented Control (sin TabBar) ──
                      SegmentedToggle(
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
                            ? UserSelectionTab(
                                searchController: _searchController,
                                usuariosFiltrados: usuariosFiltrados,
                                estadoUsuarios: estadoUsuarios,
                                sessionCounts: _sessionCounts,
                                filtroBusqueda: _filtroBusqueda,
                                onSeleccionarUsuario: _seleccionarUsuario,
                                onEliminarUsuario: _eliminarUsuario,
                              )
                            : FormularioCrearUsuario(onSubmit: _crearUsuario),
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
}
