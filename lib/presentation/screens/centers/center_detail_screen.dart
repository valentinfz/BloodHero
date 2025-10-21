import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/presentation/screens/appointments/appointment_booking_date_screen.dart';
//import 'package:bloodhero/presentation/screens/centers/center_reviews_screen.dart';
import 'package:bloodhero/presentation/screens/map/centers_loader.dart';
import 'package:url_launcher/url_launcher.dart';


class CenterDetailScreen extends StatelessWidget {
  static const String name = 'center_detail_screen';

  final MapCenter? center;
  final String? centerName;

  const CenterDetailScreen({
    super.key,
    this.center,
    this.centerName,
  });

  Widget _centerImage(BuildContext context) {
    const placeholder = 'assets/images/centers/placeholder.jpg';
    final src = center?.image ?? placeholder;

    final isNetwork = src.startsWith('http');
    final imageWidget = isNetwork
        ? Image.network(
            src,
            fit: BoxFit.cover,
            height: 180,
            width: double.infinity,
            errorBuilder: (_, __, ___) => Image.asset(
              placeholder,
              fit: BoxFit.cover,
              height: 180,
              width: double.infinity,
            ),
          )
        : Image.asset(
            src,
            fit: BoxFit.cover,
            height: 180,
            width: double.infinity,
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: imageWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = center?.name ?? centerName ?? 'Centro de donación';
    final address = center?.address ?? 'Av. Principal 123, Ciudad Autónoma de Buenos Aires';
    final lat = center?.lat;
    final lng = center?.lng;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
actions: [
  IconButton(
    icon: const Icon(Icons.reviews_outlined),
    tooltip: 'Ver reseñas en Google',
    onPressed: () async {
      final query = Uri.encodeComponent('$title reseñas');
      final uri = Uri.parse('https://www.google.com/search?q=$query');

            ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Abriendo reseñas en Google...'),
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 400));

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la búsqueda en Google')),
        );
      }
    },
  ),
],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _centerImage(context),

            const SizedBox(height: 20),

            Row(
              children: [
                const Icon(Icons.location_on_outlined, color: Color(0xFFC62828)),
                const SizedBox(width: 8),
                Expanded(child: Text(address)),
              ],
            ),
            const SizedBox(height: 12),

            if (lat != null && lng != null)
              Row(
                children: [
                  const Icon(Icons.map_outlined, color: Color(0xFFC62828)),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Ubicación: $lat, $lng')),
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
              onPressed: () =>
                  context.pushNamed(AppointmentBookingDateScreen.name, extra: title),
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
