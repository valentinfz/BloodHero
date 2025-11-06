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
  final _formKey = GlobalKey<FormState>();

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
      if (previous is AuthLoading && next is AuthInitial) {
        if (!context.mounted) return; // Verificación de seguridad
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email de recuperación enviado.'),
            backgroundColor: Colors.green,
          ),
        );
        // Regresamos a la pantalla de Login
        context.goNamed(LoginScreen.name);
      }

      // Error: Detectamos el estado de error y mostramos el mensaje
      if (next is AuthError) {
        if (!context.mounted) return; // Verificación de seguridad
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.message}'),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(authProvider.notifier).resetState();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: SafeArea(
        child: Padding(
          padding: kScreenPadding,
          child: Form(
            key: _formKey,
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
                  validator: (value) {
                    // Validador de email
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return 'Ingresa un email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: kSectionSpacing),

                if (authState is AuthLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  AppButton.primary(
                    text: 'Enviar instrucciones',
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        ref
                            .read(authProvider.notifier)
                            .forgotPassword(_emailController.text);
                      }
                    },
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
      ),
    );
  }
}
