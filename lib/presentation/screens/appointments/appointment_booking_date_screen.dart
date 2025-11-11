import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';
import 'package:bloodhero/presentation/providers/repository_providers.dart';
import 'package:bloodhero/presentation/widgets/shared/app_button.dart';
import 'appointment_booking_time_screen.dart';

class AppointmentBookingDateScreen extends ConsumerStatefulWidget {
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
  @override
  ConsumerState<AppointmentBookingDateScreen> createState() =>
      _AppointmentBookingDateScreenState();
}

class _AppointmentBookingDateScreenState
    extends ConsumerState<AppointmentBookingDateScreen> {
  late DateTime selectedDate;
  Set<DateTime> _fullyBookedDays = <DateTime>{};
  bool _isLoadingAvailability = false;
  bool _selectedDateUnavailable = false;

  @override
  void initState() {
    super.initState();
    selectedDate = _initialSelectedDate();
    Future.microtask(_loadFullyBookedDays);
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

  DateTime _normalize(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime get _normalizedToday => _normalize(DateTime.now());

  DateTime get _lastSelectableDate {
    final limit = DateTime.now().add(const Duration(days: 60));
    return _normalize(limit);
  }

  Future<void> _loadFullyBookedDays() async {
    if (!mounted) return;
    setState(() => _isLoadingAvailability = true);
    try {
      final repository = ref.read(centersRepositoryProvider);
      final startDate = _nextValidDate(_normalizedToday);
      final endDate = _lastSelectableDate;
      final result = await repository.getFullyBookedDays(
        centerId: widget.centerId,
        startDate: startDate,
        endDate: endDate,
      );

      if (!mounted) return;
      setState(() {
        var normalizedSelected = _normalize(selectedDate);
        final blockedDays = result.toSet();
        final fallback = blockedDays.contains(normalizedSelected)
            ? _findNextAvailableDate(normalizedSelected, blockedDays)
            : null;

        if (fallback != null) {
          selectedDate = fallback;
          normalizedSelected = _normalize(selectedDate);
        }

        _selectedDateUnavailable = blockedDays.contains(normalizedSelected);
        _fullyBookedDays = blockedDays.difference({normalizedSelected});
        _isLoadingAvailability = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingAvailability = false);
    }
  }

  DateTime? _findNextAvailableDate(
    DateTime from,
    Set<DateTime> blockedDays,
  ) {
    DateTime candidate = from;
    for (var i = 0; i < 120; i++) {
      candidate = candidate.add(const Duration(days: 1));
      if (candidate.isAfter(_lastSelectableDate)) {
        break;
      }
      final normalizedCandidate = _normalize(candidate);
      if (_isSelectable(normalizedCandidate, _normalizedToday) &&
          !blockedDays.contains(normalizedCandidate)) {
        return normalizedCandidate;
      }
    }
    return null;
  }

  bool _isSelectable(DateTime date, DateTime normalizedToday) {
    if (!date.isAfter(normalizedToday)) return false;
    if (date.weekday == DateTime.sunday) return false;
    return true;
  }

  bool _selectableDayPredicate(DateTime day) {
    final normalizedDay = _normalize(day);
    if (!_isSelectable(normalizedDay, _normalizedToday)) {
      return false;
    }
    if (_fullyBookedDays.contains(normalizedDay)) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final firstDate = _nextValidDate(_normalizedToday);
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
            if (_isLoadingAvailability)
              const LinearProgressIndicator(minHeight: 2),
            const SizedBox(height: 16),
            CalendarDatePicker(
              initialDate: selectedDate,
              firstDate: firstDate,
              lastDate: _lastSelectableDate,
              selectableDayPredicate: _selectableDayPredicate,
              onDateChanged: (value) => setState(
                () => selectedDate = DateTime(value.year, value.month, value.day),
              ),
            ),
            if (_selectedDateUnavailable)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No hay horarios disponibles para la fecha seleccionada. Elegí otro día.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            const Spacer(),
            AppButton.primary(
              text: 'Continuar con ${selectedDate.day}/${selectedDate.month}',
              onPressed: _selectedDateUnavailable
                  ? null
                  : () => context.pushNamed(
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
