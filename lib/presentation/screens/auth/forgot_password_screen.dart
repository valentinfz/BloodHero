import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/layout_constants.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/shared/app_button.dart';
import 'login_screen.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  static const String name = 'forgot_password_screen';
  const ForgotPasswordScreen({super.key});

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Observamos el estado del provider para reaccionar a la UI
    final authState = ref.watch(authProvider);

    // Escuchamos los cambios de estado para acciones únicas
    ref.listen(authProvider, (previous, next) {
      if (next == AuthState.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email de recuperación enviado (demo).'),
          ),
        );
        // Reseteamos el estado para futuras operaciones
        ref.read(authProvider.notifier).resetState();
      }
      if (next == AuthState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al enviar el email (demo).')),
        );
        ref.read(authProvider.notifier).resetState();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: SafeArea(
        child: Padding(
          padding: kScreenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Ingresá tu email y te enviaremos instrucciones para restablecerla.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: kSectionSpacing),
              CustomTextFormField(
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
                controller: _emailController, // Conectamos el controller
              ),
              const SizedBox(height: kSectionSpacing),
              // El botón se deshabilita mientras está en estado de carga
              AppButton.primary(
                text: 'Enviar instrucciones',
                onPressed: authState == AuthState.loading
                    ? null
                    : () {
                        // Llamamos al método del provider
                        ref
                            .read(authProvider.notifier)
                            .forgotPassword(_emailController.text);
                      },
              ),
              // Mostramos un spinner si el estado es 'loading'
              if (authState == AuthState.loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              const Spacer(),
              AppButton.text(
                text: 'Volver al inicio de sesión',
                onPressed: () => context.goNamed(LoginScreen.name),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
