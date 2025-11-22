import 'package:flutter/material.dart';
import 'views/login_screen.dart';
import 'views/report_list_screen.dart';
import 'views/report_type_screen.dart';
import 'views/report_success_screen.dart'; // si usas esta pantalla

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ReportApp());
}

class ReportApp extends StatelessWidget {
  const ReportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de reporte ciudadano',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(), // ✅ punto de entrada
      onGenerateRoute: (settings) {
        if (settings.name == '/reportList') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => ReportListScreen(
              userId: args['userId'],
              userRole: args['userRole'],
            ),
          );
        }

        if (settings.name == '/reportType') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => ReportTypeScreen(userId: args['userId']),
          );
        }

        if (settings.name == '/reportSuccess') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => ReportSuccessScreen(
              tipo: args['tipo'],
              direccion: args['direccion'],
              referencia: args['referencia'],
              userId: args['userId'],
            ),
          );
        }

        return null; // si la ruta no existe
      },
    );
  }
}
