import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class BbDM {
  Future<String> _getDatabasePath() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDir.path, 'appDM.db');

    if (!File(dbPath).existsSync()) {
      final byteData = await rootBundle.load('assets/appDM.db');
      final buffer = byteData.buffer;
      await File(dbPath).writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );
    }

    return dbPath;
  }

  Future<Database> _openDataBase() async {
    final path = await _getDatabasePath();
    final db = await openDatabase(path, version: 1);

    final tablas = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='reportes'",
    );
    if (tablas.isEmpty) {
      await db.execute('''
        CREATE TABLE reportes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tipo TEXT NOT NULL,
          direccion TEXT NOT NULL,
          referencia TEXT NOT NULL,
          fecha TEXT NOT NULL
        )
      ''');
    }

    return db;
  }

  Future<void> agregarReporte(
    String tipo,
    String direccion,
    String referencia,
  ) async {
    final db = await _openDataBase();
    await db.insert('reportes', {
      'tipo': tipo,
      'direccion': direccion,
      'referencia': referencia,
      'fecha': DateTime.now().toIso8601String(),
    });
    await db.close();
  }

  Future<void> mostrarReportes() async {
    final db = await _openDataBase();
    final data = await db.query('reportes');
    for (var r in data) {
      print(
        'Reporte #${r['id']}: ${r['tipo']} - ${r['direccion']} (${r['referencia']})',
      );
    }
    await db.close();
  }

  Future<List<Map<String, dynamic>>> obtenerReportes() async {
    final db = await _openDataBase();
    final data = await db.query('reportes', orderBy: 'fecha DESC');
    await db.close();
    return data;
  }

  Future<void> verificarTablas() async {
    final db = await _openDataBase();
    final tablas = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    print('Tablas encontradas: $tablas');
    await db.close();
  }

  Future<void> borrarReporte({int? id}) async {
    final db = await _openDataBase();

    if (id != null) {
      await db.delete('reportes', where: 'id = ?', whereArgs: [id]);
      print('Reporte con ID $id eliminado.');
    } else {
      await db.delete('reportes');
      print('Todos los reportes han sido eliminados.');
    }

    await db.close();
  }
}
