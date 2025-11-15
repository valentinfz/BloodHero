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
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

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
    final isLoading =
        authState is AuthInProgress && authState.action == AuthAction.login;

    ref.listen(authProvider, (previous, next) {
      if (next is AuthCompleted && next.action == AuthAction.login) {
        ref.read(authProvider.notifier).resetState();
        context.goNamed(HomeScreen.name);
      }
      if (next is AuthFailure && next.action == AuthAction.login) {
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: kScreenPadding,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  Text(
                    'Iniciar sesión',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: kSectionSpacing),
                  CustomTextFormField(
                    labelText: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final trimmed = value?.trim() ?? '';
                      if (trimmed.isEmpty) {
                        return 'Ingresá tu email';
                      }
                      if (!trimmed.contains('@')) {
                        return 'El email no es válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: kCardSpacing),
                  CustomTextFormField(
                    labelText: 'Contraseña',
                    obscureText: _obscurePassword,
                    controller: _passwordController,
                    validator: (value) {
                      final trimmed = value?.trim() ?? '';
                      if (trimmed.isEmpty) {
                        return 'Ingresá tu contraseña';
                      }
                      if (trimmed.length < 6) {
                        return 'Debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
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
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    AppButton.primary(
                      text: 'Ingresar',
                      onPressed: () {
                        if (isLoading) return;
                        if (!(_formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        FocusScope.of(context).unfocus();
                        ref
                            .read(authProvider.notifier)
                            .login(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            );
                      },
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
      ),
    );
  }
}
