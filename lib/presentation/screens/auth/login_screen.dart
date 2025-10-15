import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';
import 'package:bloodhero/presentation/screens/auth/register_screen.dart';
import 'package:bloodhero/presentation/screens/permissions/permissions_screen.dart';
import 'package:bloodhero/presentation/screens/auth/forgot_password_screen.dart';
import 'package:bloodhero/presentation/widgets/custom_text_form_field.dart';
import 'package:bloodhero/presentation/widgets/shared/app_button.dart';

class LoginScreen extends StatelessWidget {
  static const String name = 'login_screen';
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                const CustomTextFormField(labelText: 'Email'),
                const SizedBox(height: kCardSpacing),
                const CustomTextFormField(
                  labelText: 'Contraseña',
                  obscureText: true,
                ),
                const SizedBox(height: kCardSpacing),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.pushNamed(ForgotPasswordScreen.name),
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),
                const SizedBox(height: kSmallSpacing),
                AppButton.primary(
                  text: 'Ingresar',
                  onPressed: () {
                    // TODO: Lógica de inicio de sesión
                    context.goNamed(PermissionsScreen.name);
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
    );
  }
}
