import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';

class DonacionesScreen extends StatefulWidget {
  @override
  _DonacionesScreenState createState() => _DonacionesScreenState();
}

class _DonacionesScreenState extends State<DonacionesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final _formKey = GlobalKey<FormState>();
  String? _provincia = '';
  String? _codigoCentro;
  TextEditingController _articuloController = TextEditingController(text: '');
  TextEditingController _cantidadController = TextEditingController(text: '');
  TextEditingController _caducidadController = TextEditingController(text: '00/00/0000');

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
  List<Map<String, dynamic>> _donaciones = []; // Lista de donaciones para la tabla
  String? _selectedDonacionId; // ID de la donación seleccionada para eliminar
  String? _editDonacionId; // ID de la donación seleccionada para editar
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

    // Cargar los códigos iniciales para la provincia por defecto
    _cargarCodigosCentros(_provincia!);
  }

  @override
  void dispose() {
    _controller.dispose();
    _articuloController.dispose();
    _cantidadController.dispose();
    _caducidadController.dispose();
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
        _codigoCentro = _codigosCentros.isNotEmpty ? _codigosCentros[0] : null;
        if (_codigoCentro != null) {
          _cargarDonaciones(_codigoCentro!);
        } else {
          _donaciones = [];
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar códigos: $e')),
      );
    }
  }

  // Función para cargar las donaciones del centro de acopio según el código
  Future<void> _cargarDonaciones(String codigoCentro) async {
    try {
      final querySnapshot = await _firestore
          .collection('donaciones')
          .where('codigoCentro', isEqualTo: codigoCentro)
          .get();

      setState(() {
        _donaciones = querySnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'codigo': doc.data().containsKey('codigoArticulo') ? doc['codigoArticulo'] as String : 'N/A',
            'articulo': doc['articulo'] as String,
            'cantidad': doc['cantidad'] as String,
            'caducidad': doc['caducidad'] as String,
          };
        }).toList();
        _selectedDonacionId = null; // Resetear la selección para eliminar
        _editDonacionId = null; // Resetear la selección para editar
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar donaciones: $e')),
      );
    }
  }

  // Función para generar un código de artículo en secuencia (A001, A002, etc.)
  Future<String> _generarCodigoArticulo(String codigoCentro) async {
    final querySnapshot = await _firestore
        .collection('donaciones')
        .where('codigoCentro', isEqualTo: codigoCentro)
        .get();

    final count = querySnapshot.docs.length + 1;
    return 'A${count.toString().padLeft(3, '0')}';
  }

  // Función para agregar una donación a Firestore
  Future<void> _agregarDonacion() async {
    if (_provincia == null ||
        _codigoCentro == null ||
        _articuloController.text.isEmpty ||
        _cantidadController.text.isEmpty ||
        _caducidadController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    try {
      final codigoArticulo = await _generarCodigoArticulo(_codigoCentro!);

      await _firestore.collection('donaciones').add({
        'provincia': _provincia,
        'codigoCentro': _codigoCentro,
        'codigoArticulo': codigoArticulo,
        'articulo': _articuloController.text,
        'cantidad': _cantidadController.text,
        'caducidad': _caducidadController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Donación registrada exitosamente')),
      );

      _limpiarCampos();
      // Recargar las donaciones para actualizar la tabla
      _cargarDonaciones(_codigoCentro!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar donación: $e')),
      );
    }
  }

  // Función para actualizar una donación existente
  Future<void> _actualizarDonacion() async {
    if (_editDonacionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se ha seleccionado una donación para actualizar')),
      );
      return;
    }

    if (_provincia == null ||
        _codigoCentro == null ||
        _articuloController.text.isEmpty ||
        _cantidadController.text.isEmpty ||
        _caducidadController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    try {
      await _firestore.collection('donaciones').doc(_editDonacionId).update({
        'provincia': _provincia,
        'codigoCentro': _codigoCentro,
        'articulo': _articuloController.text,
        'cantidad': _cantidadController.text,
        'caducidad': _caducidadController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Donación actualizada exitosamente')),
      );

      _limpiarCampos();
      // Recargar las donaciones para actualizar la tabla
      _cargarDonaciones(_codigoCentro!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar donación: $e')),
      );
    }
  }

  // Función para eliminar la donación seleccionada
  Future<void> _eliminarDonacion() async {
    if (_selectedDonacionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, selecciona una donación para eliminar')),
      );
      return;
    }

    try {
      await _firestore.collection('donaciones').doc(_selectedDonacionId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Donación eliminada exitosamente')),
      );

      _limpiarCampos();
      // Recargar las donaciones para actualizar la tabla
      _cargarDonaciones(_codigoCentro!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar donación: $e')),
      );
    }
  }

  // Función para limpiar los campos y salir del modo de edición
  void _limpiarCampos() {
    setState(() {
      _articuloController.clear();
      _cantidadController.clear();
      _caducidadController.text = '00/00/0000';
      _editDonacionId = null;
      _selectedDonacionId = null;
    });
  }

  // Función para mostrar el diálogo con la tabla estilizada
  void _mostrarDialogoDonaciones() {
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
                      'Donaciones del Centro',
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
                _buildAnimatedBackground(),
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
                          _buildDropdownField('Provincia', _provincias, onChanged: (value) {
                            setState(() {
                              _provincia = value;
                              _cargarCodigosCentros(value!);
                              _limpiarCampos();
                            });
                          }),
                          _buildDropdownField('CÓDIGO DEL CENTRO', _codigosCentros, onChanged: (value) {
                            setState(() {
                              _codigoCentro = value;
                              if (value != null) {
                                _cargarDonaciones(value);
                              } else {
                                _donaciones = [];
                              }
                              _limpiarCampos();
                            });
                          }, value: _codigoCentro),
                          _buildTextField('ARTÍCULO', _articuloController),
                          _buildTextField('CANTIDAD', _cantidadController),
                          _buildTextField('CADUCIDAD', _caducidadController),
                          SizedBox(height: 20),
                          _buildDonacionesTable(),
                          SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildNeonButton('AGREGAR', onTap: _agregarDonacion),
                              _buildNeonButton('ELIMINAR SELECCIONADA', onTap: _eliminarDonacion),
                              _buildNeonButton('VISUALIZAR EN DIÁLOGO', onTap: _mostrarDialogoDonaciones),
                              if (_editDonacionId != null) // Mostrar el botón "ACTUALIZAR" solo si estás editando
                                _buildNeonButton('ACTUALIZAR', onTap: _actualizarDonacion),
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
          labelStyle: TextStyle(color: Colors.black87),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        style: TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }

  Widget _buildDonacionesTable() {
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
              _buildTableHeader('Acción', Colors.black),
            ],
          ),
          SizedBox(height: 10),
          ..._donaciones.map((item) => _buildTableRow(item)).toList(),
          if (_donaciones.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'No hay donaciones para este centro.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStyledTable() {
    return Container(
      constraints: BoxConstraints(maxHeight: 400),
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
            DataColumn(
              label: Text(
                'Acción',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          rows: _donaciones.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> item = entry.value;
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
                DataCell(
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _editDonacionId = item['id'];
                        _articuloController.text = item['articulo'];
                        _cantidadController.text = item['cantidad'];
                        _caducidadController.text = item['caducidad'];
                      });
                      Navigator.of(context).pop(); // Cerrar el diálogo
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF59E0B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Editar',
                      style: TextStyle(color: Colors.white),
                    ),
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

  Widget _buildTableRow(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDonacionId = item['id'];
        });
      },
      child: Container(
        color: _selectedDonacionId == item['id'] ? Colors.blue.shade100 : Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTableCell(item['codigo']!),
            _buildTableCell(item['articulo']!),
            _buildTableCell(item['cantidad']!),
            _buildTableCell(item['caducidad']!),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _editDonacionId = item['id'];
                    _articuloController.text = item['articulo'];
                    _cantidadController.text = item['cantidad'];
                    _caducidadController.text = item['caducidad'];
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF59E0B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Editar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
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