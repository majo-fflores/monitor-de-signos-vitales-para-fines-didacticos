import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

/// Formulario para crear un nuevo usuario.
/// Puede ser utilizado de forma inline en pantallas grandes o dentro de diálogos/hojas.
class CreateUserForm extends StatefulWidget {
  final Function(String name, String email, int dni) onSubmit;
  final VoidCallback? onCancel;

  const CreateUserForm({super.key, required this.onSubmit, this.onCancel});

  @override
  State<CreateUserForm> createState() => _CreateUserFormState();
}

class _CreateUserFormState extends State<CreateUserForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dniController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dniController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final dniVal = int.parse(_dniController.text.trim());
      widget.onSubmit(
        _nameController.text.trim(),
        _emailController.text.trim(),
        dniVal,
      );
      // Limpiamos los controladores después de guardar
      _nameController.clear();
      _emailController.clear();
      _dniController.clear();
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
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nombre Completo',
              hintText: 'Ej. María Giménez',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
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
            controller: _dniController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'DNI',
              hintText: 'Ej. 12345678',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'El DNI es obligatorio';
              }
              final dni = int.tryParse(val.trim());
              if (dni == null) {
                return 'Ingrese un DNI válido (solo números)';
              }
              if (dni <= 0) {
                return 'El DNI debe ser mayor a 0';
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
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
                  onPressed: _save,
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
