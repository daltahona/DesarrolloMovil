import 'package:flutter/material.dart';
import '../core/database/bd_dm.dart';
import '../core/utils/security.dart'; // funciones de seguridad

class RecoverPasswordScreen extends StatefulWidget {
  const RecoverPasswordScreen({super.key});

  @override
  State<RecoverPasswordScreen> createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  final _userController = TextEditingController();
  final _newPassController =
      TextEditingController(); // campo para nueva contraseña
  String? _message;
  bool _showOptions = false; // mostrar opciones después de validar usuario

  Future<void> _recoverPassword() async {
    final username = _userController.text.trim();

    if (username.isEmpty) {
      setState(() => _message = "Ingresa tu usuario");
      return;
    }

    final db = BbDM();
    final userData = await db.obtenerUsuarioPorNombre(username);

    if (userData == null) {
      setState(() {
        _message = "Usuario no encontrado ❌";
        _showOptions = false;
      });
      return;
    }

    // Usuario válido → mostrar opciones de recuperación
    setState(() {
      _message =
          "Usuario válido, selecciona una opción para recuperar tu contraseña.";
      _showOptions = true;
    });
  }

  /// Generar contraseña temporal segura
  Future<void> _setTemporaryPassword() async {
    final username = _userController.text.trim();
    final db = BbDM();
    final tempPass = generateTemporaryPassword(length: 10); // security.dart

    await db.actualizarContrasena(username, tempPass);

    setState(() {
      _message = "Se generó una nueva contraseña temporal.";
      _showOptions = false;
    });

    // Mostrar contraseña temporal en un diálogo estilizado
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Contraseña temporal"),
          content: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F1F1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1B4C4C), width: 1),
            ),
            child: SelectableText(
              tempPass,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B4C4C),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }

  /// Crear nueva contraseña personalizada
  Future<void> _setNewPassword() async {
    final username = _userController.text.trim();
    final newPass = _newPassController.text.trim();

    if (newPass.isEmpty) {
      setState(() => _message = "Ingresa una nueva contraseña válida");
      return;
    }

    if (!isStrongPassword(newPass)) {
      setState(
        () => _message =
            "La contraseña debe tener al menos 8 caracteres, incluir mayúsculas, minúsculas y números.",
      );
      return;
    }

    final db = BbDM();
    await db.actualizarContrasena(username, newPass);

    setState(() {
      _message = "Tu contraseña fue actualizada correctamente ✅";
      _showOptions = false;
      _newPassController.clear();
    });
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_reset,
                    size: 60,
                    color: Color(0xFF1B4C4C),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Recuperar contraseña",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4C4C),
                    ),
                  ),
                  const SizedBox(height: 24),

                  TextField(
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
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _recoverPassword,
                      icon: const Icon(Icons.lock_open),
                      label: const Text("Validar usuario"),
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

                  if (_message != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      _message!,
                      style: TextStyle(
                        color:
                            _message!.contains("Error") ||
                                _message!.contains("no encontrado")
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],

                  if (_showOptions) ...[
                    const SizedBox(height: 20),
                    TextField(
                      controller: _newPassController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        labelText: "Nueva contraseña",
                        hintText: "Ingresa tu nueva contraseña",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _setTemporaryPassword,
                            icon: const Icon(Icons.refresh),
                            label: const Text(
                              "Contraseña temporal",
                            ), // cambio aplicado
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1B4C4C),
                              side: const BorderSide(
                                color: Color(0xFF1B4C4C),
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _setNewPassword,
                            icon: const Icon(Icons.save),
                            label: const Text("Guardar nueva"),
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
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Volver al inicio de sesión", style: linkStyle),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
