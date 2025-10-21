import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';
import 'package:bloodhero/presentation/screens/permissions/permissions_screen.dart';
import 'package:bloodhero/presentation/widgets/custom_text_form_field.dart';
import 'package:bloodhero/presentation/widgets/shared/app_button.dart';

class RegisterScreen extends StatelessWidget {
  static const String name = 'register_screen';
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: kScreenPadding,
            child: Column(
              children: [
                const CustomTextFormField(labelText: 'Nombre y apellido'),
                const SizedBox(height: kCardSpacing),
                const CustomTextFormField(
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: kCardSpacing),
                const CustomTextFormField(
                  labelText: 'Contraseña',
                  obscureText: true,
                ),
                const SizedBox(height: kCardSpacing),
                const CustomTextFormField(
                  labelText: 'Teléfono',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: kCardSpacing),
                const CustomTextFormField(labelText: 'Tipo de sangre'),
                const SizedBox(height: kCardSpacing),
                const CustomTextFormField(labelText: 'Ciudad'),
                const SizedBox(height: kSectionSpacing),
                AppButton.primary(
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
