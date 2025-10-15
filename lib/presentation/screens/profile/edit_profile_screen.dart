import 'package:flutter/material.dart';
import 'package:bloodhero/presentation/widgets/custom_text_form_field.dart';
import 'package:bloodhero/presentation/widgets/primary_button.dart';

class EditProfileScreen extends StatelessWidget {
  static const String name = 'edit_profile_screen';
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CustomTextFormField(labelText: 'Nombre y apellido'),
            const SizedBox(height: 16),
            const CustomTextFormField(labelText: 'Email'),
            const SizedBox(height: 16),
            const CustomTextFormField(labelText: 'Teléfono'),
            const SizedBox(height: 16),
            const CustomTextFormField(labelText: 'Ciudad'),
            const SizedBox(height: 16),
            const CustomTextFormField(labelText: 'Tipo de sangre'),
            const SizedBox(height: 24),
            PrimaryButton(
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
