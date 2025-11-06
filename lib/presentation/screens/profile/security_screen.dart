import 'package:bloodhero/core/utils/repository_exception.dart';
import 'package:bloodhero/presentation/providers/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/login_screen.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  static const String name = 'security_screen';
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  bool _isBiometricsEnabled = true;
  bool _isProcessingAction = false;

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  Future<void> _handlePasswordChange() async {
    if (_isProcessingAction) return;

    final newPassword = await _promptPasswordDialog();
    if (newPassword == null) return;

    setState(() => _isProcessingAction = true);
    final authRepository = ref.read(authRepositoryProvider);
    try {
      await authRepository.updatePassword(newPassword);
      _showMessage('Contraseña actualizada correctamente');
    } on RepositoryException catch (e) {
      _showMessage(e.message, isError: true);
    } catch (_) {
      _showMessage(
        'Ocurrió un error al actualizar la contraseña. Intentá nuevamente.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessingAction = false);
      }
    }
  }

  Future<String?> _promptPasswordDialog() async {
    final formKey = GlobalKey<FormState>();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cambiar contraseña'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Nueva contraseña',
                    ),
                    autofocus: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresá una contraseña';
                      }
                      if (value.trim().length < 6) {
                        return 'Debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Repetir contraseña',
                    ),
                    validator: (value) {
                      if (value != newPasswordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final isValid = formKey.currentState?.validate() ?? false;
                if (isValid) {
                  Navigator.of(dialogContext)
                      .pop(newPasswordController.text.trim());
                }
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  void _toggleBiometrics(bool value) {
    setState(() => _isBiometricsEnabled = value);
    _showMessage(
      value
          ? 'Biometría habilitada para futuros ingresos.'
          : 'Biometría deshabilitada. Usá tu contraseña para ingresar.',
    );
  }

  Future<void> _showConnectedDevices() async {
    const connectedDevices = [
      {'name': 'Pixel 8', 'lastActive': 'Último acceso hace 2 h'},
      {'name': 'iPhone 14', 'lastActive': 'Último acceso hace 1 día'},
      {'name': 'Web - Chrome', 'lastActive': 'Sesión actual'},
    ];

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dispositivos conectados',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ...connectedDevices.map((device) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.devices_other),
                      title: Text(device['name']!),
                      subtitle: Text(device['lastActive']!),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleDeleteAccount() async {
    if (_isProcessingAction) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar cuenta'),
          content: const Text(
            'Esta acción eliminará tu cuenta y no se puede deshacer. ' 
            '¿Querés continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    setState(() => _isProcessingAction = true);
    final authRepository = ref.read(authRepositoryProvider);
    try {
      await authRepository.deleteAccount();
      if (!mounted) return;
      _showMessage('Cuenta eliminada. Te esperamos pronto de vuelta.');
      context.goNamed(LoginScreen.name);
    } on RepositoryException catch (e) {
      _showMessage(e.message, isError: true);
    } catch (_) {
      _showMessage(
        'No pudimos eliminar tu cuenta. Intentá más tarde.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessingAction = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tilesAreEnabled = !_isProcessingAction;

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
          ListTile(
            enabled: tilesAreEnabled,
            leading: const Icon(Icons.lock_outline),
            title: const Text('Cambiar contraseña'),
            subtitle: const Text('Actualizá tu contraseña regularmente'),
            onTap: _handlePasswordChange,
          ),
          ListTile(
            enabled: tilesAreEnabled,
            leading: const Icon(Icons.fingerprint),
            title: const Text('Biometría'),
            subtitle: const Text('Usá tu huella o rostro para iniciar sesión'),
            trailing: Switch.adaptive(
              value: _isBiometricsEnabled,
              onChanged: tilesAreEnabled ? _toggleBiometrics : null,
            ),
          ),
          ListTile(
            enabled: tilesAreEnabled,
            leading: const Icon(Icons.devices),
            title: const Text('Dispositivos conectados'),
            subtitle: const Text('Gestioná dónde iniciaste sesión'),
            onTap: _showConnectedDevices,
          ),
          const Divider(),
          ListTile(
            enabled: tilesAreEnabled,
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Eliminar cuenta'),
            subtitle: const Text(
              'Podés solicitar la eliminación de todos tus datos',
            ),
            onTap: _handleDeleteAccount,
          ),
        ],
      ),
    );
  }
}
