import 'package:bloodhero/data/repositories/fake_centers_repository.dart';
import 'package:bloodhero/domain/entities/appointment_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repository = FakeCentersRepository();

  setUp(() {
    repository.resetForTesting();
  });

  test('booking and cancelling an appointment updates the history', () async {
    final initialAppointments = await repository.getAppointments();
    final initialCount = initialAppointments.length;

    final date = DateTime.now().add(const Duration(days: 5));
    await repository.bookAppointment(
      centerName: 'Hospital de Clínicas (UBA)',
      date: date,
      time: '10:30',
    );

    final updatedAppointments = await repository.getAppointments();
    expect(updatedAppointments.length, initialCount + 1);

  final AppointmentEntity newAppointment = updatedAppointments.firstWhere(
    (appt) =>
      appt.centerName == 'Hospital de Clínicas (UBA)' &&
      appt.scheduledAt.year == date.year &&
      appt.scheduledAt.month == date.month &&
      appt.scheduledAt.day == date.day &&
      appt.scheduledAt.hour == 10 &&
      appt.scheduledAt.minute == 30,
  );

    await repository.cancelAppointment(newAppointment.id);

    final history = await repository.getDonationHistory();
    final cancelled = history.firstWhere((item) => item.id == newAppointment.id);
    expect(cancelled.status, AppointmentStatus.cancelled);
  });

  test('verifying a donation code only affects totals once', () async {
    final impactBefore = await repository.getUserImpactStats();
    expect(impactBefore.totalDonations, greaterThanOrEqualTo(1));

    final firstTry = await repository.verifyDonationCode(
      appointmentId: 'apt-001',
      code: 'BH-4312',
    );
    expect(firstTry, isTrue);

    final details = await repository.getAppointmentDetails('apt-001');
    expect(details.verificationCompleted, isTrue);
    expect(details.pointsAwarded, greaterThan(0));

    final secondTry = await repository.verifyDonationCode(
      appointmentId: 'apt-001',
      code: 'BH-4312',
    );
    expect(secondTry, isTrue, reason: 'El código ya estaba registrado.');

    final impactAfter = await repository.getUserImpactStats();
    expect(impactAfter.totalDonations, impactBefore.totalDonations + 1);
  });
}
