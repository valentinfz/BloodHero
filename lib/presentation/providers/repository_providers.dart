import 'package:bloodhero/data/repositories/firebase_auth_repository.dart';
import 'package:bloodhero/data/repositories/firebase_centers_repository.dart';
import 'package:bloodhero/domain/repositories/auth_repository.dart';
import 'package:bloodhero/domain/repositories/centers_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // return FakeAuthRepository(); //Fake
  return FirebaseAuthRepository(); //FireBase
});

final centersRepositoryProvider = Provider<CentersRepository>((ref) {
  return FirebaseCentersRepository();
});
