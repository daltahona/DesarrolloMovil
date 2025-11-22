import 'package:flutter/material.dart';
import 'report_form_screen.dart';
import 'user_report_screen.dart'; // acceso de usuario
import 'login_screen.dart'; // importamos LoginScreen

class ReportTypeScreen extends StatelessWidget {
  final int userId; // 👈 recibimos el userId desde LoginScreen

  const ReportTypeScreen({super.key, required this.userId});

  final List<Map<String, dynamic>> reportTypes = const [
    {
      'title': 'Daños viales',
      'subtitle': 'Reporta huecos o baches en la vía pública',
      'icon': Icons.construction,
    },
    {
      'title': 'Aguas residuales',
      'subtitle': 'Reporta fugas, estancamientos o malos olores',
      'icon': Icons.water_damage,
    },
    {
      'title': 'Alumbrado público',
      'subtitle': 'Reporta luminarias o postes sin funcionamiento',
      'icon': Icons.lightbulb,
    },
    {
      'title': 'Semáforos y señales de tránsito',
      'subtitle': 'Reporta fallas o daños en la señalización vial',
      'icon': Icons.traffic,
    },
    {
      'title': 'Acumulación de basuras',
      'subtitle': 'Reporta puntos críticos o basuras en la vía pública',
      'icon': Icons.delete,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B4C4C),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        title: const Text(
          'Reporta y transforma tu ciudad',
          style: TextStyle(
            color: Color(0xFF1B4C4C),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF1B4C4C)),
            tooltip: "Cerrar sesión",
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text('Cerrar sesión'),
                    content: const Text(
                      '¿Estás seguro de querer cerrar sesión?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text('Sí'),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Qué tipo de reporte deseas realizar?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: reportTypes.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: Icon(
                        reportTypes[index]['icon'],
                        color: const Color(0xFF1B4C4C),
                        size: 32,
                      ),
                      title: Text(
                        reportTypes[index]['title']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B4C4C),
                        ),
                      ),
                      subtitle: Text(reportTypes[index]['subtitle']!),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportFormScreen(
                              type: reportTypes[index]['title']!,
                              existingData: null,
                              userId: userId, // 👈 pasamos el userId
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
                    builder: (context) => UserReportScreen(
                      userId: userId,
                    ), // 👈 pasamos el userId
                  ),
                );
              },
              icon: const Icon(Icons.person),
              label: const Text('Seguir mi reporte'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1B4C4C),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
