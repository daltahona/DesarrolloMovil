class Report {
  final int? id;
  final String tipo;
  final String direccion;
  final String referencia;
  final String? foto_path;
  final String? fecha;
  final String estado;
  final int userId; //  obligatorio
  final String? userName; // nuevo campo opcional para mostrar el nombre

  Report({
    this.id,
    required this.tipo,
    required this.direccion,
    required this.referencia,
    this.foto_path,
    this.fecha,
    this.estado = "En trámite", // valor por defecto
    required this.userId,
    this.userName, //  se puede pasar si lo traes del JOIN
  });

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'],
      tipo: map['tipo'],
      direccion: map['direccion'],
      referencia: map['referencia'],
      foto_path: map['foto_path'],
      fecha: map['fecha'],
      estado: map['estado'] ?? "En trámite",
      userId: map['user_id'], //  lo leemos de la BD
      userName: map['userName'], //  lo traemos del JOIN si existe
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
      'estado': estado,
      'user_id': userId, //  lo guardamos en la BD
      'userName': userName, //  opcional, útil para mostrar en UI
    };
  }
}
