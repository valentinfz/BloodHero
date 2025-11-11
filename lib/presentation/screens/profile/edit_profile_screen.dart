import 'package:bloodhero/config/theme/layout_constants.dart';
import 'package:bloodhero/domain/entities/user_entity.dart';
import 'package:bloodhero/presentation/providers/auth_provider.dart';
import 'package:bloodhero/presentation/providers/home_provider.dart';
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
  static const _bloodTypes = [
    'No especificado',
    'O-',
    'O+',
    'A-',
    'A+',
    'B-',
    'B+',
    'AB-',
    'AB+',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  String? _selectedBloodType;
  bool _initialized = false;
  ProviderSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription =
        ref.listenManual<AuthState>(authProvider, _onAuthStateChange);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _authSubscription?.close();
    super.dispose();
  }

  void _fillForm(UserEntity user) {
    if (_initialized) return;
    _nameController.text = user.name;
    _emailController.text = user.email;
    _phoneController.text = user.phone == 'No teléfono' ? '' : user.phone;
    _cityController.text = user.city == 'No ciudad' ? '' : user.city;
  final normalizedBloodType = user.bloodType.trim();
  _selectedBloodType = _bloodTypes.contains(normalizedBloodType)
    ? normalizedBloodType
    : _bloodTypes.first;
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final authState = ref.watch(authProvider);
  final isSubmitting = authState is AuthInProgress &&
    authState.action == AuthAction.updateProfile;

    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error al cargar el perfil: $error'),
        ),
        data: (user) {
          _fillForm(user);

          return SingleChildScrollView(
            padding: kScreenPadding,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextFormField(
                    labelText: 'Nombre y apellido',
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresá tu nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: kCardSpacing),
                  CustomTextFormField(
                    labelText: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    readOnly: true,
                  ),
                  const SizedBox(height: kCardSpacing),
                  CustomTextFormField(
                    labelText: 'Teléfono',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: kCardSpacing),
                  CustomTextFormField(
                    labelText: 'Ciudad',
                    controller: _cityController,
                  ),
                  const SizedBox(height: kCardSpacing),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Tipo de sangre',
                    ),
                    // ignore: deprecated_member_use
                    value: _selectedBloodType,
                    items: _bloodTypes
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ),
                        )
                        .toList(),
                    onChanged: isSubmitting
                        ? null
                        : (value) {
                            setState(() {
                              _selectedBloodType = value;
                            });
                          },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Seleccioná tu tipo de sangre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: kSectionSpacing),
                  AppButton.primary(
                    text: isSubmitting ? 'Guardando...' : 'Guardar cambios',
                    onPressed: isSubmitting ? null : _submit,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    await ref.read(authProvider.notifier).updateUserProfile({
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'city': _cityController.text.trim(),
      'bloodType': _selectedBloodType,
    });
  }

  void _onAuthStateChange(AuthState? previous, AuthState next) {
    if (!mounted) return;
    if (next is AuthFailure && next.action == AuthAction.updateProfile) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(next.message)),
      );
      ref.read(authProvider.notifier).resetState();
      return;
    }
    if (previous is AuthInProgress &&
        previous.action == AuthAction.updateProfile &&
        next is AuthCompleted &&
        next.action == AuthAction.updateProfile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente.')),
      );
      ref.invalidate(userProfileProvider);
      Navigator.of(context).pop();
      ref.read(authProvider.notifier).resetState();
    }
  }
}
