class Report {
  final int? id;
  final String tipo;
  final String direccion;
  final String referencia;
  final String? foto_path;
  final String? fecha;
  final String estado; // nuevo campo

  Report({
    this.id,
    required this.tipo,
    required this.direccion,
    required this.referencia,
    this.foto_path,
    this.fecha,
    this.estado = "En trámite", // valor por defecto
  });

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'],
      tipo: map['tipo'],
      direccion: map['direccion'],
      referencia: map['referencia'],
      foto_path: map['foto_path'],
      fecha: map['fecha'],
      estado: map['estado'] ?? "En trámite", // leer estado
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo,
      'direccion': direccion,
      'referencia': referencia,
      'foto_path': foto_path,
      'fecha': fecha,
      'estado': estado, // guardar estado
    };
  }
}
