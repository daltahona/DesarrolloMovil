import '../models/report_model.dart';
import '../core/database/bd_dm.dart';

class ReportListViewModel {
  final BbDM db = BbDM();

  /// Obtener todos los reportes desde la BD (para usuarios normales)
  Future<List<Report>> obtenerReportes() async {
    return await db.obtenerReportes(); // devuelve List<Report>
  }

  /// Obtener todos los reportes con nombre de usuario (JOIN con tabla usuarios)
  /// Usado por el admin para ver todos los reportes
  Future<List<Report>> obtenerTodosLosReportes() async {
    final rows = await db
        .obtenerReportesConUsuarios(); //  usamos el método del helper
    return rows.map((row) => Report.fromMap(row)).toList();
  }

  /// Obtener reportes filtrados por usuario (solo sus propios reportes)
  Future<List<Report>> obtenerReportesPorUsuario(int userId) async {
    return await db.obtenerReportesPorUsuario(userId);
  }

  /// Eliminar un reporte por ID
  Future<void> eliminarReporte(int id) async {
    await db.borrarReporte(id: id);
  }

  /// Actualizar estado de un reporte
  Future<void> actualizarEstado(int id, String nuevoEstado) async {
    await db.actualizarEstado(id, nuevoEstado);
  }
}
