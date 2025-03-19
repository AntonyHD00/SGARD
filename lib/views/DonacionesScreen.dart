import 'package:flutter/material.dart';
import 'dart:math' as math;

class DonacionesScreen extends StatefulWidget {
  @override
  _DonacionesScreenState createState() => _DonacionesScreenState();
}

class _DonacionesScreenState extends State<DonacionesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final _formKey = GlobalKey<FormState>();
  String? _provincia = 'San Pedro de Macorís';
  TextEditingController _codigoController = TextEditingController(
    text: 'CA-011-RS-SPM-1',
  );
  TextEditingController _articuloController = TextEditingController(
    text: 'ARROZ DOS PINOS DE 1LB.',
  );
  TextEditingController _cantidadController = TextEditingController(
    text: '500',
  );
  TextEditingController _caducidadController = TextEditingController(
    text: '18/12/2027',
  );

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
    _codigoController.dispose();
    _articuloController.dispose();
    _cantidadController.dispose();
    _caducidadController.dispose();
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
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AnimatedOpacity(
                            duration: Duration(milliseconds: 1000),
                            opacity: _animation.value,
                            child: Text(
                              'REGISTRO DE DONACIONES',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 40),
                          _buildDropdownField('Provincia', [
                            'San Pedro de Macorís',
                          ]),
                          _buildTextField(
                            'CÓDIGO DEL CENTRO',
                            _codigoController,
                          ),
                          _buildTextField('ARTÍCULO', _articuloController),
                          _buildTextField('CANTIDAD', _cantidadController),
                          _buildTextField('CADUCIDAD', _caducidadController),
                          SizedBox(height: 20),
                          _buildInfoCard(),
                          SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildNeonButton('REGISTRAR'),
                              _buildNeonButton('GUARDAR TODO'),
                              _buildNeonButton(
                                'VISUALIZAR LISTADO DE DONACIONES',
                              ),
                            ],
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

  Widget _buildDropdownField(String label, List<String> items) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(vertical: 10),
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
          labelText: label,
          labelStyle: TextStyle(color: Colors.black87), // Label negro
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        value: _provincia,
        items:
            items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ), // Texto negro
                ),
              );
            }).toList(),
        onChanged: (value) {
          setState(() => _provincia = value);
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(vertical: 10),
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
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black87), // Label negro
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        style: TextStyle(fontSize: 16, color: Colors.black87), // Texto negro
      ),
    );
  }

  Widget _buildInfoCard() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
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
      child: Text(
        'El arroz blanco donado es de la marca “Dos Pinos”. Cada paquete contiene una libra de arroz blanco de alta calidad, ideal para acompañar una amplia variedad de comidas.',
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87, // Texto negro
          shadows: [
            Shadow(color: Colors.black12, offset: Offset(1, 1), blurRadius: 3),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildNeonButton(String text) {
    return GestureDetector(
      onTap: () {},
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
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
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
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
          center.dx + math.cos(animationValue + i * 2) * 200,
          center.dy + math.sin(animationValue + i * 2) * 200,
        ),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
