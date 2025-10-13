import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/presentation/screens/permissions/permissions_screen.dart';
import 'package:bloodhero/presentation/widgets/custom_text_form_field.dart';
import 'package:bloodhero/presentation/widgets/primary_button.dart';

class RegisterScreen extends StatelessWidget {
  static const String name = 'register_screen';
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              children: [
                const CustomTextFormField(labelText: 'Nombre y apellido'),
                const SizedBox(height: 15),
                const CustomTextFormField(
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                const CustomTextFormField(
                  labelText: 'Contraseña',
                  obscureText: true,
                ),
                const SizedBox(height: 15),
                const CustomTextFormField(
                  labelText: 'Teléfono',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 15),
                const CustomTextFormField(labelText: 'Tipo de sangre'),
                const SizedBox(height: 15),
                const CustomTextFormField(labelText: 'Ciudad'),
                const SizedBox(height: 30),
                PrimaryButton(
                  text: 'Crear cuenta',
                  onPressed: () {
                    // TODO: Lógica de registro de usuario
                    context.goNamed(PermissionsScreen.name);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
