import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';
import 'package:bloodhero/presentation/screens/permissions/permissions_screen.dart';
import 'package:bloodhero/presentation/widgets/custom_text_form_field.dart';
import 'package:bloodhero/presentation/widgets/shared/app_button.dart';

class CompleteProfileScreen extends StatelessWidget {
  static const String name = 'complete_profile_screen';
  const CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completar perfil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: kScreenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Contanos un poco más de vos para personalizar tu experiencia.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: kSectionSpacing),
              const CustomTextFormField(labelText: 'Fecha de nacimiento'),
              const SizedBox(height: kCardSpacing),
              const CustomTextFormField(
                labelText: 'DNI',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: kCardSpacing),
              const CustomTextFormField(labelText: 'Dirección'),
              const SizedBox(height: kCardSpacing),
              const CustomTextFormField(labelText: 'Obra social'),
              const SizedBox(height: kCardSpacing),
              const CustomTextFormField(
                labelText: 'Tipo de sangre',
                helperText: 'Ej: O-, A+, B+, etc.',
              ),
              const SizedBox(height: kSectionSpacing),
              AppButton.primary(
                text: 'Guardar y continuar',
                onPressed: () => context.goNamed(PermissionsScreen.name),
              ),
              const SizedBox(height: kItemSpacing),
              AppButton.text(
                text: 'Lo completaré más tarde',
                onPressed: () => context.goNamed(PermissionsScreen.name),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
