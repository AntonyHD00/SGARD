import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';

class InventariosScreen extends StatefulWidget {
  @override
  _InventariosScreenState createState() => _InventariosScreenState();
}

class _InventariosScreenState extends State<InventariosScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String? _provincia = '';
  String? _codigoCentro;
  String? _direccion;
  TextEditingController _codigoController = TextEditingController();
  TextEditingController _direccionController = TextEditingController();

  // Lista de provincias de la República Dominicana
  final List<String> _provincias = [
    'Azua',
    'Bahoruco',
    'Barahona',
    'Dajabón',
    'Distrito Nacional',
    'Duarte',
    'El Seibo',
    'Elías Piña',
    'Espaillat',
    'Hato Mayor',
    'Hermanas Mirabal',
    'Independencia',
    'La Altagracia',
    'La Romana',
    'La Vega',
    'María Trinidad Sánchez',
    'Monseñor Nouel',
    'Monte Cristi',
    'Monte Plata',
    'Pedernales',
    'Peravia',
    'Puerto Plata',
    'Samaná',
    'San Cristóbal',
    'San José de Ocoa',
    'San Juan',
    'San Pedro de Macorís',
    'Sánchez Ramírez',
    'Santiago',
    'Santiago Rodríguez',
    'Santo Domingo',
    'Valverde',
  ]..sort();

  // Lista de códigos de centros de acopio (se cargará dinámicamente)
  List<String> _codigosCentros = [];
  List<Map<String, String>> _articulos = []; // Lista de artículos para la tabla
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

    _cargarCodigosCentros(_provincia!);
  }

  @override
  void dispose() {
    _controller.dispose();
    _codigoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  // Función para cargar los códigos de centros de acopio según la provincia
  Future<void> _cargarCodigosCentros(String provincia) async {
    try {
      final querySnapshot = await _firestore
          .collection('centros_de_acopios')
          .where('provincia', isEqualTo: provincia)
          .get();

      setState(() {
        _codigosCentros = querySnapshot.docs
            .where((doc) => doc.data().containsKey('codigo'))
            .map((doc) => doc['codigo'] as String)
            .toList();
        // Si hay códigos, seleccionamos el primero por defecto; si no, null
        _codigoCentro = _codigosCentros.isNotEmpty ? _codigosCentros[0] : null;
        _codigoController.text = _codigoCentro ?? '';
        // Cargar la dirección y los artículos si hay un código seleccionado
        if (_codigoCentro != null) {
          _cargarDireccion(_codigoCentro!);
          _cargarArticulos(_codigoCentro!);
        } else {
          _direccionController.text = '';
          _articulos = [];
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar códigos: $e')),
      );
    }
  }

  // Función para cargar la dirección del centro de acopio según el código
  Future<void> _cargarDireccion(String codigoCentro) async {
    try {
      final querySnapshot = await _firestore
          .collection('centros_de_acopios')
          .where('codigo', isEqualTo: codigoCentro)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        setState(() {
          _direccion = doc['municipio'] as String;
          _direccionController.text = _direccion ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar dirección: $e')),
      );
    }
  }

  // Función para cargar los artículos del centro de acopio según el código
  Future<void> _cargarArticulos(String codigoCentro) async {
    try {
      final querySnapshot = await _firestore
          .collection('donaciones')
          .where('codigoCentro', isEqualTo: codigoCentro)
          .get();

      setState(() {
        _articulos = querySnapshot.docs.map((doc) {
          return {
            'codigo': doc.data().containsKey('codigoArticulo') ? doc['codigoArticulo'] as String : 'N/A',
            'articulo': doc['articulo'] as String,
            'cantidad': doc['cantidad'] as String,
            'caducidad': doc['caducidad'] as String,
          };
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar artículos: $e')),
      );
    }
  }

  // Función para mostrar el diálogo con la tabla estilizada
  void _mostrarDialogoArticulos() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.only(top: 45),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Artículos del Centro',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildStyledTable(),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFDC2626),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      ),
                      child: Text(
                        'Cerrar',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                child: CircleAvatar(
                  backgroundColor: Color(0xFF1E3A8A),
                  radius: 45,
                  child: Icon(
                    Icons.inventory,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
                          // Dropdown para Provincia
                          _buildDropdownField('Provincia', _provincias, onChanged: (value) {
                            setState(() {
                              _provincia = value;
                              _cargarCodigosCentros(value!);
                            });
                          }),
                          // Dropdown para Código del Centro
                          _buildDropdownField('CÓDIGO DEL CENTRO', _codigosCentros, onChanged: (value) {
                            setState(() {
                              _codigoCentro = value;
                              _codigoController.text = value ?? '';
                              if (value != null) {
                                _cargarDireccion(value);
                                _cargarArticulos(value);
                              } else {
                                _direccionController.text = '';
                                _articulos = [];
                              }
                            });
                          }, value: _codigoCentro),
                          // Campo de Dirección (no editable)
                          _buildTextField('DIRECCIÓN', _direccionController, readOnly: true),
                          SizedBox(height: 40),
                          // Tabla con diseño asimétrico
                          _buildInventoryTable(),
                          SizedBox(height: 20),
                          // Botón para mostrar el diálogo
                          _buildNeonButton('VISUALIZAR EN DIÁLOGO', onTap: _mostrarDialogoArticulos),
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

  Widget _buildDropdownField(String label, List<String> items, {String? value, ValueChanged<String?>? onChanged}) {
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
          labelStyle: TextStyle(color: Colors.black87),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        value: value ?? (items.isNotEmpty ? items[0] : null),
        items: items.isEmpty
            ? [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(
                    'No hay centros disponibles',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                )
              ]
            : items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                );
              }).toList(),
        onChanged: onChanged ?? (value) {},
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false}) {
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
        readOnly: readOnly,
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
          ..._articulos.map((item) => _buildTableRow(item)).toList(),
          if (_articulos.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'No hay artículos para este centro.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }

  // Nueva función para construir la tabla estilizada en el diálogo
  Widget _buildStyledTable() {
    return Container(
      constraints: BoxConstraints(maxHeight: 400), // Limita la altura del diálogo
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 20,
          dataRowHeight: 60,
          headingRowHeight: 60,
          headingRowColor: MaterialStateColor.resolveWith((states) => Color(0xFF1E3A8A)),
          border: TableBorder(
            horizontalInside: BorderSide(color: Colors.grey.shade300, width: 1),
            verticalInside: BorderSide(color: Colors.grey.shade300, width: 1),
            top: BorderSide(color: Colors.grey.shade300, width: 1),
            bottom: BorderSide(color: Colors.grey.shade300, width: 1),
            left: BorderSide(color: Colors.grey.shade300, width: 1),
            right: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          columns: [
            DataColumn(
              label: Text(
                'Código',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Artículo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Cantidad',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Caducidad',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          rows: _articulos.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, String> item = entry.value;
            return DataRow(
              color: MaterialStateColor.resolveWith((states) =>
                  index % 2 == 0 ? Colors.grey.shade100 : Colors.white),
              cells: [
                DataCell(
                  Text(
                    item['codigo']!,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
                DataCell(
                  Text(
                    item['articulo']!,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
                DataCell(
                  Text(
                    item['cantidad']!,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
                DataCell(
                  Text(
                    item['caducidad']!,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text, Color color) {
    return Expanded(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
          shadows: [
            Shadow(color: Colors.black12, offset: Offset(1, 1), blurRadius: 3),
          ],
        ),
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
    return Expanded(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
          shadows: [
            Shadow(color: Colors.black12, offset: Offset(1, 1), blurRadius: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNeonButton(String text, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {},
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