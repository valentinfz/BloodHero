import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/presentation/widgets/custom_text_form_field.dart';
import 'package:bloodhero/presentation/widgets/primary_button.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Ingresá tu email y te enviaremos instrucciones para restablecerla.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              const CustomTextFormField(
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Enviar instrucciones',
                onPressed: () {
                  // TODO: Implementar envío de email de recuperación
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email enviado (demo).')),
                  );
                },
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.goNamed(LoginScreen.name),
                child: const Text('Volver al inicio de sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
