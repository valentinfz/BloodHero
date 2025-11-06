import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/layout_constants.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/shared/app_button.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  static const String name = 'register_screen';
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _bloodTypeController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      if (next == AuthState.success) {
        context.goNamed(HomeScreen.name);
      }
      if (next == AuthState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear la cuenta (demo).')),
        );
        ref.read(authProvider.notifier).resetState();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: kScreenPadding,
            child: Column(
              children: [
                CustomTextFormField(
                  labelText: 'Nombre y apellido',
                  controller: _nameController,
                ),
                const SizedBox(height: kCardSpacing),
                CustomTextFormField(
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
                const SizedBox(height: kCardSpacing),
                CustomTextFormField(
                  labelText: 'Contraseña',
                  obscureText: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: kCardSpacing),
                CustomTextFormField(
                  labelText: 'Teléfono',
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,
                ),
                const SizedBox(height: kCardSpacing),
                CustomTextFormField(
                  labelText: 'Tipo de sangre',
                  controller: _bloodTypeController,
                ),
                const SizedBox(height: kCardSpacing),
                CustomTextFormField(
                  labelText: 'Ciudad',
                  controller: _cityController,
                ),
                const SizedBox(height: kSectionSpacing),
                if (authState == AuthState.loading)
                  const Center(child: CircularProgressIndicator())
                else
                  AppButton.primary(
                    text: 'Crear cuenta',
                    onPressed: () {
                      ref.read(authProvider.notifier).register(
                            name: _nameController.text,
                            email: _emailController.text,
                            password: _passwordController.text,
                            phone: _phoneController.text,
                            bloodType: _bloodTypeController.text,
                            city: _cityController.text,
                          );
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
