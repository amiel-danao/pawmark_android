import '../models/models.dart';

abstract class AuthService {
  Future<Customer> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Customer> createUserWithEmailAndPassword({
    required String firstName,
    required String middleName,
    required String lastName,
    required String email,
    required String password,
  });
}
