import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:rimap_desarrollo_movil/database/bd_dm.dart';

void main() {
  runApp(const ReportApp());
}

class ReportApp extends StatelessWidget {
  const ReportApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de reporte ciudadano',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ReportTypeScreen(),
    );
  }
}

// PANTALLA DE TIPOS DE REPORTE
class ReportTypeScreen extends StatelessWidget {
  const ReportTypeScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> reportTypes = const [
    {
      'title': 'Daños viales',
      'subtitle': 'Reporta huecos o baches en la vía pública',
    },
    {
      'title': 'Aguas residuales',
      'subtitle': 'Reporta fugas, estancamientos o malos olores',
    },
    {
      'title': 'Alumbrado público',
      'subtitle': 'Reporta luminarias o postes sin funcionamiento',
    },
    {
      'title': 'Semáforos y señales de tránsito',
      'subtitle': 'Reporta fallas o daños en la señalización vial',
    },
    {
      'title': 'Acumulación de basuras',
      'subtitle': 'Reporta puntos críticos o basuras en la vía pública',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reporta y transforma tu ciudad')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Qué tipo de reporte deseas realizar?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: reportTypes.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(reportTypes[index]['title']!),
                      subtitle: Text(reportTypes[index]['subtitle']!),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportFormScreen(
                              type: reportTypes[index]['title']!,
                              existingData: null,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportListScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.list),
              label: const Text('Ver reportes enviados'),
            ),
          ],
        ),
      ),
    );
  }
}

// FORMULARIO DE REPORTE (PARA CREAR Y EDITAR)
class ReportFormScreen extends StatefulWidget {
  final String type;
  final Map<String, dynamic>? existingData;

  const ReportFormScreen({Key? key, required this.type, this.existingData})
    : super(key: key);

  @override
  State<ReportFormScreen> createState() => ReportFormScreenState();
}

class ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String address = '';
  String reference = '';
  File? selectedImage;

  final ImagePicker picker = ImagePicker();

  //Definimos el canal nativo
  static const platform = MethodChannel(
    'com.rimap_desarrollo_movil/save_image',
  );

  @override
  void initState() {
    super.initState();

    if (widget.existingData != null) {
      address = widget.existingData!["direccion"];
      reference = widget.existingData!["referencia"];
      if (widget.existingData!["foto_path"] != null) {
        selectedImage = File(widget.existingData!["foto_path"]);
      }
    }
  }

  // Se mantiene la función para guardar la copia interna (para la DB)
  Future<String> saveInternal(File image) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(
      dir.path,
      "foto_${DateTime.now().millisecondsSinceEpoch}.png",
    );
    return (await image.copy(path)).path;
  }

  //Función auxiliar para llamar al código nativo y guardar en Galería
  Future<void> saveToGalleryNative(File image) async {
    try {
      final Uint8List bytes = await image.readAsBytes();
      await platform.invokeMethod('saveImage', {
        "image": bytes,
        "name": "foto_${DateTime.now().millisecondsSinceEpoch}.png",
      });
      // Muestra un SnackBar de éxito
      if (!mounted) return;
    } catch (e) {
      // Muestra un SnackBar si hay un error en el canal nativo
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar en galería: $e")),
      );
      print("Error guardando en galería: $e");
    }
  }

  // Las funciones de picker solo actualizan el estado
  Future<void> pickFromGallery() async {
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() => selectedImage = File(file.path));
  }

  Future<void> takePhoto() async {
    final XFile? file = await picker.pickImage(source: ImageSource.camera);
    if (file == null) return;
    setState(() => selectedImage = File(file.path));
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingData != null;

    return Scaffold(
      // ✅ CAMBIO 1: Evita que el layout se encoja al abrir el teclado
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(isEditing ? "Editar reporte" : widget.type)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Dirección del daño en la vía pública',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                initialValue: address,
                decoration: const InputDecoration(
                  hintText: 'Ejemplo: Calle 12 con Carrera 5',
                  labelText: 'Dirección',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Campo requerido" : null,
                onSaved: (value) => address = value!,
              ),
              const SizedBox(height: 16),
              const Text(
                'Punto de referencia (mínimo 5 caracteres)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                initialValue: reference,
                decoration: const InputDecoration(
                  hintText: 'Ejemplo: Cerca al parque...',
                  labelText: 'Referencia',
                ),
                validator: (value) => value == null || value.length < 5
                    ? "Mínimo 5 caracteres"
                    : null,
                onSaved: (value) => reference = value!,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Tomar foto"),
                  ),
                  ElevatedButton.icon(
                    onPressed: pickFromGallery,
                    icon: const Icon(Icons.photo),
                    label: const Text("Galería"),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    selectedImage!,
                    height: 280,
                    // Muestra la foto completa dentro del espacio (sin recortar)
                    fit: BoxFit.contain,
                  ),
                ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    String? imagePath;

                    if (selectedImage != null) {
                      // 📌 5. Lógica de guardado centralizada en el botón "Enviar"
                      // Si es un reporte nuevo o la foto cambió
                      if (widget.existingData == null ||
                          selectedImage!.path !=
                              widget.existingData!["foto_path"]) {
                        // A. Guardar copia interna (Para la App y DB)
                        imagePath = await saveInternal(selectedImage!);

                        // B. Guardar copia en Galería (Nativo)
                        await saveToGalleryNative(selectedImage!);
                      } else {
                        // Si es edición y la foto no cambió, mantiene la ruta interna existente
                        imagePath = selectedImage!.path;
                      }
                    }

                    final BbDM db = BbDM();

                    if (isEditing) {
                      await db.actualizarReporte(
                        widget.existingData!["id"],
                        widget.type,
                        address,
                        reference,
                        imagePath,
                      );
                      // Vuelve a la lista e indica que hubo una actualización
                      if (!mounted) return;
                      Navigator.pop(context, true);
                      return;
                    }

                    await db.agregarReporte(
                      widget.type,
                      address,
                      reference,
                      imagePath,
                    );

                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportSuccessScreen(
                          type: widget.type,
                          address: address,
                          reference: reference,
                        ),
                      ),
                    );
                  }
                },
                child: Text(isEditing ? "Guardar cambios" : "Enviar reporte"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// REPORTE ENVIADO (CONFIRMACIÓN
class ReportSuccessScreen extends StatelessWidget {
  final String type;
  final String address;
  final String reference;

  const ReportSuccessScreen({
    Key? key,
    required this.type,
    required this.address,
    required this.reference,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reporte enviado')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                '¡Tu reporte ha sido enviado con éxito!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                'Tipo: $type\nDirección: $address\nReferencia: $reference',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportTypeScreen(),
                    ),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// LISTA DE REPORTES
class ReportListScreen extends StatefulWidget {
  const ReportListScreen({Key? key}) : super(key: key);

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  late Future<List<Map<String, dynamic>>> _reportes;

  @override
  void initState() {
    super.initState();
    _reportes = BbDM().obtenerReportes();
  }

  Future<void> _eliminarReporte(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar reporte'),
          content: const Text('¿Deseas eliminar este reporte?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await BbDM().borrarReporte(id: id);
      setState(() {
        _reportes = BbDM().obtenerReportes();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes enviados')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _reportes,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reportes = snapshot.data!;

          if (reportes.isEmpty) {
            return const Center(child: Text("No hay reportes."));
          }

          return ListView.builder(
            itemCount: reportes.length,
            itemBuilder: (context, index) {
              final r = reportes[index];

              return Card(
                child: ListTile(
                  leading: r["foto_path"] != null
                      ? Image.file(
                          File(r["foto_path"]),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image),
                  title: Text(r['tipo']),
                  subtitle: Text('${r['direccion']}\n${r['referencia']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReportFormScreen(
                                type: r["tipo"],
                                existingData: r,
                              ),
                            ),
                          );
                          if (updated == true) {
                            setState(() {
                              _reportes = BbDM().obtenerReportes();
                            });
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminarReporte(r['id']),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportDetailScreen(reporte: r),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// DETALLE DEL REPORTE
class ReportDetailScreen extends StatelessWidget {
  final Map<String, dynamic> reporte;

  const ReportDetailScreen({Key? key, required this.reporte}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final foto = reporte["foto_path"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle del reporte"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportFormScreen(
                    type: reporte["tipo"],
                    existingData: reporte,
                  ),
                ),
              );
              // Recargar la lista de reportes al volver a la pantalla de detalle.
              if (!context.mounted) return;
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (foto != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(foto),
                  height: 280,
                  // Muestra la foto completa en el detalle también
                  fit: BoxFit.contain,
                ),
              )
            else
              const Icon(Icons.image, size: 150),
            const SizedBox(height: 20),
            Text(
              "Tipo: ${reporte['tipo']}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Dirección: ${reporte['direccion']}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "Referencia: ${reporte['referencia']}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "Fecha: ${reporte['fecha']}",
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
