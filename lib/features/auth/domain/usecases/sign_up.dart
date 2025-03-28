import '../repositories/auth_repository.dart';

class SignUp {
  final AuthRepository repository;

  SignUp(this.repository);

  Future<void> call(String email, String password) async {
    await repository.signUpWithEmailAndPassword(email, password);
  }
} 