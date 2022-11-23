import 'package:auth_service/src/models/models.dart';
import 'package:auth_service/src/service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({
    required auth.FirebaseAuth authService,
  }) : _firebaseAuth = authService;

  final auth.FirebaseAuth _firebaseAuth;

  Customer _mapFirebaseUser(
      auth.User? user, String firstName, String middleName, String lastName) {
    if (user == null) {
      return Customer.empty();
    }

    final map = <String, dynamic>{
      'id': user.uid,
      'firstname': firstName,
      'middlename': middleName,
      'lastname': lastName,
      'email': user.email ?? ''
    };
    return Customer.fromJson(map);
  }

  Customer _mapFirebaseUserLogin(auth.User? user) {
    if (user == null) {
      return Customer.empty();
    }

    final map = <String, dynamic>{'id': user.uid, 'email': user.email ?? ''};
    return Customer.fromJson(map);
  }

  @override
  Future<Customer> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return _mapFirebaseUserLogin(userCredential.user!);
    } on auth.FirebaseAuthException catch (e) {
      throw _determineError(e);
    }
  }

  @override
  Future<Customer> createUserWithEmailAndPassword({
    required String firstName,
    required String middleName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return _mapFirebaseUser(
          _firebaseAuth.currentUser!, firstName, middleName, lastName);
    } on auth.FirebaseAuthException catch (e) {
      throw _determineError(e);
    }
  }

  AuthError _determineError(auth.FirebaseAuthException exception) {
    switch (exception.code) {
      case 'invalid-email':
        return AuthError.invalidEmail;
      case 'user-disabled':
        return AuthError.userDisabled;
      case 'user-not-found':
        return AuthError.userNotFound;
      case 'wrong-password':
        return AuthError.wrongPassword;
      case 'email-already-in-use':
      case 'account-exists-with-different-credential':
        return AuthError.emailAlreadyInUse;
      case 'invalid-credential':
        return AuthError.invalidCredential;
      case 'operation-not-allowed':
        return AuthError.operationNotAllowed;
      case 'weak-password':
        return AuthError.weakPassword;
      case 'ERROR_MISSING_GOOGLE_AUTH_TOKEN':
      default:
        return AuthError.error;
    }
  }
}
