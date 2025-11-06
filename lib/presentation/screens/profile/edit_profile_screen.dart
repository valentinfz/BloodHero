import 'package:bloodhero/config/theme/layout_constants.dart';
import 'package:bloodhero/domain/entities/user_entity.dart';
import 'package:bloodhero/presentation/providers/repository_providers.dart';
import 'package:bloodhero/presentation/providers/user_provider.dart';
import 'package:bloodhero/presentation/widgets/custom_text_form_field.dart';
import 'package:bloodhero/presentation/widgets/shared/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  static const String name = 'edit_profile_screen';
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _cityController;
  late final TextEditingController _bloodTypeController;
  bool _isSaving = false;

  void _populateFields(UserEntity? user) {
    _nameController.text = user?.name ?? '';
    _emailController.text = user?.email ?? '';
    _phoneController.text = user?.phone ?? '';
    _cityController.text = user?.city ?? '';
    _bloodTypeController.text = user?.bloodType ?? '';
  }

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _bloodTypeController = TextEditingController(text: user?.bloodType ?? '');

    if (user == null) {
      Future.microtask(() async {
        try {
          await ref.read(userProvider.notifier).refresh();
          final refreshed = ref.read(userProvider);
          if (!mounted) return;
          _populateFields(refreshed);
        } catch (_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No pudimos cargar tu perfil. Intenta más tarde o modifica manualmente.',
              ),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _bloodTypeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving) return;

    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final currentUser = ref.read(userProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró un usuario activo para actualizar.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final centersRepository = ref.read(centersRepositoryProvider);
    final updatedUser = currentUser.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      city: _cityController.text.trim(),
      bloodType: _bloodTypeController.text.trim(),
    );

    try {
      await centersRepository.updateUserProfile(updatedUser);
      ref.read(userProvider.notifier).setUser(updatedUser);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente.')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pudimos guardar los cambios. Probá nuevamente.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: SingleChildScrollView(
        padding: kScreenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextFormField(
                controller: _nameController,
                labelText: 'Nombre y apellido',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresá tu nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: kCardSpacing),
              CustomTextFormField(
                controller: _emailController,
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresá tu email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Ingresá un email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: kCardSpacing),
              CustomTextFormField(
                controller: _phoneController,
                labelText: 'Teléfono',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresá tu teléfono';
                  }
                  return null;
                },
              ),
              const SizedBox(height: kCardSpacing),
              CustomTextFormField(
                controller: _cityController,
                labelText: 'Ciudad',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresá tu ciudad';
                  }
                  return null;
                },
              ),
              const SizedBox(height: kCardSpacing),
              CustomTextFormField(
                controller: _bloodTypeController,
                labelText: 'Tipo de sangre',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Indicá tu tipo de sangre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: kSectionSpacing),
              AppButton.primary(
                text: _isSaving ? 'Guardando…' : 'Guardar cambios',
                onPressed: _isSaving ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
