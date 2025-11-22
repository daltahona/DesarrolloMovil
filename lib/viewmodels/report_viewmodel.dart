import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import '../models/report_model.dart';
import '../core/database/bd_dm.dart';

class ReportViewModel {
  final BbDM db = BbDM();

  // Canal nativo para guardar imágenes en la galería
  static const platform = MethodChannel(
    'com.rimap_desarrollo_movil/save_image',
  );

  /// Guardar copia interna de la imagen (para la BD)
  Future<String> saveInternal(File image) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(
      dir.path,
      "foto_${DateTime.now().millisecondsSinceEpoch}.png",
    );
    return (await image.copy(path)).path;
  }

  /// Guardar copia en la galería usando código nativo
  Future<void> saveToGalleryNative(File image) async {
    final Uint8List bytes = await image.readAsBytes();
    await platform.invokeMethod('saveImage', {
      "image": bytes,
      "name": "foto_${DateTime.now().millisecondsSinceEpoch}.png",
    });
  }

  /// Guardar o actualizar un reporte en la BD
  Future<void> guardarReporte(Report report, {bool isEditing = false}) async {
    if (isEditing && report.id != null) {
      // Al editar, conservar la foto original si no se cambió
      final reporteExistente = await db.obtenerReportePorId(report.id!);

      final String? fotoFinal =
          (report.foto_path == null || report.foto_path!.isEmpty)
          ? reporteExistente?.foto_path
          : report.foto_path;

      await db.actualizarReporte(
        report.id!,
        report.tipo,
        report.direccion,
        report.referencia,
        fotoFinal,
      );
    } else {
      // Al crear, se asigna automáticamente el estado "En trámite"
      // 👇 ahora incluimos el userId del usuario logueado
      await db.agregarReporte(
        report.tipo,
        report.direccion,
        report.referencia,
        report.foto_path,
        report.userId, // 👈 nuevo parámetro obligatorio
      );
    }
  }
}
