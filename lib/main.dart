import 'package:flutter/material.dart';
import 'views/login_screen.dart';

void main() async {
  // Esto asegura que los plugins nativos estén listos antes de ejecutar la app
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
      home: const LoginScreen(), // inicia en login
    );
  }
}
