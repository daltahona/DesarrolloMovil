import 'dart:math';
import 'package:bcrypt/bcrypt.dart';

/// Genera un hash seguro con bcrypt
String hashPassword(String password) {
  return BCrypt.hashpw(password, BCrypt.gensalt());
}

/// Verifica si la contraseña ingresada coincide con el hash almacenado
bool verifyPassword(String password, String hashed) {
  return BCrypt.checkpw(password, hashed);
}

/// Genera una contraseña temporal aleatoria segura
String generateTemporaryPassword({int length = 10}) {
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#\$%&';
  final rand = Random.secure();
  return List.generate(
    length,
    (index) => chars[rand.nextInt(chars.length)],
  ).join();
}

/// Valida la fortaleza de una contraseña (mínimo 8 caracteres, mayúscula, minúscula, número)
bool isStrongPassword(String password) {
  final hasUpper = password.contains(RegExp(r'[A-Z]'));
  final hasLower = password.contains(RegExp(r'[a-z]'));
  final hasDigit = password.contains(RegExp(r'[0-9]'));
  final hasMinLength = password.length >= 8;
  return hasUpper && hasLower && hasDigit && hasMinLength;
}
