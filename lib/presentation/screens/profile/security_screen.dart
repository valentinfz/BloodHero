import 'package:flutter/material.dart';

class SecurityScreen extends StatelessWidget {
  static const String name = 'security_screen';
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seguridad')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Protegé tu cuenta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Cambiar contraseña'),
            subtitle: const Text('Actualizá tu contraseña regularmente'),
            onTap: () {
              // TODO: Cambio de contraseña
            },
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Biometría'),
            subtitle: const Text('Usá tu huella o rostro para iniciar sesión'),
            trailing: Switch(
              value: true,
              onChanged: (_) {
                // TODO: Deshabilitar biometría
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.devices),
            title: const Text('Dispositivos conectados'),
            subtitle: const Text('Gestioná dónde iniciaste sesión'),
            onTap: () {
              // TODO: Mostrar dispositivos
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Eliminar cuenta'),
            subtitle: const Text('Podés solicitar la eliminación de todos tus datos'),
            onTap: () {
              // TODO: Proceso de eliminación
            },
          ),
        ],
      ),
    );
  }
}
