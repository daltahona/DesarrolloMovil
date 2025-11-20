import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// Definición de la clase como Singleton para una gestión eficiente de la DB
class BbDM {
  // 1. Instancia Singleton estática
  static final BbDM _instance = BbDM._internal();
  factory BbDM() => _instance;
  BbDM._internal();

  // 2. Variable para almacenar la instancia de la base de datos abierta
  static Database? _database;

  // 3. Getter que asegura que la base de datos se abre una sola vez
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDataBase();
    return _database!;
  }

  // Método para inicializar la DB de forma segura (copia de assets, migración y creación)
  Future<Database> _initDataBase() async {
    final path = await _getDatabasePath();

    // Abrir la base de datos con la lógica de migración y creación
    final db = await openDatabase(
      path,
      version: 2,
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 2) {
          // Agregar columna 'foto_path' si la base de datos es anterior a la versión 2
          await db.execute("ALTER TABLE reportes ADD COLUMN foto_path TEXT");
        }
      },
    );

    // Verificación de existencia de tabla (si la DB se crea de cero)
    final tablas = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='reportes'",
    );

    if (tablas.isEmpty) {
      // Crear la tabla si no existe (esto puede pasar si no se copió de assets)
      await db.execute('''
        CREATE TABLE reportes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tipo TEXT NOT NULL,
          direccion TEXT NOT NULL,
          referencia TEXT NOT NULL,
          foto_path TEXT,
          fecha TEXT NOT NULL
        )
      ''');
    }

    return db;
  }

  Future<String> _getDatabasePath() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDir.path, 'appDM.db');

    if (!File(dbPath).existsSync()) {
      // Intenta copiar la DB inicial de assets si no existe localmente
      try {
        final byteData = await rootBundle.load('assets/appDM.db');
        final buffer = byteData.buffer;
        await File(dbPath).writeAsBytes(
          buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        );
      } catch (e) {
        // Si falla la carga de assets, se usará la lógica de _initDataBase para crearla
        print("Error al cargar assets/appDM.db: $e");
      }
    }

    return dbPath;
  }

  // -------------------------------------------------------------------
  // OPERACIONES CRUD (ya no cierran la DB)
  // -------------------------------------------------------------------

  Future<void> agregarReporte(
    String tipo,
    String direccion,
    String referencia,
    String? fotoPath,
  ) async {
    final db = await database;
    await db.insert('reportes', {
      'tipo': tipo,
      'direccion': direccion,
      'referencia': referencia,
      'foto_path': fotoPath,
      'fecha': DateTime.now().toIso8601String(),
    });
  }

  Future<void> actualizarReporte(
    int id,
    String tipo,
    String direccion,
    String referencia,
    String? fotoPath,
  ) async {
    final db = await database;
    await db.update(
      'reportes',
      {
        'tipo': tipo,
        'direccion': direccion,
        'referencia': referencia,
        'foto_path': fotoPath,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> obtenerReportes() async {
    final db = await database;
    final data = await db.query('reportes', orderBy: 'fecha DESC');
    return data;
  }

  Future<void> borrarReporte({int? id}) async {
    final db = await database;

    if (id != null) {
      // Elimina un reporte específico
      await db.delete('reportes', where: 'id = ?', whereArgs: [id]);
    } else {
      // Elimina todos los reportes
      await db.delete('reportes');
    }
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
