import 'dart:io';
import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../viewmodels/report_list_viewmodel.dart';
import 'report_form_screen.dart';
import 'report_detail_screen.dart';
import 'login_screen.dart';

class ReportListScreen extends StatefulWidget {
  final int userId;
  final String userRole; // 'admin' o 'user'

  const ReportListScreen({
    super.key,
    required this.userId,
    required this.userRole,
  });

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  final vm = ReportListViewModel();
  late Future<List<Report>> _reportes;

  @override
  void initState() {
    super.initState();
    if (widget.userRole == 'admin') {
      _reportes = vm.obtenerTodosLosReportes();
    } else {
      _reportes = vm.obtenerReportesPorUsuario(widget.userId);
    }
  }

  Future<void> _eliminarReporte(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Eliminar reporte'),
          content: const Text('¿Deseas eliminar este reporte?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await vm.eliminarReporte(id);
      setState(() {
        if (widget.userRole == 'admin') {
          _reportes = vm.obtenerTodosLosReportes();
        } else {
          _reportes = vm.obtenerReportesPorUsuario(widget.userId);
        }
      });
    }
  }

  Future<void> _cambiarEstado(int id, String nuevoEstado) async {
    await vm.actualizarEstado(id, nuevoEstado);
    setState(() {
      if (widget.userRole == 'admin') {
        _reportes = vm.obtenerTodosLosReportes();
      } else {
        _reportes = vm.obtenerReportesPorUsuario(widget.userId);
      }
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        title: const Text(
          'Reportes enviados',
          style: TextStyle(
            color: Color(0xFF1B4C4C),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF1B4C4C)),
            tooltip: "Cerrar sesión",
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text('Cerrar sesión'),
                    content: const Text(
                      '¿Estás seguro de querer cerrar sesión?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text('Sí'),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Report>>(
        future: _reportes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final reportes = snapshot.data ?? [];
          if (reportes.isEmpty) {
            return const Center(
              child: Text(
                "No hay reportes.",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reportes.length,
            itemBuilder: (context, index) {
              final r = reportes[index];
              return Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportDetailScreen(
                            reporte: r,
                            userId: widget.userId,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Imagen + Título + datos principales
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            r.foto_path != null && r.foto_path!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(r.foto_path!),
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(
                                    Icons.image,
                                    size: 70,
                                    color: Color(0xFF1B4C4C),
                                  ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.tipo, style: linkStyle),
                                  const SizedBox(height: 4),
                                  Text(
                                    r.direccion,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(r.referencia),
                                  if (widget.userRole == 'admin' &&
                                      r.userName != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        "Usuario: ${r.userName}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF1B4C4C),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Estado
                        Row(
                          children: [
                            const Text(
                              "Estado:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            DropdownButton<String>(
                              value: r.estado,
                              items: const [
                                DropdownMenuItem(
                                  value: "En trámite",
                                  child: Text("En trámite"),
                                ),
                                DropdownMenuItem(
                                  value: "Procesado",
                                  child: Text("Procesado"),
                                ),
                              ],
                              onChanged: (nuevoEstado) {
                                if (nuevoEstado != null && r.id != null) {
                                  _cambiarEstado(r.id!, nuevoEstado);
                                }
                              },
                            ),
                          ],
                        ),

                        const Divider(height: 20, thickness: 1),

                        // Acciones
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                final updated = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReportFormScreen(
                                      type: r.tipo,
                                      existingData: r.toMap(),
                                      userId: widget.userId,
                                    ),
                                  ),
                                );
                                if (updated == true) {
                                  setState(() {
                                    if (widget.userRole == 'admin') {
                                      _reportes = vm.obtenerTodosLosReportes();
                                    } else {
                                      _reportes = vm.obtenerReportesPorUsuario(
                                        widget.userId,
                                      );
                                    }
                                  });
                                }
                              },
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text("Editar"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B4C4C),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (r.id != null) _eliminarReporte(r.id!);
                              },
                              icon: const Icon(Icons.delete, size: 18),
                              label: const Text("Eliminar"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFFB71C1C),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(
                                    color: Color(0xFFB71C1C),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: widget.userRole == 'admin'
          ? null //  no mostrar nada para admin
          : FloatingActionButton.extended(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1B4C4C),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo reporte'),
              onPressed: () async {
                final created = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportFormScreen(
                      userId: widget.userId,
                      type: 'General',
                    ),
                  ),
                );
                if (created == true) {
                  setState(() {
                    _reportes = vm.obtenerReportesPorUsuario(widget.userId);
                  });
                }
              },
            ),
    );
  }
}
