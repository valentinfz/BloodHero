import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';
import 'package:bloodhero/presentation/widgets/custom_text_form_field.dart';
import 'package:bloodhero/presentation/widgets/shared/app_button.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  static const String name = 'forgot_password_screen';
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              const CustomTextFormField(
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: kSectionSpacing),
              AppButton.primary(
                text: 'Enviar instrucciones',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email enviado (demo).')),
                  );
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
    );
  }
}
