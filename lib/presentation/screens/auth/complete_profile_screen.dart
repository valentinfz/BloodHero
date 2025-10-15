import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/presentation/screens/permissions/permissions_screen.dart';
import 'package:bloodhero/presentation/widgets/custom_text_form_field.dart';
import 'package:bloodhero/presentation/widgets/primary_button.dart';

class CompleteProfileScreen extends StatelessWidget {
  static const String name = 'complete_profile_screen';
  const CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completar perfil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Contanos un poco más de vos para personalizar tu experiencia.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              const CustomTextFormField(labelText: 'Fecha de nacimiento'),
              const SizedBox(height: 16),
              const CustomTextFormField(
                labelText: 'DNI',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const CustomTextFormField(labelText: 'Dirección'),
              const SizedBox(height: 16),
              const CustomTextFormField(labelText: 'Obra social'),
              const SizedBox(height: 16),
              const CustomTextFormField(
                labelText: 'Tipo de sangre',
                helperText: 'Ej: O-, A+, B+, etc.',
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Guardar y continuar',
                onPressed: () => context.goNamed(PermissionsScreen.name),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.goNamed(PermissionsScreen.name),
                child: const Text('Lo completaré más tarde'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
