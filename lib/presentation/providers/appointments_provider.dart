import 'package:bloodhero/core/utils/repository_exception.dart';
import 'package:bloodhero/presentation/providers/achievement_provider.dart'
  as achievement;
import 'package:bloodhero/presentation/providers/history_provider.dart'
  as history;
import 'package:bloodhero/presentation/providers/home_provider.dart' as home;
import 'package:bloodhero/presentation/providers/impact_provider.dart'
  as impact;
import 'package:bloodhero/presentation/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/appointment_detail_entity.dart';
import '../../domain/entities/appointment_entity.dart';

final appointmentsProvider =
    FutureProvider.autoDispose<List<AppointmentEntity>>((ref) {
      final repository = ref.watch(centersRepositoryProvider);
      return repository.getAppointments();
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
  final String centerName;
  final DateTime date;

  AvailableTimesParams({required this.centerName, required this.date});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvailableTimesParams &&
          runtimeType == other.runtimeType &&
          centerName == other.centerName &&
          date == other.date;

  @override
  int get hashCode => centerName.hashCode ^ date.hashCode;
}

// Provider.family para obtener los horarios disponibles
final availableTimesProvider = FutureProvider.autoDispose
    .family<List<String>, AvailableTimesParams>((ref, params) {
      final repository = ref.watch(centersRepositoryProvider);
      return repository.getAvailableTimes(params.centerName, params.date);
    });

// Enum para manejar los estados del proceso de agendamiento
enum BookingState { initial, loading, success, error }

// Notifier para manejar la lógica de agendar una cita
class AppointmentBookingNotifier extends Notifier<BookingState> {
  @override
  BookingState build() => BookingState.initial;

  Future<void> bookAppointment({
    required String centerName,
    required DateTime date,
    required String time,
  }) async {
    state = BookingState.loading;
    try {
      final repository = ref.read(centersRepositoryProvider);
      await repository.bookAppointment(
        centerName: centerName,
        date: date,
        time: time,
      );
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

enum AppointmentActionType { cancel, verify, reschedule }

class AppointmentActionsState {
  const AppointmentActionsState({
    this.isCancelling = false,
    this.isVerifying = false,
    this.successMessage,
    this.errorMessage,
    this.lastSuccessAction,
    this.lastErrorAction,
    this.pendingRescheduleCenter,
  });

  final bool isCancelling;
  final bool isVerifying;
  final String? successMessage;
  final String? errorMessage;
  final AppointmentActionType? lastSuccessAction;
  final AppointmentActionType? lastErrorAction;
  final String? pendingRescheduleCenter;

  static const _sentinel = Object();

  AppointmentActionsState copyWith({
    bool? isCancelling,
    bool? isVerifying,
    Object? successMessage = _sentinel,
    Object? errorMessage = _sentinel,
    Object? lastSuccessAction = _sentinel,
    Object? lastErrorAction = _sentinel,
    Object? pendingRescheduleCenter = _sentinel,
  }) {
    return AppointmentActionsState(
      isCancelling: isCancelling ?? this.isCancelling,
      isVerifying: isVerifying ?? this.isVerifying,
      successMessage: successMessage == _sentinel
          ? this.successMessage
          : successMessage as String?,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      lastSuccessAction: lastSuccessAction == _sentinel
          ? this.lastSuccessAction
          : lastSuccessAction as AppointmentActionType?,
      lastErrorAction: lastErrorAction == _sentinel
          ? this.lastErrorAction
          : lastErrorAction as AppointmentActionType?,
      pendingRescheduleCenter: pendingRescheduleCenter == _sentinel
          ? this.pendingRescheduleCenter
          : pendingRescheduleCenter as String?,
    );
  }
}

class AppointmentActionsNotifier extends Notifier<AppointmentActionsState> {
  @override
  AppointmentActionsState build() => const AppointmentActionsState();

  Future<void> _cancelAppointment({
    required String appointmentId,
    required AppointmentActionType actionType,
    required String successMessage,
    String? pendingRescheduleCenter,
  }) async {
    state = state.copyWith(
      isCancelling: true,
      successMessage: null,
      errorMessage: null,
      lastSuccessAction: null,
      lastErrorAction: null,
      pendingRescheduleCenter: pendingRescheduleCenter,
    );

    try {
      await ref
          .read(centersRepositoryProvider)
          .cancelAppointment(appointmentId);

      ref.invalidate(appointmentsProvider);
      ref.invalidate(appointmentDetailProvider(appointmentId));
      ref.invalidate(home.nextAppointmentProvider);

      state = state.copyWith(
        isCancelling: false,
        successMessage: successMessage,
        lastSuccessAction: actionType,
      );
    } on RepositoryException catch (e) {
      state = state.copyWith(
        isCancelling: false,
        errorMessage: e.message,
        lastErrorAction: actionType,
        pendingRescheduleCenter: null,
      );
    } catch (_) {
      state = state.copyWith(
        isCancelling: false,
        errorMessage: 'No pudimos cancelar tu turno. Intentá nuevamente.',
        lastErrorAction: actionType,
        pendingRescheduleCenter: null,
      );
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    await _cancelAppointment(
      appointmentId: appointmentId,
      actionType: AppointmentActionType.cancel,
      successMessage: 'Tu turno fue cancelado correctamente.',
    );
  }

  Future<void> cancelAppointmentForReschedule({
    required String appointmentId,
    required String centerName,
  }) async {
    await _cancelAppointment(
      appointmentId: appointmentId,
      actionType: AppointmentActionType.reschedule,
      successMessage: 'Turno liberado. Elegí una nueva fecha.',
      pendingRescheduleCenter: centerName,
    );
  }

  Future<void> verifyDonationCode({
    required String appointmentId,
    required String code,
  }) async {
    state = state.copyWith(
      isVerifying: true,
      successMessage: null,
      errorMessage: null,
      lastSuccessAction: null,
      lastErrorAction: null,
    );

    try {
      final verified = await ref.read(centersRepositoryProvider).verifyDonationCode(
            appointmentId: appointmentId,
            code: code,
          );

      if (!verified) {
        state = state.copyWith(
          isVerifying: false,
          errorMessage:
              'El código ingresado no coincide. Revisalo e intentá otra vez.',
          lastErrorAction: AppointmentActionType.verify,
        );
        return;
      }

      ref.invalidate(appointmentsProvider);
      ref.invalidate(appointmentDetailProvider(appointmentId));
      ref.invalidate(history.donationHistoryProvider);
      ref.invalidate(home.nextAppointmentProvider);
      ref.invalidate(home.nearbyAlertsProvider);
      ref.invalidate(home.userImpactProvider);
      ref.invalidate(impact.userImpactStatsProvider);
      ref.invalidate(achievement.achievementsProvider);

      state = state.copyWith(
        isVerifying: false,
        successMessage: '¡Gracias! Registramos tu donación.',
        lastSuccessAction: AppointmentActionType.verify,
      );
    } on RepositoryException catch (e) {
      state = state.copyWith(
        isVerifying: false,
        errorMessage: e.message,
        lastErrorAction: AppointmentActionType.verify,
      );
    } catch (_) {
      state = state.copyWith(
        isVerifying: false,
        errorMessage: 'No pudimos verificar el código. Intentá nuevamente.',
        lastErrorAction: AppointmentActionType.verify,
      );
    }
  }

  void clearMessages() {
    state = state.copyWith(
      successMessage: null,
      errorMessage: null,
      lastSuccessAction: null,
      lastErrorAction: null,
      pendingRescheduleCenter: null,
    );
  }
}

final appointmentActionsProvider = NotifierProvider.autoDispose<
    AppointmentActionsNotifier, AppointmentActionsState>(
  AppointmentActionsNotifier.new,
);
