import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/providers/session_provider.dart';
import '../../../../shared/providers/user_provider.dart';
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
  String _searchFilter = '';
  int _currentTab = 0;
  bool _isLoadingCounts = false;

  @override
  void initState() {
    super.initState();
    _loadSessionCounts();
    _searchController.addListener(() {
      setState(() {
        _searchFilter = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSessionCounts() async {
    if (_isLoadingCounts) return;
    _isLoadingCounts = true;
    try {
      final users = ref.read(usersNotifierProvider).users;
      final Map<String, int> counts = {};
      final sessionApi = ref.read(sessionApiServiceProvider);
      for (final u in users) {
        final uId = int.tryParse(u.id);
        if (uId != null) {
          final sessions = await sessionApi.getSessionsByUser(uId);
          counts[u.id] = sessions.length;
        } else {
          counts[u.id] = 0;
        }
      }
      if (mounted) {
        setState(() {
          _sessionCounts = counts;
        });
      }
    } catch (_) {
      // Ignorar errores al cargar conteos
    } finally {
      _isLoadingCounts = false;
    }
  }

  void _createUser(String nombre, String email, int dni) async {
    try {
      await ref
          .read(usersNotifierProvider.notifier)
          .createUser(name: nombre, email: email, dni: dni);
      await _loadSessionCounts();
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString();
        if (errorMsg.startsWith('Exception: ')) {
          errorMsg = errorMsg.substring('Exception: '.length);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMsg,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _selectUser(dynamic usuario) {
    ref.read(usersNotifierProvider.notifier).selectUser(usuario);
    context.go('/');
  }

  void _deleteUser(String id) async {
    await ref.read(usersNotifierProvider.notifier).deleteUser(id);
    _loadSessionCounts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final esOscuro = theme.brightness == Brightness.dark;
    final usersState = ref.watch(usersNotifierProvider);

    ref.listen<UsersState>(usersNotifierProvider, (prev, next) {
      if (prev?.users.length != next.users.length) {
        _loadSessionCounts();
      }
    });

    if (usersState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final filteredUsers = usersState.users.where((u) {
      return u.name.toLowerCase().contains(_searchFilter) ||
          u.email.toLowerCase().contains(_searchFilter);
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
                      color: Colors.black.withValues(
                        alpha: esOscuro ? 0.3 : 0.05,
                      ),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 36,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Header principal componentizado ──
                      UserGatewayHeader(isDark: esOscuro),
                      const Gap(32),

                      // ── Segmented Control (sin TabBar) ──
                      SegmentedToggle(
                        selectedIndex: _currentTab,
                        labels: const [
                          'Seleccionar Usuario',
                          'Registrar Nuevo',
                        ],
                        onChanged: (i) => setState(() => _currentTab = i),
                      ),
                      const Gap(24),

                      // ── Contenido de las pestañas (sin animación física) ──
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        alignment: Alignment.topCenter,
                        child: _currentTab == 0
                            ? UserSelectionTab(
                                searchController: _searchController,
                                filteredUsers: filteredUsers,
                                usersState: usersState,
                                sessionCounts: _sessionCounts,
                                searchFilter: _searchFilter,
                                onSelectUser: _selectUser,
                                onDeleteUser: _deleteUser,
                              )
                            : CreateUserForm(onSubmit: _createUser),
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
