import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/report_model.dart';
import '../viewmodels/report_viewmodel.dart';
import 'report_success_screen.dart';

class ReportFormScreen extends StatefulWidget {
  final String type;
  final Map<String, dynamic>? existingData;
  final int userId; // 👈 obligatorio

  const ReportFormScreen({
    super.key,
    required this.type,
    this.existingData,
    required this.userId,
  });

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final vm = ReportViewModel();
  final picker = ImagePicker();

  String direccion = '';
  String referencia = '';
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      direccion = widget.existingData!["direccion"];
      referencia = widget.existingData!["referencia"];
      if (widget.existingData!["foto_path"] != null) {
        selectedImage = File(widget.existingData!["foto_path"]);
      }
    }
  }

  Future<void> pickFromGallery() async {
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => selectedImage = File(file.path));
  }

  Future<void> takePhoto() async {
    final XFile? file = await picker.pickImage(source: ImageSource.camera);
    if (file != null) setState(() => selectedImage = File(file.path));
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingData != null;

    return Scaffold(
      backgroundColor: const Color(0xFF1B4C4C),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        title: Text(
          isEditing ? "Editar reporte" : widget.type,
          style: const TextStyle(
            color: Color(0xFF1B4C4C),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: direccion,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.location_on),
                        labelText: 'Dirección',
                        hintText: 'Ej: Calle 22 #7A',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? "Campo requerido"
                          : null,
                      onSaved: (value) => direccion = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: referencia,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.notes),
                        labelText: 'Referencia',
                        hintText: 'Ej: Frente al parque principal',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) => value == null || value.length < 5
                          ? "Mínimo 5 caracteres"
                          : null,
                      onSaved: (value) => referencia = value!,
                    ),
                    const SizedBox(height: 20),

                    // Botones de foto
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: takePhoto,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text("Tomar foto"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B4C4C),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: pickFromGallery,
                          icon: const Icon(Icons.photo),
                          label: const Text("Galería"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B4C4C),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (selectedImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          selectedImage!,
                          height: 280,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context, false),
                          icon: const Icon(Icons.cancel),
                          label: const Text("Cancelar"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1B4C4C),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Color(0xFF1B4C4C),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();

                              String? imagePath;

                              // Ajuste para evitar duplicados
                              if (isEditing && selectedImage == null) {
                                imagePath = widget.existingData?["foto_path"];
                              } else if (selectedImage != null) {
                                imagePath = await vm.saveInternal(
                                  selectedImage!,
                                );
                                await vm.saveToGalleryNative(selectedImage!);
                              }

                              final report = Report(
                                id: widget.existingData?["id"],
                                tipo: widget.type,
                                direccion: direccion,
                                referencia: referencia,
                                foto_path: imagePath,
                                fecha: DateTime.now().toString(),
                                estado:
                                    widget.existingData?["estado"] ??
                                    "En trámite",
                                userId: widget.userId,
                              );

                              await vm.guardarReporte(
                                report,
                                isEditing: isEditing,
                              );

                              if (!mounted) return;

                              if (isEditing) {
                                Navigator.pop(context, true);
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReportSuccessScreen(
                                      tipo: report.tipo,
                                      direccion: report.direccion,
                                      referencia: report.referencia,
                                      userId: widget.userId,
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.save),
                          label: Text(
                            isEditing ? "Guardar cambios" : "Enviar reporte",
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B4C4C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
