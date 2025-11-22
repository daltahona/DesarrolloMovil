import 'dart:io';
import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../viewmodels/report_list_viewmodel.dart';
import 'report_form_screen.dart'; // necesario para abrir el formulario

class UserReportScreen extends StatefulWidget {
  final int userId; //  nuevo campo obligatorio

  const UserReportScreen({super.key, required this.userId});

  @override
  State<UserReportScreen> createState() => _UserReportScreenState();
}

class _UserReportScreenState extends State<UserReportScreen> {
  final vm = ReportListViewModel();
  late Future<List<Report>> _reportes;

  @override
  void initState() {
    super.initState();
    // ahora cargamos solo los reportes del usuario logueado
    _reportes = vm.obtenerReportesPorUsuario(widget.userId);
  }

  Future<void> _refresh() async {
    final nuevosReportes = vm.obtenerReportesPorUsuario(widget.userId);
    setState(() {
      _reportes = nuevosReportes;
    });
  }

  // Función para asignar ícono según el tipo de reporte
  IconData _getIconForReportType(String tipo) {
    switch (tipo) {
      case 'Daños viales':
        return Icons.construction;
      case 'Aguas residuales':
        return Icons.water_damage;
      case 'Alumbrado público':
        return Icons.lightbulb;
      case 'Semáforos y señales de tránsito':
        return Icons.traffic;
      case 'Acumulación de basuras':
        return Icons.delete;
      default:
        return Icons.report;
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color(0xFF1B4C4C),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF1B4C4C),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        title: const Text(
          "Seguir mi reporte",
          style: TextStyle(
            color: Color(0xFF1B4C4C),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<Report>>(
        future: _reportes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No hay reportes registrados.",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          final reportes = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reportes.length,
              itemBuilder: (context, index) {
                final r = reportes[index];
                return Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ícono representativo del tipo de reporte
                            Icon(
                              _getIconForReportType(r.tipo),
                              size: 40,
                              color: const Color(0xFF1B4C4C),
                            ),
                            const SizedBox(width: 12),
                            // Imagen si existe
                            r.foto_path != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(r.foto_path!),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(r.tipo, style: titleStyle)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Dirección: ${r.direccion}",
                          style: const TextStyle(fontSize: 15),
                        ),
                        Text(
                          "Referencia: ${r.referencia}",
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9F1F1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF1B4C4C),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            "Estado: ${r.estado}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B4C4C),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (r.estado == "En trámite")
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReportFormScreen(
                                        type: r.tipo,
                                        existingData: r.toMap(),
                                        userId:
                                            widget.userId, // pasamos el userId
                                      ),
                                    ),
                                  ).then((value) {
                                    if (value == true) {
                                      _refresh();
                                    }
                                  });
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text("Editar"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1B4C4C),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              )
                            else
                              ElevatedButton.icon(
                                onPressed: null, // deshabilitado
                                icon: const Icon(Icons.lock),
                                label: const Text("Procesado"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade300,
                                  foregroundColor: Colors.grey.shade700,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
