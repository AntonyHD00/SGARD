import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:proyectofinal/main.dart'; 

void main() {
  runApp(MaterialApp(
    home: LoginScreen(),
  ));
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _pulseAnimation;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
    _emailController.dispose();
    _passwordController.dispose();
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
                _buildAnimatedBackground(),
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
                                        color: Color(0xFFDC2626)
                                            .withOpacity(0.6),
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
                                      Icons.lock,
                                      size: 90,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 40),
                          AnimatedOpacity(
                            duration: Duration(milliseconds: 1000),
                            opacity: _animation.value,
                            child: Text(
                              'INICIAR SESIÓN',
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
                          SizedBox(height: 40),
                          _buildTextField(
                            controller: _emailController,
                            label: 'Correo Electrónico',
                            icon: Icons.email,
                          ),
                          SizedBox(height: 20),
                          _buildTextField(
                            controller: _passwordController,
                            label: 'Contraseña',
                            icon: Icons.lock,
                            isPassword: true,
                          ),
                          SizedBox(height: 40),
                          _buildNeonButton('INGRESAR', onTap: () {
                            Navigator.pushReplacement(
                            context,
                             MaterialPageRoute(builder: (context) => HomeScreen()),
                            );
                          }),
                          SizedBox(height: 20),
                          GestureDetector(
                                onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterScreen(),
      ),
    );
  },
  child: AnimatedContainer(
    duration: Duration(milliseconds: 300),
    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFFDC2626).withOpacity(0.2), Color(0xFFF59E0B).withOpacity(0.2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withOpacity(0.5),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Text(
      '¿No tienes cuenta? Regístrate',
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.3),
            offset: Offset(1, 1),
            blurRadius: 4,
          ),
        ],
      ),
    ),
  ),
),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      padding: EdgeInsets.symmetric(horizontal: 15),
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
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(color: Colors.black87, fontSize: 18),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black54),
          prefixIcon: Icon(icon, color: Color(0xFFDC2626)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildNeonButton(String text, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
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

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _pulseAnimation;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_passwordController.text == _confirmPasswordController.text) {
      // Add your registration logic here (e.g., API call)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registro exitoso')),
      );
      Navigator.pop(context); // Return to LoginScreen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Las contraseñas no coinciden')),
      );
    }
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
                _buildAnimatedBackground(),
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
                                        color: Color(0xFFDC2626)
                                            .withOpacity(0.6),
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
                                      Icons.person_add,
                                      size: 90,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 40),
                          AnimatedOpacity(
                            duration: Duration(milliseconds: 1000),
                            opacity: _animation.value,
                            child: Text(
                              'REGISTRARSE',
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
                          SizedBox(height: 40),
                          _buildTextField(
                            controller: _emailController,
                            label: 'Correo Electrónico',
                            icon: Icons.email,
                          ),
                          SizedBox(height: 20),
                          _buildTextField(
                            controller: _passwordController,
                            label: 'Contraseña',
                            icon: Icons.lock,
                            isPassword: true,
                          ),
                          SizedBox(height: 20),
                          _buildTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirmar Contraseña',
                            icon: Icons.lock,
                            isPassword: true,
                          ),
                          SizedBox(height: 40),
                          _buildNeonButton('REGISTRAR', onTap: _register),
                          SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              '¿Ya tienes cuenta? Inicia sesión',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      padding: EdgeInsets.symmetric(horizontal: 15),
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
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(color: Colors.black87, fontSize: 18),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black54),
          prefixIcon: Icon(icon, color: Color(0xFFDC2626)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildNeonButton(String text, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
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
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

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