import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/layout_constants.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/shared/app_button.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  static const String name = 'register_screen';
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();

  String? _selectedBloodType;
  final List<String> _bloodTypes = const [
    'O-',
    'O+',
    'A-',
    'A+',
    'B-',
    'B+',
    'AB-',
    'AB+',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  String? _validateNonEmpty(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Usamos 'watch' para que la UI se reconstruya (ej. para mostrar/ocultar el spinner)
    final authState = ref.watch(authProvider);

    // Usamos 'listen' para acciones que solo deben ocurrir UNA VEZ por cambio de estado
    // (como navegar o mostrar un SnackBar)
    ref.listen(authProvider, (previous, next) {
      if (next is AuthSuccess) {
        // Al registrarse, vamos a la pantalla Home
        context.goNamed(HomeScreen.name);
      }
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // Mostramos el mensaje de error real
            content: Text('Error: ${next.message}'),
            backgroundColor: Colors.red,
          ),
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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextFormField(
                    labelText: 'Nombre y apellido',
                    controller: _nameController,
                    validator: _validateNonEmpty,
                  ),
                  const SizedBox(height: kCardSpacing),
                  CustomTextFormField(
                    labelText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty ||
                          !value.contains('@')) {
                        return 'Ingresa un email válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: kCardSpacing),
                  CustomTextFormField(
                    labelText: 'Contraseña',
                    obscureText: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      if (value.length < 6) {
                        return 'Debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: kCardSpacing),
                  CustomTextFormField(
                    labelText: 'Teléfono',
                    keyboardType: TextInputType.phone,
                    controller: _phoneController,
                    validator: _validateNonEmpty,
                  ),
                  const SizedBox(height: kCardSpacing),
                  DropdownButtonFormField<String>(
                    // value: _selectedBloodType,
                    initialValue: _selectedBloodType,
                    hint: const Text('Tipo de sangre'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                    items: _bloodTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedBloodType = newValue;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Selecciona una opción' : null,
                  ),

                  const SizedBox(height: kCardSpacing),
                  CustomTextFormField(
                    labelText: 'Ciudad',
                    controller: _cityController,
                    validator: _validateNonEmpty,
                  ),

                  const SizedBox(height: kSectionSpacing),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿Ya tenés una cuenta?'),
                      TextButton(
                        onPressed: () => context.goNamed(LoginScreen.name),
                        child: const Text('Iniciá sesión'),
                      ),
                    ],
                  ),
                  const SizedBox(height: kItemSpacing),

                  if (authState is AuthLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    AppButton.primary(
                      text: 'Crear cuenta',
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          ref
                              .read(authProvider.notifier)
                              .register(
                                name: _nameController.text,
                                email: _emailController.text,
                                password: _passwordController.text,
                                phone: _phoneController.text,
                                bloodType: _selectedBloodType!,
                                city: _cityController.text,
                              );
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
