import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // para guardar credenciales
import '../core/database/bd_dm.dart';
import 'register_screen.dart';
import 'recover_password_screen.dart'; // nueva pantalla de recuperación

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  String? _errorMessage;
  bool _rememberMe = false; // checkbox

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUser = prefs.getString('saved_user');
    final savedPass = prefs.getString('saved_pass');
    final remember = prefs.getBool('remember_me') ?? false;

    if (remember && savedUser != null && savedPass != null) {
      setState(() {
        _userController.text = savedUser;
        _passController.text = savedPass;
        _rememberMe = true;
      });
    }
  }

  Future<void> _login() async {
    final user = _userController.text.trim();
    final pass = _passController.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      setState(() => _errorMessage = "Usuario y contraseña requeridos");
      return;
    }

    final db = BbDM();
    final userData = await db.obtenerUsuario(user, pass);

    if (userData != null) {
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('saved_user', user);
        await prefs.setString('saved_pass', pass);
        await prefs.setBool('remember_me', true);
      } else {
        await prefs.remove('saved_user');
        await prefs.remove('saved_pass');
        await prefs.setBool('remember_me', false);
      }

      final int userId = userData['id']; //  obtenemos el id del usuario
      final String userRole = userData['role']; //  obtenemos el rol del usuario

      if (userRole == 'admin') {
        Navigator.pushReplacementNamed(
          context,
          '/reportList',
          arguments: {'userId': userId, 'userRole': userRole},
        );
      } else {
        Navigator.pushReplacementNamed(
          context,
          '/reportType',
          arguments: {'userId': userId},
        );
      }
    } else {
      setState(() => _errorMessage = "Credenciales inválidas");
    }
  }

  @override
  Widget build(BuildContext context) {
    final linkStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Color(0xFF1B4C4C),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF1B4C4C),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock, size: 60, color: Color(0xFF1B4C4C)),
                    const SizedBox(height: 16),
                    const Text(
                      "Inicio de sesión",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4C4C),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _userController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person),
                        labelText: "Usuario",
                        hintText: "Ej: user, juan, carlos",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        labelText: "Contraseña",
                        hintText: "Ej: Abcde1234",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                        ),
                        Text("Recordar usuario y contraseña", style: linkStyle),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _login,
                        icon: const Icon(Icons.login),
                        label: const Text("Ingresar"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B4C4C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text("Crear nuevo usuario", style: linkStyle),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RecoverPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "¿Olvidaste tu contraseña?",
                        style: linkStyle,
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
