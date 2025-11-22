import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:bcrypt/bcrypt.dart';
import '../../models/report_model.dart';

/// Clase de base de datos como Singleton para gestión eficiente
class BbDM {
  static final BbDM _instance = BbDM._internal();
  factory BbDM() => _instance;
  BbDM._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDataBase();
    return _database!;
  }

  Future<Database> _initDataBase() async {
    final path = await _getDatabasePath();

    final db = await openDatabase(
      path,
      version: 6, // subimos versión para incluir user_id
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE reportes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tipo TEXT NOT NULL,
            direccion TEXT NOT NULL,
            referencia TEXT NOT NULL,
            foto_path TEXT,
            fecha TEXT NOT NULL,
            estado TEXT DEFAULT 'En trámite',
            user_id INTEGER NOT NULL,
            FOREIGN KEY(user_id) REFERENCES usuarios(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            role TEXT NOT NULL
          )
        ''');

        // Insertar SOLO admin con contraseña encriptada
        await db.insert('usuarios', {
          'username': 'admin',
          'password': BCrypt.hashpw('Admin1234', BCrypt.gensalt()),
          'role': 'admin',
        });
      },
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 2) {
          final tablas = await db.rawQuery(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='reportes'",
          );
          if (tablas.isNotEmpty) {
            await db.execute("ALTER TABLE reportes ADD COLUMN foto_path TEXT");
          }
        }
        if (oldV < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS usuarios (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT UNIQUE NOT NULL,
              password TEXT NOT NULL,
              role TEXT NOT NULL
            )
          ''');
        }
        if (oldV < 4) {
          await db.execute(
            "ALTER TABLE reportes ADD COLUMN estado TEXT DEFAULT 'En trámite'",
          );
        }
        if (oldV < 5) {
          // Regenerar SOLO admin con contraseña encriptada
          await db.delete('usuarios');
          await db.insert('usuarios', {
            'username': 'admin',
            'password': BCrypt.hashpw('Admin1234', BCrypt.gensalt()),
            'role': 'admin',
          });
        }
        if (oldV < 6) {
          // nuevo campo user_id
          await db.execute("ALTER TABLE reportes ADD COLUMN user_id INTEGER");
        }
      },
    );

    await _seedDefaultAdmin(db);
    return db;
  }

  /// Semilla de usuarios: SOLO admin
  Future<void> _seedDefaultAdmin(Database db) async {
    final admin = await db.query(
      'usuarios',
      where: 'username = ?',
      whereArgs: ['admin'],
      limit: 1,
    );
    if (admin.isEmpty) {
      await db.insert('usuarios', {
        'username': 'admin',
        'password': BCrypt.hashpw('Admin1234', BCrypt.gensalt()),
        'role': 'admin',
      });
    }
  }

  Future<String> _getDatabasePath() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDir.path, 'appDM.db');

    if (!File(dbPath).existsSync()) {
      try {
        final byteData = await rootBundle.load('assets/appDM.db');
        final buffer = byteData.buffer;
        await File(dbPath).writeAsBytes(
          buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        );
      } catch (e) {
        print("Error al cargar assets/appDM.db: $e");
      }
    }

    return dbPath;
  }

  // -------------------------------------------------------------------
  // CRUD REPORTES
  // -------------------------------------------------------------------

  Future<void> agregarReporte(
    String tipo,
    String direccion,
    String referencia,
    String? fotoPath,
    int userId,
  ) async {
    final db = await database;
    await db.insert('reportes', {
      'tipo': tipo,
      'direccion': direccion,
      'referencia': referencia,
      'foto_path': fotoPath,
      'fecha': DateTime.now().toIso8601String(),
      'estado': 'En trámite',
      'user_id': userId,
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

  Future<void> actualizarEstado(int id, String nuevoEstado) async {
    final db = await database;
    await db.update(
      'reportes',
      {'estado': nuevoEstado},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Report>> obtenerReportes() async {
    final db = await database;
    final result = await db.query('reportes', orderBy: 'fecha DESC');
    return result.map((e) => Report.fromMap(e)).toList();
  }

  /// Reportes filtrados por usuario
  Future<List<Report>> obtenerReportesPorUsuario(int userId) async {
    final db = await database;
    final result = await db.query(
      'reportes',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'fecha DESC',
    );
    return result.map((e) => Report.fromMap(e)).toList();
  }

  /// Nuevo método: obtener todos los reportes con nombre de usuario (solo admin)
  Future<List<Map<String, Object?>>> obtenerReportesConUsuarios() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        r.id,
        r.tipo,
        r.direccion,
        r.referencia,
        r.foto_path,
        r.fecha,
        r.estado,
        r.user_id,
        u.username AS userName
      FROM reportes r
      INNER JOIN usuarios u ON r.user_id = u.id
      ORDER BY r.fecha DESC
    ''');
    return result;
  }

  Future<Report?> obtenerReportePorId(int id) async {
    final db = await database;
    final result = await db.query(
      'reportes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? Report.fromMap(result.first) : null;
  }

  Future<void> borrarReporte({int? id}) async {
    final db = await database;
    if (id != null) {
      await db.delete('reportes', where: 'id = ?', whereArgs: [id]);
    } else {
      await db.delete('reportes');
    }
  }

  // -------------------------------------------------------------------
  // CRUD USUARIOS con bcrypt
  // -------------------------------------------------------------------

  Future<void> agregarUsuario(
    String username,
    String password,
    String role,
  ) async {
    final db = await database;
    final hashed = BCrypt.hashpw(password, BCrypt.gensalt());
    await db.insert('usuarios', {
      'username': username,
      'password': hashed,
      'role': role,
    });
  }

  Future<Map<String, dynamic>?> obtenerUsuario(
    String username,
    String password,
  ) async {
    final db = await database;
    final result = await db.query(
      'usuarios',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );

    if (result.isNotEmpty) {
      final user = result.first;
      final hashed = user['password'] as String;
      if (BCrypt.checkpw(password, hashed)) {
        return user;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> obtenerUsuarioPorNombre(String nombre) async {
    final db = await database;
    final result = await db.query(
      'usuarios',
      where: 'username = ?',
      whereArgs: [nombre],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> actualizarContrasena(String nombre, String nuevaPassword) async {
    final db = await database;
    final hashed = BCrypt.hashpw(nuevaPassword, BCrypt.gensalt());
    await db.update(
      'usuarios',
      {'password': hashed},
      where: 'username = ?',
      whereArgs: [nombre],
    );
  }

  Future<void> borrarUsuarios() async {
    final db = await database;
    await db.delete('usuarios');
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // -------------------------------------------------------------------
  // Método de verificación (opcional)
  // -------------------------------------------------------------------
  Future<void> imprimirUsuarios() async {
    final db = await database;
    final usuarios = await db.query('usuarios');
    for (var u in usuarios) {
      print("Usuario: ${u['username']}, Hash: ${u['password']}");
    }
  }
}
