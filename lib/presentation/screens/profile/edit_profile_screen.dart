import 'package:flutter/material.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';
import 'package:bloodhero/presentation/widgets/custom_text_form_field.dart';
import 'package:bloodhero/presentation/widgets/shared/app_button.dart';

class EditProfileScreen extends StatelessWidget {
  static const String name = 'edit_profile_screen';
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: SingleChildScrollView(
        padding: kScreenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CustomTextFormField(labelText: 'Nombre y apellido'),
            const SizedBox(height: kCardSpacing),
            const CustomTextFormField(labelText: 'Email'),
            const SizedBox(height: kCardSpacing),
            const CustomTextFormField(labelText: 'Teléfono'),
            const SizedBox(height: kCardSpacing),
            const CustomTextFormField(labelText: 'Ciudad'),
            const SizedBox(height: kCardSpacing),
            const CustomTextFormField(labelText: 'Tipo de sangre'),
            const SizedBox(height: kSectionSpacing),
            AppButton.primary(
              text: 'Guardar cambios',
              onPressed: () {
                // TODO: Guardar perfil
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
