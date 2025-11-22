import '../models/report_model.dart';
import '../core/database/bd_dm.dart';

class ReportDetailViewModel {
  final BbDM db = BbDM();

  /// Obtener un reporte por su ID
  Future<Report?> obtenerReportePorId(int id) async {
    return await db.obtenerReportePorId(id); // ya devuelve Report?
  }

  /// Actualizar un reporte existente
  Future<void> actualizarReporte(Report report) async {
    if (report.id != null) {
      await db.actualizarReporte(
        report.id!,
        report.tipo,
        report.direccion,
        report.referencia,
        report.foto_path,
      );
    }
  }
}
