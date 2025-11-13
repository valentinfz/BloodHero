import 'package:bloodhero/presentation/providers/home_provider.dart';
import 'package:bloodhero/presentation/providers/impact_provider.dart';
import 'package:bloodhero/presentation/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/appointment_detail_entity.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointment_repository.dart';

/// Estado para el notifier de citas.
/// [appointments] es la lista de citas obtenidas del repositorio.
/// [isLoading] indica si se está realizando una operación (cargar, cancelar, etc.).
/// [error] contiene un mensaje de error si una operación falla.
class AppointmentsState {
  final AsyncValue<List<AppointmentEntity>> appointments;
  final bool isActing; // Para acciones como cancelar/completar
  final String? actionError;

  AppointmentsState({
    this.appointments = const AsyncValue.loading(),
    this.isActing = false,
    this.actionError,
  });

  AppointmentsState copyWith({
    AsyncValue<List<AppointmentEntity>>? appointments,
    bool? isActing,
    String? actionError,
  }) {
    return AppointmentsState(
      appointments: appointments ?? this.appointments,
      isActing: isActing ?? this.isActing,
      actionError: actionError,
    );
  }
}

/// Notifier para gestionar las citas del usuario.
/// Expone métodos para cargar, cancelar y registrar el resultado de las citas,
/// interactuando con el `AppointmentRepository`.
class AppointmentsNotifier extends Notifier<AppointmentsState> {
  // Helper para obtener el repositorio
  AppointmentRepository get _repository =>
      ref.read(appointmentRepositoryProvider);

  @override
  AppointmentsState build() {
    // Estado inicial y disparo de carga asíncrona.
    Future.microtask(loadAppointments);
    return AppointmentsState();
  }

  /// Carga la lista de citas del usuario desde el repositorio.
  Future<void> loadAppointments() async {
    state = state.copyWith(appointments: const AsyncValue.loading());
    try {
      final appointments = await _repository.getAppointments();
      state = state.copyWith(appointments: AsyncValue.data(appointments));
    } catch (e, stack) {
      state = state.copyWith(appointments: AsyncValue.error(e, stack));
    }
  }

  /// Cancela una cita específica.
  Future<bool> cancelAppointment(String appointmentId) async {
    state = state.copyWith(isActing: true, actionError: null);
    try {
      await _repository.cancelAppointment(appointmentId: appointmentId);
      // Vuelve a cargar la lista de citas para reflejar el cambio de estado.
      await loadAppointments();
      ref.invalidate(nextAppointmentProvider);
      state = state.copyWith(isActing: false);
      return true; // Indica éxito
    } catch (e) {
      state = state.copyWith(
        isActing: false,
        actionError: 'Error al cancelar la cita: $e',
      );
      return false; // Indica fallo
    }
  }

  /// Registra el resultado de una donación.
  Future<bool> logDonation(
    String appointmentId, {
    required bool wasCompleted,
    String? notes,
  }) async {
    state = state.copyWith(isActing: true, actionError: null);
    try {
      await _repository.logDonation(
        appointmentId: appointmentId,
        wasCompleted: wasCompleted,
        notes: notes,
      );

      // Refrescamos los providers afectados
      await loadAppointments();
      ref.invalidate(impactProvider);
      ref.invalidate(nextAppointmentProvider);

      state = state.copyWith(isActing: false);
      return true; // Indica éxito
    } catch (e) {
      state = state.copyWith(
        isActing: false,
        actionError: 'Error al registrar la donación: $e',
      );
      return false; // Indica fallo
    }
  }
}

/// Provider que expone el `AppointmentsNotifier` a la UI.
final appointmentsProvider =
    NotifierProvider<AppointmentsNotifier, AppointmentsState>(() {
      return AppointmentsNotifier();
    });

