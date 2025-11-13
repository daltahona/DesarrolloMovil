import 'package:flutter/material.dart';
import 'bd_DM.dart';

void main() {
  runApp(ReportApp());
}

class ReportApp extends StatelessWidget {
  const ReportApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reportes Riohacha',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ReportTypeScreen(),
    );
  }
}

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
      appBar: AppBar(title: const Text('Sistema de reporte ciudadano')),
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

class ReportFormScreen extends StatefulWidget {
  final String type;

  const ReportFormScreen({Key? key, required this.type}) : super(key: key);

  @override
  State<ReportFormScreen> createState() => ReportFormScreenState();
}

class ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String address = '';
  String reference = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.type)),
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
                decoration: const InputDecoration(
                  hintText: 'Ejemplo: Calle 12 con Carrera 5',
                  labelText: 'Dirección',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa una dirección';
                  }
                  return null;
                },
                onSaved: (value) => address = value!,
              ),
              const SizedBox(height: 16),
              const Text(
                'Punto de referencia (mínimo 5 caracteres)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Ejemplo: Cerca al parque...',
                  labelText: 'Referencia',
                ),
                validator: (value) {
                  if (value == null || value.length < 5) {
                    return 'Debes escribir al menos 5 caracteres';
                  }
                  return null;
                },
                onSaved: (value) => reference = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final BbDM db = BbDM();
                    await db.agregarReporte(widget.type, address, reference);

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
                child: const Text('Enviar reporte'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
                'Tipo de reporte: $type\nDirección: $address\nReferencia: $reference',
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
      builder: (context) => AlertDialog(
        title: const Text('Eliminar reporte'),
        content: const Text('¿Deseas eliminar este reporte?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay reportes registrados.'));
          } else {
            final reportes = snapshot.data!;
            return ListView.builder(
              itemCount: reportes.length,
              itemBuilder: (context, index) {
                final r = reportes[index];
                return Card(
                  child: ListTile(
                    title: Text(r['tipo']),
                    subtitle: Text('${r['direccion']}\n${r['referencia']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(r['fecha'].toString().substring(0, 16)),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _eliminarReporte(r['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
