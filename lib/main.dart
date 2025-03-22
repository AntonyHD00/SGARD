import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyectofinal/views/Dashboard.dart';
import 'package:proyectofinal/views/DonacionesScreen.dart';
import 'package:proyectofinal/views/InventariosScreen.dart';
import 'dart:math' as math;
import 'firebase_options.dart'; 
import 'package:firebase_core/firebase_core.dart'; // Agrega este import
import 'package:proyectofinal/views/Perfilscreen.dart';
import 'package:proyectofinal/views/VisualizarCentrosScreen.dart';
import 'package:proyectofinal/views/registrocentroscreen.dart';
import 'package:proyectofinal/views/LoginScreen.dart'; 
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Necesario para async
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Configuración de Firebase
  ); // Inicializa Firebase
  runApp(ChangeNotifierProvider(create: (_) => AppState(), child: MyApp()));
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SGARD Revolution',
      theme: ThemeData(
        primaryColor: Color(0xFF1E3A8A),

        hintColor: Color(0xFFF59E0B),
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 28,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
    );
  }
}

class AppState with ChangeNotifier {
  int selectedIndex = 0;
  void setIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    )..repeat();
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutQuad,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final List<Widget> _screens = [
    PerfilScreen(),
    RegistroCentrosScreen(),
    InventariosScreen(),
    VisualizarCentrosScreen(),
    DonacionesScreen(),
    DashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Navegación Lateral con Efecto Neón
          SizedBox(
            width: 80,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF2A4D8A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  _buildNavIcon(Icons.person, 0, 'Perfil'),
                  _buildNavIcon(Icons.store, 1, 'Registro Centros'),
                  _buildNavIcon(Icons.inventory_2, 2, 'Inventarios'),
                  _buildNavIcon(Icons.map, 3, 'Visualizar Centros'),
                  _buildNavIcon(Icons.favorite, 4, 'Donaciones'),
                  _buildNavIcon(
                    Icons.dashboard,
                    5,
                    'Dashboard',
                  ), // Nuevo ícono para Dashboard
                  Spacer(),
                  FloatingActionButton(
                    onPressed: () {},
                    backgroundColor: Color(0xFFDC2626),
                    child: Icon(Icons.settings, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Contenido Principal con Animación de Fondo
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFFF59E0B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.0, _animation.value],
                    ),
                  ),
                  child: _screens[context.watch<AppState>().selectedIndex],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, String label) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        bool isSelected = appState.selectedIndex == index;
        return GestureDetector(
          onTap: () => appState.setIndex(index),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(vertical: 5), // Espacio entre íconos
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFFDC2626) : Colors.transparent,
              borderRadius: BorderRadius.circular(50),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: Color(0xFFDC2626).withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 10,
                          offset: Offset(0, 0),
                        ),
                      ]
                      : [],
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.white70,
                  size: 30,
                ),
                if (isSelected)
                  Text(
                    label,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
