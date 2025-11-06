import 'package:bloodhero/data/repositories/firebase_centers_repository.dart';
import 'package:bloodhero/data/seeds/firestore_seed_service.dart';
import 'package:bloodhero/domain/entities/appointment_entity.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const userId = 'test-user';
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late FirebaseCentersRepository repository;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    final mockUser = MockUser(
      uid: userId,
      email: 'hero@example.com',
      displayName: 'Hero User',
    );
    auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    repository = FirebaseCentersRepository(
      firestore: firestore,
      auth: auth,
      codeGenerator: () => 'BH-9999',
    );

    final seedService = FirestoreSeedService(
      firestore,
      baseDate: DateTime(2025, 11, 5),
    );
    await seedService.seed(userId: userId);
  });

  test('getCenters returns seeded centers', () async {
    final centers = await repository.getCenters();
    expect(centers, isNotEmpty);
    expect(centers.first.name, equals('Hospital Central'));
  });

  test('getCenterDetails returns detailed center data', () async {
    final detail = await repository.getCenterDetails('Hospital Central');
    expect(detail.name, equals('Hospital Central'));
    expect(detail.services, isNotEmpty);
  });

  test('getAvailableTimes reads Firestore slots', () async {
    final times = await repository.getAvailableTimes(
      'Hospital Central',
      DateTime(2025, 11, 7),
    );
    expect(times, contains('10:30'));
  });

  test('getAppointments returns sorted appointments', () async {
    final appointments = await repository.getAppointments();
    expect(appointments.length, equals(2));
    expect(
      appointments.first.scheduledAt.isBefore(appointments.last.scheduledAt),
      isTrue,
    );
  });

  test('getAppointmentDetails retrieves Firestore document', () async {
    final detail = await repository.getAppointmentDetails('apt-001');
    expect(detail.donationType, equals('Sangre total'));
    expect(detail.verificationCompleted, isFalse);
  });

  test('cancelAppointment updates status in Firestore', () async {
    await repository.cancelAppointment('apt-001');
    final detail = await repository.getAppointmentDetails('apt-001');
    expect(detail.status, equals(AppointmentStatus.cancelled));
  });

  test('verifyDonationCode completes appointment and updates history', () async {
    final docBefore = await firestore
        .collection('users')
        .doc(userId)
        .collection('appointments')
        .doc('apt-001')
        .get();
    expect(docBefore.exists, isTrue);
    expect(docBefore.data()?['verificationCode'], equals('BH-4312'));
    expect(docBefore.data()?['verificationCompleted'], isFalse);
  expect(docBefore.data()?['verificationCode'], isA<String>());

    final result = await repository.verifyDonationCode(
      appointmentId: 'apt-001',
      code: 'BH-4312',
    );
    expect(result, isTrue);

    final detail = await repository.getAppointmentDetails('apt-001');
    expect(detail.verificationCompleted, isTrue);

    final history = await repository.getDonationHistory();
    expect(history.any((item) => item.id == 'apt-001'), isTrue);
  });

  test('verifyDonationCode returns false for invalid code', () async {
    final result = await repository.verifyDonationCode(
      appointmentId: 'apt-001',
      code: 'WRONG',
    );
    expect(result, isFalse);
  });

  test('bookAppointment creates new appointment in Firestore', () async {
    await repository.bookAppointment(
      centerName: 'Hospital Central',
      date: DateTime(2025, 11, 10),
      time: '09:45',
    );

    final appointments = await repository.getAppointments();
    expect(appointments.length, equals(3));
    expect(
      appointments.any(
        (apt) =>
            apt.centerName == 'Hospital Central' &&
            apt.scheduledAt.year == 2025 &&
            apt.scheduledAt.month == 11 &&
            apt.scheduledAt.day == 10 &&
            apt.scheduledAt.hour == 9 &&
            apt.scheduledAt.minute == 45,
      ),
      isTrue,
    );
  });

  test('getNextAppointment returns upcoming appointment', () async {
    final next = await repository.getNextAppointment();
    expect(next.centerName, equals('Hospital Central'));
  });

  test('getNearbyAlerts returns seeded alerts', () async {
    final alerts = await repository.getNearbyAlerts();
    expect(alerts, isNotEmpty);
    expect(alerts.first.bloodType, equals('O-'));
  });

  test('getUserProfile reads Firestore profile', () async {
    final profile = await repository.getUserProfile();
    expect(profile.name, equals('Hero User'));
    expect(profile.city, equals('Buenos Aires'));
  });

  test('getDonationTips returns ordered tips', () async {
    final tips = await repository.getDonationTips();
    expect(tips.first, contains('hidratarte'));
  });

  test('getUserImpactStats returns Firestore values', () async {
    final stats = await repository.getUserImpactStats();
    expect(stats.livesHelped, equals(12));
    expect(stats.totalDonations, equals(3));
  });

  test('getAchievements returns seed data', () async {
    final achievements = await repository.getAchievements();
    expect(achievements.length, equals(3));
  });

  test('getAchievementDetails returns matching document', () async {
    final detail = await repository.getAchievementDetails('Primera Donación');
    expect(detail.description, contains('primer paso'));
  });

  test('getAlertDetails returns seeded alert info', () async {
    final detail = await repository.getAlertDetails('Hospital Central');
    expect(detail.bloodType, equals('O-'));
    expect(detail.quantityNeeded, equals('5 donaciones'));
  });

  test('getDonationHistory returns seeded history', () async {
    final history = await repository.getDonationHistory();
    expect(history.length, equals(2));
    expect(history.first.wasCompleted, isTrue);
  });
}
