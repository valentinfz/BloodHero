import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'citas_screen.dart';
import 'package:bloodhero/presentation/screens/home/home_screen.dart';

class AppointmentConfirmationScreen extends StatelessWidget {
  static const String name = 'appointment_confirmation_screen';
  final String center;
  final String date;
  final String time;
  final bool isReschedule;

  const AppointmentConfirmationScreen({
    super.key,
    required this.center,
    required this.date,
    required this.time,
    this.isReschedule = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE8F5E9),
                ),
                child: const Icon(Icons.check, size: 64, color: Colors.green),
              ),
              const SizedBox(height: 24),
              Text(
                isReschedule
                    ? '¡Listo! Reprogramaste tu turno'
                    : '¡Listo! Tu turno está confirmado',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '$date · $time\n$center',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                isReschedule
                    ? 'Actualizamos tu turno y vas a ver el nuevo horario en la sección "Mis Citas".'
                    : 'Te enviamos un email con la confirmación. Podés ver tus turnos en la sección "Mis Citas".',
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              FilledButton(
                onPressed: () => context.goNamed(CitasScreen.name),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: const Text('Ver mis citas'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.goNamed(HomeScreen.name),
                child: const Text('Volver al inicio'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
