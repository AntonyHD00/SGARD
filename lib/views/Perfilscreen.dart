import 'package:flutter/material.dart';
import 'dart:math' as math;

class PerfilScreen extends StatefulWidget {
  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _pulseAnimation;

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
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
                // Fondo con líneas y círculos animados
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Avatar con efecto pulsante
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [Colors.white, Color(0xFFDC2626)],
                                      stops: [0.5, 1.0],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(
                                          0xFFDC2626,
                                        ).withOpacity(0.6),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 70,
                                    backgroundColor: Color(0xFF1E3A8A),
                                    child: Icon(
                                      Icons.person,
                                      size: 90,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 20),
                          // Nombre con animación
                          AnimatedOpacity(
                            duration: Duration(milliseconds: 1000),
                            opacity: _animation.value,
                            child: Text(
                              'WILLIAN GUERRERO',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(3, 3),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 30),
                          // Detalles en tarjetas flotantes
                          _buildDetailCard('Número de Cédula', '028-6655889-1'),
                          _buildDetailCard('Institución', 'Gobernación'),
                          _buildDetailCard(
                            'Role',
                            'Encargado de Centro de Acopio (SPM)',
                          ),
                          _buildDetailCard(
                            'Correo',
                            'Willianguerrero001@gmail.com',
                          ),
                          _buildDetailCard('Teléfono', '+1(809) 589-6514'),
                          _buildDetailCard('Contraseña', '********'),
                          SizedBox(height: 40),
                          // Botón con efecto neón
                          _buildNeonButton('CERRAR SESIÓN'),
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

  Widget _buildDetailCard(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  shadows: [
                    Shadow(
                      color: Colors.black12,
                      offset: Offset(1, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeonButton(String text) {
    return GestureDetector(
      onTap: () {},
      child: MouseRegion(
        onEnter: (_) => setState(() {}),
        onExit: (_) => setState(() {}),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
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
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);

    // Círculos animados
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

    // Líneas dinámicas
    paint.color = Colors.white.withOpacity(0.05);
    for (int i = 0; i < 10; i++) {
      final startX = math.cos(animationValue + i) * size.width;
      final startY = math.sin(animationValue + i) * size.height;
      final endX = math.cos(animationValue + i + 1) * size.width;
      final endY = math.sin(animationValue + i + 1) * size.height;
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
