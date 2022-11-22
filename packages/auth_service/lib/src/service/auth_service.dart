import '../models/models.dart';

abstract class AuthService {
  Future<Customer> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Customer> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });
}
