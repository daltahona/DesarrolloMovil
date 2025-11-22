import 'package:flutter/material.dart';
import 'report_type_screen.dart';

class ReportSuccessScreen extends StatelessWidget {
  final String tipo;
  final String direccion;
  final String referencia;
  final String estado;
  final int userId; // 👈 nuevo parámetro obligatorio

  const ReportSuccessScreen({
    super.key,
    required this.tipo,
    required this.direccion,
    required this.referencia,
    required this.userId, // 👈 se debe pasar siempre
    this.estado = "En trámite", // valor por defecto
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B4C4C),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        title: const Text(
          'Reporte enviado',
          style: TextStyle(
            color: Color(0xFF1B4C4C),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 100,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '¡Tu reporte ha sido enviado con éxito!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4C4C),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9F1F1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFF1B4C4C), width: 1),
                    ),
                    child: Text(
                      'Tipo: $tipo\nDirección: $direccion\nReferencia: $referencia\nEstado: $estado',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1B4C4C),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportTypeScreen(
                            userId: userId, // 👈 pasamos el userId
                          ),
                        ),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Volver al inicio'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B4C4C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
