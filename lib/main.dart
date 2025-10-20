import 'package:flutter/material.dart';

/// Función principal que inicia la aplicación Flutter
void main() {
  runApp(const MyApp());
}

/// Widget principal de la aplicación que configura el MaterialApp
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Construye la aplicación con el tema y la pantalla inicial
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeCampus',
      home: const WelcomeScreen(), // Pantalla de bienvenida como inicio
    );
  }
}

/// Pantalla de bienvenida con logo de la universidad y botón de inicio
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  /// Construye la interfaz de la pantalla de bienvenida
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Contenido principal centrado (logo y título)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Título de la aplicación
                const Text(
                  'SafeCampus',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Imagen del logo de la universidad desde internet
                Image.network(
                  'https://logowik.com/content/uploads/images/universidad-de-la-guajira7775.logowik.com.webp',
                  height: 150,
                  errorBuilder: (context, error, stackTrace) {
                    // Texto alternativo si falla la carga de la imagen
                    return const Column(
                      children: [
                        Text(
                          'UNIVERSIDAD',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'DE LA GUAJIRA',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('SHIKII EKIRAJIA', style: TextStyle(fontSize: 14)),
                        Text('PÜLEE WAJIRA', style: TextStyle(fontSize: 14)),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Botón INICIAR posicionado en la parte inferior
          Positioned(
            bottom: 100, // Distancia desde el fondo de la pantalla
            left: 0,
            right: 0,
            child: Column(
              children: [
                ElevatedButton(
                  /// Navega a la pantalla principal al presionar el botón
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Fondo blanco
                    side: const BorderSide(color: Colors.black), // Borde negro
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Bordes redondeados
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'INICIAR',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pantalla principal con menú lateral y contenido dinámico
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  /// Crea el estado para la pantalla principal
  @override
  State<MainScreen> createState() => _MainScreenState();
}

/// Estado que maneja la lógica de la pantalla principal
class _MainScreenState extends State<MainScreen> {
  String _currentScreen = 'Menu Principal'; // Pantalla actualmente visible

  /// Cambia la pantalla actual y cierra el menú lateral
  void _changeScreen(String screen) {
    setState(() {
      _currentScreen = screen; // Actualiza la pantalla visible
    });
    Navigator.pop(context); // Cierra el drawer después de seleccionar
  }

  /// Navega de vuelta a la pantalla de bienvenida
  void _goToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (route) => false, // Elimina todas las rutas anteriores
    );
  }

  /// Construye la interfaz de la pantalla principal
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SafeCampus')),

      // Menú lateral deslizable
      drawer: Drawer(
        child: ListView(
          children: [
            // Encabezado del menú lateral
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menú SafeCampus',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),

            // Opciones del menú de emergencias
            _buildDrawerItem('INCENDIO', 'Texto 1'),
            _buildDrawerItem('SISMO', 'Texto 2'),
            _buildDrawerItem('EMERGENCIA MÉDICA', 'Texto 3'),
            _buildDrawerItem('SEGURIDAD', 'Texto 4'),
            _buildDrawerItem('RUTAS DE EVACUACIÓN', 'Texto 5'),
            _buildDrawerItem('CONTACTOS EMERGENCIA', 'Texto 6'),

            const Divider(), // Línea separadora visual
            // Opción para volver al inicio
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Volver al Inicio'),
              onTap: _goToHome, // Ejecuta la función para volver al inicio
            ),
          ],
        ),
      ),

      // Contenido principal que cambia según la selección del menú
      body: Center(
        child: Text(_currentScreen, style: const TextStyle(fontSize: 24)),
      ),
    );
  }

  /// Crea un elemento del menú lateral con título y acción
  Widget _buildDrawerItem(String title, String screen) {
    return ListTile(
      title: Text(title),
      onTap: () => _changeScreen(screen), // Cambia la pantalla al hacer tap
    );
  }
}
