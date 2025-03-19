import 'package:flutter/material.dart';

import 'dart:math' as math;

class VisualizarCentrosScreen extends StatefulWidget {
  @override
  _VisualizarCentrosScreenState createState() =>
      _VisualizarCentrosScreenState();
}

class _VisualizarCentrosScreenState extends State<VisualizarCentrosScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String? _provincia = 'San Pedro de Macorís';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFFF59E0B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, _animation.value],
              ),
            ),
            child: Stack(
              children: [
                // Fondo con círculos animados (efecto manual)
                _buildAnimatedBackground(),
                // Contenido principal
                Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Título con animación
                          AnimatedOpacity(
                            duration: Duration(milliseconds: 1000),
                            opacity: _animation.value,
                            child: Text(
                              'VISUALIZAR CENTROS DE ACOPIOS',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(3, 3),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 40),
                          // Dropdown con animación
                          AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Provincia',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                              ),
                              value: _provincia,
                              items:
                                  ['San Pedro de Macorís'].map((String item) {
                                    return DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(
                                        item,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() => _provincia = value);
                              },
                            ),
                          ),
                          SizedBox(height: 30),
                          // Lista de ubicaciones con diseño asimétrico
                          _buildLocationList(),
                          SizedBox(height: 40),
                          // Botón con efecto 3D
                          _buildNeonButton('VER MAPA INTERACTIVO'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return CustomPaint(
      painter: _BackgroundPainter(_animation.value),
      child: Container(),
    );
  }

  Widget _buildLocationList() {
    final locations = [
      'Calle Isidro Barros #77, Municipio Consuelo',
      'Avenida Independencia #2, Municipio SPM',
      'Calle Mella #58, Sector Los Almendros, Municipio Los Llanos',
      'Calle 30 de Marzo #76, Sector La Ciénaga, Municipio Quisqueya',
      'Calle Juan Bosch #56, Residential Costa Azul, Municipio Guayacanes',
      'Avenida Duarte #14, Sector El Progreso, Municipio Ramón Santana',
    ];

    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            locations.map((location) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, color: Color(0xFFDC2626), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          height: 1.5,
                          shadows: [
                            Shadow(
                              color: Colors.black12,
                              offset: Offset(1, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildNeonButton(String text) {
    return GestureDetector(
      onTap: () {},
      child: MouseRegion(
        onEnter: (_) => setState(() {}), // Simula hover para efecto
        onExit: (_) => setState(() {}),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 18, horizontal: 40),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFDC2626), Color(0xFFF87171)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFDC2626).withOpacity(0.6),
                spreadRadius: 5,
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 10,
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double animationValue;

  _BackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.1);
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 5; i++) {
      final radius = 50.0 + (math.sin(animationValue + i) * 30);
      canvas.drawCircle(
        Offset(
          center.dx + math.cos(animationValue + i * 2) * 300,
          center.dy + math.sin(animationValue + i * 2) * 300,
        ),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
