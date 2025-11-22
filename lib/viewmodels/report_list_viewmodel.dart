import '../models/report_model.dart';
import '../core/database/bd_dm.dart';

class ReportListViewModel {
  final BbDM db = BbDM();

  /// Obtener todos los reportes desde la BD
  Future<List<Report>> obtenerReportes() async {
    return await db.obtenerReportes(); // devuelve List<Report>
  }

  /// Eliminar un reporte por ID
  Future<void> eliminarReporte(int id) async {
    await db.borrarReporte(id: id);
  }

  ///  Nuevo método: actualizar estado de un reporte
  Future<void> actualizarEstado(int id, String nuevoEstado) async {
    await db.actualizarEstado(id, nuevoEstado);
  }
}
