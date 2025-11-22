import 'dart:io';
import 'package:flutter/material.dart';
import '../models/report_model.dart';
import 'report_form_screen.dart';

class ReportDetailScreen extends StatelessWidget {
  final Report reporte;

  const ReportDetailScreen({super.key, required this.reporte});

  @override
  Widget build(BuildContext context) {
    final titleStyle = const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Color(0xFF1B4C4C),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF1B4C4C),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        title: const Text(
          "Detalle del reporte",
          style: TextStyle(
            color: Color(0xFF1B4C4C),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF1B4C4C)),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportFormScreen(
                    type: reporte.tipo,
                    existingData: reporte.toMap(),
                  ),
                ),
              );
              if (!context.mounted) return;
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (reporte.foto_path != null &&
                      reporte.foto_path!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(reporte.foto_path!),
                        height: 280,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      height: 180,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text("Información del reporte", style: titleStyle),
                  const Divider(thickness: 1.2),
                  const SizedBox(height: 12),
                  _Item(label: 'Tipo', value: reporte.tipo),
                  _Item(label: 'Dirección', value: reporte.direccion),
                  _Item(label: 'Referencia', value: reporte.referencia),
                  _Item(label: 'Fecha', value: reporte.fecha ?? 'Sin fecha'),
                  _Item(label: 'Estado', value: reporte.estado),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String label;
  final String value;

  const _Item({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F1F1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF1B4C4C), width: 1),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B4C4C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
