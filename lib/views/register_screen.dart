import 'package:flutter/material.dart';
import '../core/database/bd_dm.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  //  Rol fijo en "user"
  final String _role = "user";
  String? _message;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final username = _userController.text.trim();
      final password = _passController.text.trim();

      try {
        await BbDM().agregarUsuario(username, password, _role);
        setState(() {
          _message = "Usuario creado correctamente ✅";
        });
      } catch (e) {
        setState(() {
          _message = "Error: el usuario ya existe o hubo un problema";
        });
      }
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
      backgroundColor: const Color(0xFF1B4C4C), // fondo suave
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
                    const Icon(
                      Icons.person_add,
                      size: 60,
                      color: Color(0xFF1B4C4C),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Registrar nuevo usuario",
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
                        hintText: "Ej: Juan1234",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? "Campo requerido"
                          : null,
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
                      validator: (value) => value == null || value.length < 8
                          ? "Mínimo 8 caracteres"
                          : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _register,
                        icon: const Icon(Icons.check),
                        label: const Text("Crear usuario"),
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
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Volver al inicio de sesión",
                        style: linkStyle,
                      ),
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _message!,
                        style: TextStyle(
                          color: _message!.contains("Error")
                              ? Colors.red
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
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
