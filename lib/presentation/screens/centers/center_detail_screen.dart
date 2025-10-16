import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/presentation/screens/appointments/appointment_booking_date_screen.dart';
import 'package:bloodhero/presentation/screens/centers/center_reviews_screen.dart';

class CenterDetailScreen extends StatelessWidget {
  static const String name = 'center_detail_screen';
  final String? centerName;

  const CenterDetailScreen({super.key, this.centerName});

  @override
  Widget build(BuildContext context) {
    final title = centerName ?? 'Centro de donación';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.reviews_outlined),
            onPressed: () => context.pushNamed(CenterReviewsScreen.name, extra: title),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 180,
                color: Colors.grey[300],
                child: const Center(child: Text('Imagen del centro')),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: const [
                Icon(Icons.location_on_outlined, color: Color(0xFFC62828)),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Av. Principal 123, Ciudad Autónoma de Buenos Aires'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Icon(Icons.schedule_outlined, color: Color(0xFFC62828)),
                SizedBox(width: 8),
                Expanded(child: Text('Lun a Vie 8:00 - 18:00 · Sáb 9:00 - 13:00')),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Servicios disponibles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const _BulletItem('Extracción de sangre y plasma'),
            const _BulletItem('Estacionamiento sin cargo'),
            const _BulletItem('Atención priorizada para donadores frecuentes'),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.pushNamed(AppointmentBookingDateScreen.name, extra: title),
              icon: const Icon(Icons.calendar_month),
              label: const Text('Agendar donación'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  const _BulletItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 20, color: Color(0xFFC62828))),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
