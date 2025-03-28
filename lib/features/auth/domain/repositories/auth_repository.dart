import '../entities/user.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  Future<User?> signInWithEmailAndPassword(String email, String password);
  Future<User?> signUpWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<User?> getCurrentUser();
} 