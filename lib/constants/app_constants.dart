import '../providers/auth_provider.dart';

class AppConstants {
  static const appTitle = "PawMark";
  static const loginTitle = "PawMark - Login";
  static const chatListTitle = "PawMark - Veterinarians";
  static const profileTitle = "Profile";
  static const fullPhotoTitle = "Full Photo";
  static const petsPageTitle = "My Pets";
  static const petProfileTitle = "Edit Pet";
}

typedef AuthStateCallback = void Function(Status status);
typedef IsEmailVerifiedCallback = void Function(bool isVerified);
typedef NotitificationReceivedAttachedCallback = void Function();
