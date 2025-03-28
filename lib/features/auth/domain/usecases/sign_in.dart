import '../repositories/auth_repository.dart';

class SignIn {
  final AuthRepository repository;

  SignIn(this.repository);

  Future<void> call(String email, String password) async {
    await repository.signInWithEmailAndPassword(email, password);
  }
} 