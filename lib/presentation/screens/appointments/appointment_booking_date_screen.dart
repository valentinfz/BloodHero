import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';
// Eliminamos la importación directa al repositorio
// import 'package:bloodhero/presentation/providers/repository_providers.dart';
import 'package:bloodhero/presentation/widgets/shared/app_button.dart';
import 'appointment_booking_time_screen.dart';
// Importamos el provider que tiene la clase BookedDaysParams
import 'package:bloodhero/presentation/providers/appointments_provider.dart';

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
  ConsumerState<AppointmentBookingDateScreen> createState() =>
      _AppointmentBookingDateScreenState();
}

class _AppointmentBookingDateScreenState
    extends ConsumerState<AppointmentBookingDateScreen> {
  late DateTime selectedDate;

  // --- ELIMINADO ---
  // Set<DateTime> _fullyBookedDays = <DateTime>{};
  // bool _isLoadingAvailability = false;
  // bool _selectedDateUnavailable = false;
  // La lógica de carga y estado ahora la maneja el provider.

  @override
  void initState() {
    super.initState();
    selectedDate = _initialSelectedDate();
    // --- ELIMINADO ---
    // Ya no llamamos a _loadFullyBookedDays() aquí.
    // El provider se cargará automáticamente en el 'build'.
  }

  // --- CUERPO RESTAURADO ---
  DateTime _initialSelectedDate() {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final candidate = widget.initialScheduledDate;
    if (candidate != null) {
      final normalizedCandidate = DateTime(
        candidate.year,
        candidate.month,
        candidate.day,
      );
      if (_isSelectable(normalizedCandidate, normalizedToday)) {
        return normalizedCandidate;
      }
    }
    return _nextValidDate(normalizedToday);
  }

  // --- CUERPO RESTAURADO ---
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

  // --- CUERPO RESTAURADO ---
  DateTime get _lastSelectableDate {
    final limit = DateTime.now().add(const Duration(days: 60));
    return _normalize(limit);
  }

  // --- MODIFICADO ---
  // Este predicado ahora recibe los días ocupados como parámetro
  bool _selectableDayPredicate(DateTime day, Set<DateTime> fullyBookedDays) {
    final normalizedDay = _normalize(day);
    if (!_isSelectable(normalizedDay, _normalizedToday)) {
      return false;
    }
    if (fullyBookedDays.contains(normalizedDay)) {
      return false;
    }
    return true;
  }

  // Helper para verificar si un día es seleccionable (lógica base)
  bool _isSelectable(DateTime date, DateTime normalizedToday) {
    if (!date.isAfter(normalizedToday)) return false;
    if (date.weekday == DateTime.sunday) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final firstDate = _nextValidDate(_normalizedToday);

    final bookedDaysParams = BookedDaysParams(
      centerId: widget.centerId,
      startDate: firstDate,
      endDate: _lastSelectableDate,
    );
    final bookedDaysAsync = ref.watch(
      fullyBookedDaysProvider(bookedDaysParams),
    );

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

            // Usamos .when para reaccionar al estado del provider
            bookedDaysAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: LinearProgressIndicator(minHeight: 2),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Error al cargar días disponibles: $error',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              data: (fullyBookedDays) {
                // Una vez cargados los datos, verificamos si la fecha
                // seleccionada actualmente sigue siendo válida.
                final bool selectedDateIsBooked = fullyBookedDays.contains(
                  _normalize(selectedDate),
                );

                // Si la fecha seleccionada está ocupada Y NO es la fecha
                // que venía de una reprogramación, busca la próxima disponible.
                if (selectedDateIsBooked &&
                    _normalize(widget.initialScheduledDate ?? DateTime(0)) !=
                        _normalize(selectedDate)) {
                  DateTime nextAvailable = _nextValidDate(selectedDate);
                  while (fullyBookedDays.contains(nextAvailable) ||
                      !_isSelectable(nextAvailable, _normalizedToday)) {
                    nextAvailable = nextAvailable.add(const Duration(days: 1));
                    // Si nos pasamos del límite, paramos
                    if (nextAvailable.isAfter(_lastSelectableDate)) {
                      nextAvailable =
                          selectedDate; // Dejamos la seleccionada original
                      break;
                    }
                  }

                  // Actualizamos 'selectedDate' en el próximo frame
                  // Usamos microtask para evitar un setState durante el build
                  Future.microtask(() {
                    if (mounted) {
                      setState(() {
                        selectedDate = nextAvailable;
                      });
                    }
                  });
                }

                // Volvemos a chequear si la fecha (potencialmente nueva) está ocupada
                final bool isDateUnavailable = fullyBookedDays.contains(
                  _normalize(selectedDate),
                );

                return Column(
                  children: [
                    CalendarDatePicker(
                      initialDate: selectedDate,
                      firstDate: firstDate,
                      lastDate: _lastSelectableDate,
                      // Pasamos los días ocupados al predicado
                      selectableDayPredicate: (day) =>
                          _selectableDayPredicate(day, fullyBookedDays),
                      onDateChanged: (value) => setState(
                        () => selectedDate = DateTime(
                          value.year,
                          value.month,
                          value.day,
                        ),
                      ),
                    ),
                    if (isDateUnavailable)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No hay horarios disponibles para la fecha seleccionada. Elegí otro día.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

            const Spacer(),

            // El botón de continuar se activa/desactiva
            // según el estado de carga del provider
            AppButton.primary(
              text: 'Continuar con ${selectedDate.day}/${selectedDate.month}',
              // Deshabilitado si carga o si (ya cargó y) el día está ocupado
              onPressed:
                  bookedDaysAsync.isLoading ||
                      (bookedDaysAsync.hasValue &&
                          bookedDaysAsync.value!.contains(
                            _normalize(selectedDate),
                          ))
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
