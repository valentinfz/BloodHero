import 'package:bloodhero/config/theme/layout_constants.dart';
import 'package:bloodhero/presentation/providers/auth_provider.dart';
import 'package:bloodhero/presentation/screens/auth/login_screen.dart';
import 'package:bloodhero/presentation/widgets/shared/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  static const String name = 'security_screen';
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  bool _isChangePasswordExpanded = false;
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  ProviderSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription =
        ref.listenManual<AuthState>(authProvider, _handleAuthStateChanges);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _authSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthInProgress &&
        authState.action == AuthAction.changePassword;
    final isDeleting = authState is AuthInProgress &&
        authState.action == AuthAction.deleteAccount;

    return Scaffold(
      appBar: AppBar(title: const Text('Seguridad')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Protegé tu cuenta',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Cambiar contraseña'),
              subtitle: const Text('Actualizá tu contraseña regularmente'),
              initiallyExpanded: _isChangePasswordExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  _isChangePasswordExpanded = expanded;
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kSectionSpacing,
                    vertical: kCardSpacing,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _PasswordField(
                          label: 'Contraseña actual',
                          controller: _currentPasswordController,
                          obscureText: _obscureCurrent,
                          onToggleVisibility: () {
                            setState(() => _obscureCurrent = !_obscureCurrent);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresá tu contraseña actual';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: kCardSpacing),
                        _PasswordField(
                          label: 'Nueva contraseña',
                          controller: _newPasswordController,
                          obscureText: _obscureNew,
                          onToggleVisibility: () {
                            setState(() => _obscureNew = !_obscureNew);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresá una nueva contraseña';
                            }
                            if (value.length < 6) {
                              return 'Debe tener al menos 6 caracteres';
                            }
                            if (value == _currentPasswordController.text) {
                              return 'Usá una contraseña diferente a la actual';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: kCardSpacing),
                        _PasswordField(
                          label: 'Confirmar nueva contraseña',
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirm,
                          onToggleVisibility: () {
                            setState(() => _obscureConfirm = !_obscureConfirm);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirmá tu nueva contraseña';
                            }
                            if (value != _newPasswordController.text) {
                              return 'Las contraseñas no coinciden';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: kSectionSpacing),
                        AppButton.primary(
                          text:
                              isLoading ? 'Actualizando...' : 'Actualizar contraseña',
                          onPressed: isLoading ? null : _submitChangePassword,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Biometría'),
            subtitle: const Text('Usá tu huella o rostro para iniciar sesión'),
            trailing: Switch(
              value: true,
              onChanged: (_) {
                // TODO: Deshabilitar biometría
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.devices),
            title: const Text('Dispositivos conectados'),
            subtitle: const Text('Gestioná dónde iniciaste sesión'),
            onTap: () {
              // TODO: Mostrar dispositivos
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Eliminar cuenta'),
            subtitle: const Text(
              'Podés solicitar la eliminación de todos tus datos',
            ),
            trailing: isDeleting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            onTap: isDeleting ? null : _confirmDeleteAccount,
          ),
        ],
      ),
    );
  }

  Future<void> _submitChangePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    await ref.read(authProvider.notifier).changePassword(
          currentPassword: _currentPasswordController.text.trim(),
          newPassword: _newPasswordController.text.trim(),
        );
  }

  Future<void> _confirmDeleteAccount() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar cuenta'),
          content: const Text(
            'Esta acción eliminará permanentemente tu cuenta y no se puede deshacer. ¿Querés continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await ref.read(authProvider.notifier).deleteUserAccount();
    }
  }

  void _handleAuthStateChanges(AuthState? previous, AuthState next) {
    if (!mounted) return;

    if (next is AuthFailure && next.action == AuthAction.changePassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(next.message)),
      );
      ref.read(authProvider.notifier).resetState();
      return;
    }

    if (previous is AuthInProgress &&
        previous.action == AuthAction.changePassword &&
        next is AuthCompleted &&
        next.action == AuthAction.changePassword) {
      _formKey.currentState?.reset();
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tu contraseña fue actualizada.')),
      );
      ref.read(authProvider.notifier).resetState();
      return;
    }

    if (next is AuthFailure && next.action == AuthAction.deleteAccount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(next.message)),
      );
      ref.read(authProvider.notifier).resetState();
      return;
    }

    if (previous is AuthInProgress &&
        previous.action == AuthAction.deleteAccount &&
        next is AuthCompleted &&
        next.action == AuthAction.deleteAccount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tu cuenta fue eliminada.')),
      );
      ref.read(authProvider.notifier).resetState();
      context.goNamed(LoginScreen.name);
    }
  }
}

class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }
}
