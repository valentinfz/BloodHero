import 'package:bloodhero/core/utils/repository_exception.dart';
import 'package:bloodhero/presentation/providers/repository_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlertResponseState {
  const AlertResponseState({
    this.isLoading = false,
    this.successMessage,
    this.errorMessage,
  });

  final bool isLoading;
  final String? successMessage;
  final String? errorMessage;

  static const _sentinel = Object();

  AlertResponseState copyWith({
    bool? isLoading,
    Object? successMessage = _sentinel,
    Object? errorMessage = _sentinel,
  }) {
    return AlertResponseState(
      isLoading: isLoading ?? this.isLoading,
      successMessage: successMessage == _sentinel
          ? this.successMessage
          : successMessage as String?,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class AlertResponseNotifier extends Notifier<AlertResponseState> {
  @override
  AlertResponseState build() => const AlertResponseState();

  Future<void> respondToAlert({
    required String alertId,
    required String contactPhone,
    required String contactEmail,
  }) async {
    debugPrint(
      'AlertResponseNotifier: registrando ayuda para $alertId '
      '(tel: $contactPhone, email: $contactEmail).',
    );
    state = state.copyWith(
      isLoading: true,
      successMessage: null,
      errorMessage: null,
    );

    try {
      final repository = ref.read(centersRepositoryProvider);
      await repository.registerAlertResponse(alertId: alertId);
      state = state.copyWith(
        isLoading: false,
        successMessage:
            '¡Gracias por ofrecer tu ayuda! El centro se comunicará con vos pronto.',
      );
    } on RepositoryException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No pudimos registrar tu respuesta. Intentá nuevamente.',
      );
    }
  }

  void reset() {
    state = const AlertResponseState();
  }
}

final alertResponseProvider = NotifierProvider.autoDispose<
  AlertResponseNotifier, AlertResponseState>(AlertResponseNotifier.new);
