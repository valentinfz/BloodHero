import 'package:bloodhero/presentation/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/layout_constants.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/shared/app_button.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const String name = 'login_screen';
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      if (next == AuthState.success) {
        // Al iniciar sesión, vamos directamente a la pantalla Home ahora (posible cambio)
        context.goNamed(HomeScreen.name);
      }
      if (next == AuthState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Credenciales incorrectas (demo).'),
          ),
        );
        ref.read(authProvider.notifier).resetState();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: kScreenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                Text('Iniciar sesión', style: textTheme.headlineMedium),
                const SizedBox(height: kSectionSpacing),
                CustomTextFormField(
                  labelText: 'Email',
                  controller: _emailController,
                ),
                const SizedBox(height: kCardSpacing),
                CustomTextFormField(
                  labelText: 'Contraseña',
                  obscureText: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: kCardSpacing),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        context.pushNamed(ForgotPasswordScreen.name),
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),
                const SizedBox(height: kSmallSpacing),
                AppButton.primary(
                  text: 'Ingresar',
                  onPressed: authState == AuthState.loading
                      ? null
                      : () {
                          ref
                              .read(authProvider.notifier)
                              .login(
                                _emailController.text,
                                _passwordController.text,
                              );
                        },
                ),
                if (authState == AuthState.loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                const SizedBox(height: kCardSpacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿No tienes una cuenta?'),
                    TextButton(
                      onPressed: () => context.goNamed(RegisterScreen.name),
                      child: const Text('Regístrate'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
