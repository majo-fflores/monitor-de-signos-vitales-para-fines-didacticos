import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Formulario para crear un nuevo usuario.
/// Puede ser utilizado de forma inline en pantallas grandes o dentro de diálogos/hojas.
class FormularioCrearUsuario extends StatefulWidget {
  final Function(String nombre, String email) onSubmit;
  final VoidCallback? onCancel;

  const FormularioCrearUsuario({
    super.key,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  State<FormularioCrearUsuario> createState() => _FormularioCrearUsuarioState();
}

class _FormularioCrearUsuarioState extends State<FormularioCrearUsuario> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        _nombreController.text.trim(),
        _emailController.text.trim(),
      );
      // Limpiamos los controladores después de guardar
      _nombreController.clear();
      _emailController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Crear Nuevo Usuario',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(16),
          TextFormField(
            controller: _nombreController,
            decoration: InputDecoration(
              labelText: 'Nombre Completo',
              hintText: 'Ej. María Giménez',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'El nombre es obligatorio';
              }
              return null;
            },
          ),
          const Gap(16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Correo Electrónico',
              hintText: 'Ej. maria@correo.com',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'El correo electrónico es obligatorio';
              }
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
              if (!emailRegex.hasMatch(val.trim())) {
                return 'Ingrese un correo electrónico válido';
              }
              return null;
            },
          ),
          const Gap(24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (widget.onCancel != null) ...[
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _guardar,
                  child: const Text(
                    'CREAR Y SELECCIONAR',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
