import 'package:bloodhero/presentation/providers/home_provider.dart';
import 'package:bloodhero/presentation/providers/impact_provider.dart';
import 'package:bloodhero/presentation/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/appointment_detail_entity.dart';
import '../../domain/entities/appointment_entity.dart';

/// Estado para el notifier de citas.
///
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
///
/// Expone métodos para cargar, cancelar y registrar el resultado de las citas,
/// interactuando con el `CentersRepository`.
class AppointmentsNotifier extends Notifier<AppointmentsState> {
  @override
  AppointmentsState build() {
    // Estado inicial y disparo de carga asíncrona.
    // No podemos hacer await aquí, así que lanzamos la carga en microtask.
    Future.microtask(loadAppointments);
    return AppointmentsState();
  }

  /// Carga la lista de citas del usuario desde el repositorio.
  Future<void> loadAppointments() async {
    // Pone el estado en 'cargando'.
    state = state.copyWith(appointments: const AsyncValue.loading());

    try {
      // Obtiene el repositorio desde el provider.
  final repository = ref.read(centersRepositoryProvider);
      // Llama al método del repositorio para obtener las citas.
      final appointments = await repository.getAppointments();
      // Actualiza el estado con las citas obtenidas.
      state = state.copyWith(appointments: AsyncValue.data(appointments));
    } catch (e, stack) {
      // En caso de error, actualiza el estado con el error.
      state = state.copyWith(appointments: AsyncValue.error(e, stack));
    }
  }

  /// Cancela una cita específica.
  ///
  /// [appointmentId] es el ID de la cita a cancelar.
  Future<bool> cancelAppointment(String appointmentId) async {
    state = state.copyWith(isActing: true, actionError: null);
    try {
  final repository = ref.read(centersRepositoryProvider);
      // Llama al método del repositorio para cancelar la cita.
      await repository.cancelAppointment(appointmentId: appointmentId);
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
  ///
  /// [appointmentId] es el ID de la cita.
  /// [wasCompleted] indica si la donación se realizó con éxito.
  /// [notes] son notas opcionales sobre la donación.
  /// Devuelve `true` si la operación fue exitosa.
  Future<bool> logDonation(
    String appointmentId, {
    required bool wasCompleted,
    String? notes,
  }) async {
    state = state.copyWith(isActing: true, actionError: null);
    try {
  final repository = ref.read(centersRepositoryProvider);
      // Llama al método del repositorio para registrar el resultado.
      await repository.logDonation(
        appointmentId: appointmentId,
        wasCompleted: wasCompleted,
        notes: notes,
      );

      // --- COMENTARIO: Refrescar ambos notifiers ---
      // Después de registrar una donación, se refrescan tanto la lista de
      // citas (para que la cita completada cambie de estado) como las
      // estadísticas de impacto (para que el contador de donaciones aumente).
      await loadAppointments();
  ref.read(impactProvider.notifier).loadImpactStats();
      ref.invalidate(nextAppointmentProvider);
      // --- FIN DEL COMENTARIO ---

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
///
/// La UI observará este provider para reaccionar a los cambios de estado
/// (lista de citas, carga, errores) y llamará a sus métodos para
/// ejecutar acciones.
final appointmentsProvider =
    NotifierProvider<AppointmentsNotifier, AppointmentsState>(() {
  return AppointmentsNotifier();
});

// Provider.family para obtener los detalles de UNA cita específica por su ID
final appointmentDetailProvider = FutureProvider.autoDispose
    .family<AppointmentDetailEntity, String>((ref, appointmentId) {
      final repository = ref.watch(centersRepositoryProvider);
      return repository.getAppointmentDetails(appointmentId);
    });

//PROVIDERS PARA EL FLUJO DE AGENDAR CITA:

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
      final repository = ref.watch(centersRepositoryProvider);
      return repository.getAvailableTimes(
        centerId: params.centerId,
        date: params.date,
      );
    });

// Enum para manejar los estados del proceso de agendamiento
enum BookingState { initial, loading, success, error }

// Notifier para manejar la lógica de agendar una cita
class AppointmentBookingNotifier extends Notifier<BookingState> {
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
      final repository = ref.read(centersRepositoryProvider);
      if (appointmentId != null) {
        await repository.rescheduleAppointment(
          appointmentId: appointmentId,
          centerId: centerId,
          centerName: centerName,
          date: date,
          time: time,
          donationType: donationType,
        );
      } else {
        await repository.bookAppointment(
          centerId: centerId,
          centerName: centerName,
          date: date,
          time: time,
          donationType: donationType,
        );
      }
      await ref.read(appointmentsProvider.notifier).loadAppointments();
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