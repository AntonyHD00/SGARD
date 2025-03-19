import 'package:flutter/material.dart';
import 'dart:math' as math;

class InventariosScreen extends StatefulWidget {
  @override
  _InventariosScreenState createState() => _InventariosScreenState();
}

class _InventariosScreenState extends State<InventariosScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  TextEditingController _codigoController = TextEditingController(
    text: 'CA-011-RS-SPM-1',
  );
  TextEditingController _direccionController = TextEditingController(
    text:
        'Calle Isidro Barros No. 77, Municipio Consuelo, San Pedro de Macorís',
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
    _direccionController.dispose();
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
                              'INVENTARIOS',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
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
                          // Campos de texto con animación
                          _buildTextField(
                            'CÓDIGO DEL CENTRO',
                            _codigoController,
                          ),
                          _buildTextField('DIRECCIÓN', _direccionController),
                          SizedBox(height: 30),
                          // Botones con efecto 3D
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildNeonButton('AGREGAR'),
                              _buildNeonButton('ELIMINAR SELECCIONADA'),
                            ],
                          ),
                          SizedBox(height: 40),
                          // Tabla con diseño asimétrico
                          _buildInventoryTable(),
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

  Widget _buildTextField(String label, TextEditingController controller) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
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
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black87),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        style: TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }

  Widget _buildInventoryTable() {
    final items = [
      {
        'codigo': 'A001',
        'articulo': 'Lata de Habichuelas Negras',
        'cantidad': '500 unidades',
        'caducidad': '15/12/2024',
      },
      {
        'codigo': 'A002',
        'articulo': 'Paquete de Arroz Blanco',
        'cantidad': '1000 unidades',
        'caducidad': '30/11/2025',
      },
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTableHeader('Código', Colors.black),
              _buildTableHeader('Artículo', Colors.black),
              _buildTableHeader('Cantidad', Colors.black),
              _buildTableHeader('Caducidad', Colors.black),
            ],
          ),
          SizedBox(height: 10),
          ...items.map((item) => _buildTableRow(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: color,
        shadows: [
          Shadow(color: Colors.black12, offset: Offset(1, 1), blurRadius: 3),
        ],
      ),
    );
  }

  Widget _buildTableRow(Map<String, String> item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTableCell(item['codigo']!),
          _buildTableCell(item['articulo']!),
          _buildTableCell(item['cantidad']!),
          _buildTableCell(item['caducidad']!),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        color: Colors.black87,
        shadows: [
          Shadow(color: Colors.black12, offset: Offset(1, 1), blurRadius: 3),
        ],
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
                offset: Offset(0, 8),
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
