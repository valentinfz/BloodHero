import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';
import 'package:bloodhero/presentation/widgets/shared/app_button.dart';
import 'appointment_booking_time_screen.dart';

class AppointmentBookingDateScreen extends StatefulWidget {
  static const String name = 'appointment_booking_date_screen';
  final String centerId;
  final String centerName;
  final String? appointmentId;
  final String? donationType;
  final DateTime? initialScheduledDate;
  final String? initialTime;

  const AppointmentBookingDateScreen({
    super.key,
    required this.centerId,
    required this.centerName,
    this.appointmentId,
    this.donationType,
    this.initialScheduledDate,
    this.initialTime,
  });

  @override
  State<AppointmentBookingDateScreen> createState() =>
      _AppointmentBookingDateScreenState();
}

class _AppointmentBookingDateScreenState
    extends State<AppointmentBookingDateScreen> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = _initialSelectedDate();
  }

  DateTime _initialSelectedDate() {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final candidate = widget.initialScheduledDate;
    if (candidate != null) {
      final normalizedCandidate =
          DateTime(candidate.year, candidate.month, candidate.day);
      if (_isSelectable(normalizedCandidate, normalizedToday)) {
        return normalizedCandidate;
      }
    }
    return _nextValidDate(normalizedToday);
  }

  DateTime _nextValidDate(DateTime from) {
    DateTime next = from.add(const Duration(days: 1));
    while (next.weekday == DateTime.sunday) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }

  bool _isSelectable(DateTime date, DateTime normalizedToday) {
    if (!date.isAfter(normalizedToday)) return false;
    if (date.weekday == DateTime.sunday) return false;
    return true;
  }

  bool _selectableDayPredicate(DateTime day) {
    final normalizedToday =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _isSelectable(normalizedDay, normalizedToday);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final firstDate = _nextValidDate(normalizedToday);
    return Scaffold(
      appBar: AppBar(title: const Text('Agendar donación · Fecha')),
      body: Padding(
        padding: kScreenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Centro: ${widget.centerName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CalendarDatePicker(
              initialDate: selectedDate,
              firstDate: firstDate,
              lastDate: DateTime.now().add(const Duration(days: 60)),
              selectableDayPredicate: _selectableDayPredicate,
              onDateChanged: (value) => setState(
                () => selectedDate = DateTime(value.year, value.month, value.day),
              ),
            ),
            const Spacer(),
            AppButton.primary(
              text: 'Continuar con ${selectedDate.day}/${selectedDate.month}',
              onPressed: () => context.pushNamed(
                AppointmentBookingTimeScreen.name,
                extra: {
                  'centerId': widget.centerId,
                  'center': widget.centerName,
                  'date': selectedDate,
                  'appointmentId': widget.appointmentId,
                  'donationType': widget.donationType,
                  'initialTime': widget.initialTime,
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