// Provider.family para obtener los detalles de UNA cita específica por su ID
final appointmentDetailProvider = FutureProvider.autoDispose
    .family<AppointmentDetailEntity, String>((ref, appointmentId) {
      final repository = ref.watch(appointmentRepositoryProvider);
      return repository.getAppointmentDetails(appointmentId);
    });

// Clase auxiliar para pasar múltiples parámetros al provider.family
class AvailableTimesParams {
  final String centerId;
  final String centerName;
  final DateTime date;

  AvailableTimesParams({
    required this.centerId,
    required this.centerName,
    required this.date,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvailableTimesParams &&
          runtimeType == other.runtimeType &&
          centerId == other.centerId &&
          centerName == other.centerName &&
          date == other.date;

  @override
  int get hashCode => centerId.hashCode ^ centerName.hashCode ^ date.hashCode;
}

// Provider.family para obtener los horarios disponibles
final availableTimesProvider = FutureProvider.autoDispose
    .family<List<String>, AvailableTimesParams>((ref, params) {
      final repository = ref.watch(appointmentRepositoryProvider);
      return repository.getAvailableTimes(
        centerId: params.centerId,
        date: params.date,
      );
    });

// Enum para manejar los estados del proceso de agendamiento
enum BookingState { initial, loading, success, error }

// Notifier para manejar la lógica de agendar una cita
class AppointmentBookingNotifier extends Notifier<BookingState> {
  AppointmentRepository get _repository =>
      ref.read(appointmentRepositoryProvider);

  @override
  BookingState build() => BookingState.initial;

  Future<void> bookAppointment({
    required String centerId,
    required String centerName,
    required DateTime date,
    required String time,
    required String donationType,
    String? appointmentId,
  }) async {
    state = BookingState.loading;
    try {
      if (appointmentId != null) {
        // Lógica de Reprogramación
        await _repository.rescheduleAppointment(
          appointmentId: appointmentId,
          centerId: centerId,
          centerName: centerName,
          date: date,
          time: time,
          donationType: donationType,
        );
      } else {
        // Lógica de Agendado nuevo
        await _repository.bookAppointment(
          centerId: centerId,
          centerName: centerName,
          date: date,
          time: time,
          donationType: donationType,
        );
      }
      // Invalidamos providers para que se actualice la UI
      ref.invalidate(appointmentsProvider);
      ref.invalidate(nextAppointmentProvider);
      state = BookingState.success;
    } catch (e) {
      state = BookingState.error;
    }
  }

  void resetState() {
    state = BookingState.initial;
  }
}

// El NotifierProvider que la UI consumirá
final appointmentBookingProvider =
    NotifierProvider<AppointmentBookingNotifier, BookingState>(() {
      return AppointmentBookingNotifier();
    });

/// Parámetros para el provider de días ocupados.
class BookedDaysParams {
  final String centerId;
  final DateTime startDate;
  final DateTime endDate;

  BookedDaysParams({
    required this.centerId,
    required this.startDate,
    required this.endDate,
  });

  // Sobrescribimos == y hashCode para que el provider.family
  // sepa cuándo los parámetros han cambiado realmente.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookedDaysParams &&
          runtimeType == other.runtimeType &&
          centerId == other.centerId &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => centerId.hashCode ^ startDate.hashCode ^ endDate.hashCode;
}

/// Provider que obtiene los días completamente ocupados para un centro
/// en un rango de fechas específico.
/// La UI "observará" este provider. Riverpod manejará automáticamente
/// los estados de carga, error y datos.
final fullyBookedDaysProvider = FutureProvider.autoDispose
    .family<Set<DateTime>, BookedDaysParams>((ref, params) {
      // Obtiene el repositorio de citas
      final repository = ref.watch(appointmentRepositoryProvider);

      // Llama al método del repositorio con los parámetros dados
      // El provider ahora se encarga de la lógica de carga.
      return repository.getFullyBookedDays(
        centerId: params.centerId,
        startDate: params.startDate,
        endDate: params.endDate,
      );
    });
