import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Manages user notification and language preferences in-memory.
@immutable
class PreferenceLanguageOption {
  const PreferenceLanguageOption({
    required this.code,
    required this.label,
  });

  final String code;
  final String label;
}

const List<PreferenceLanguageOption> _languageOptions = [
  PreferenceLanguageOption(code: 'es-AR', label: 'Español (AR)'),
  PreferenceLanguageOption(code: 'en-US', label: 'English (US)'),
  PreferenceLanguageOption(code: 'pt-BR', label: 'Português (BR)'),
];

PreferenceLanguageOption languageOptionFor(String code) {
  return _languageOptions.firstWhere(
    (option) => option.code == code,
    orElse: () => _languageOptions.first,
  );
}

List<PreferenceLanguageOption> get preferenceLanguageOptions =>
    List<PreferenceLanguageOption>.unmodifiable(_languageOptions);

@immutable
class PreferencesState {
  const PreferencesState({
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.smsNotifications = false,
    this.languageCode = 'es-AR',
  });

  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;
  final String languageCode;

  String get languageLabel => languageOptionFor(languageCode).label;

  PreferencesState copyWith({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    String? languageCode,
  }) {
    return PreferencesState(
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

class PreferencesNotifier extends Notifier<PreferencesState> {
  @override
  PreferencesState build() {
    return const PreferencesState();
  }

  void updateEmailNotifications(bool value) {
    state = state.copyWith(emailNotifications: value);
  }

  void updatePushNotifications(bool value) {
    state = state.copyWith(pushNotifications: value);
  }

  void updateSmsNotifications(bool value) {
    state = state.copyWith(smsNotifications: value);
  }

  void updateLanguage(String code) {
    state = state.copyWith(languageCode: code);
  }
}

final preferencesProvider =
    NotifierProvider<PreferencesNotifier, PreferencesState>(
  PreferencesNotifier.new,
);
