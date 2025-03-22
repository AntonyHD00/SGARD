import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistroCentrosScreen extends StatefulWidget {
  @override
  _RegistroCentrosScreenState createState() => _RegistroCentrosScreenState();
}

class _RegistroCentrosScreenState extends State<RegistroCentrosScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final _formKey = GlobalKey<FormState>();
  String? _provincia = 'Azua';
  String? _codigoGenerado; // Variable para almacenar el código generado
  TextEditingController _municipioController = TextEditingController(text: '');
  TextEditingController _capacidadController = TextEditingController(text: '');
  TextEditingController _encargadoController = TextEditingController(text: '');

  // Instancia de Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Variable para almacenar el ID del documento que se está editando
  String? _editDocumentId;

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

    // Generar el código inicial para la provincia por defecto
    _generarCodigoCentro(_provincia!).then((codigo) {
      setState(() {
        _codigoGenerado = codigo;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _municipioController.dispose();
    _capacidadController.dispose();
    _encargadoController.dispose();
    super.dispose();
  }

  // Función para generar un código único para el centro de acopio
  Future<String> _generarCodigoCentro(String provincia) async {
    // Obtener el número de centros existentes (para todas las provincias)
    final querySnapshot = await _firestore.collection('centros_de_acopios').get();
    final count = querySnapshot.docs.length + 1; // Incrementar para el nuevo centro

    // Generar dos letras aleatorias para "YY"
    const letras = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = math.Random();
    final letra1 = letras[random.nextInt(letras.length)];
    final letra2 = letras[random.nextInt(letras.length)];
    final letrasAleatorias = '$letra1$letra2';

    // Generar las iniciales de la provincia (primeras 3 letras en mayúsculas)
    final provinciaAbrev = provincia.length >= 3
        ? provincia.substring(0, 3).toUpperCase()
        : provincia.toUpperCase();

    // Formato del código: CA-XXX-YY-PROV
    return 'CA-${count.toString().padLeft(3, '0')}-$letrasAleatorias-$provinciaAbrev';
  }

  // Función para registrar un nuevo centro
  Future<void> _registrarCentro() async {
    // Validar que todos los campos estén completos
    if (_provincia == null ||
        _municipioController.text.isEmpty ||
        _capacidadController.text.isEmpty ||
        _encargadoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    try {
      // Generar el código del centro
      final codigoCentro = await _generarCodigoCentro(_provincia!);

      // Guardar en Firestore
      await _firestore.collection('centros_de_acopios').add({
        'codigo': codigoCentro,
        'provincia': _provincia,
        'municipio': _municipioController.text,
        'capacidad': _capacidadController.text,
        'encargado': _encargadoController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Centro registrado exitosamente')),
      );

      // Limpiar los campos después de guardar
      _limpiarCampos();
    } catch (e) {
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar: $e')),
      );
    }
  }

  // Función para actualizar un centro existente
  Future<void> _actualizarCentro() async {
    if (_editDocumentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se ha seleccionado un centro para actualizar')),
      );
      return;
    }

    // Validar que todos los campos estén completos
    if (_provincia == null ||
        _municipioController.text.isEmpty ||
        _capacidadController.text.isEmpty ||
        _encargadoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    try {
      // Actualizar en Firestore
      await _firestore.collection('centros_de_acopios').doc(_editDocumentId).update({
        'provincia': _provincia,
        'municipio': _municipioController.text,
        'capacidad': _capacidadController.text,
        'encargado': _encargadoController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Centro actualizado exitosamente')),
      );

      // Limpiar los campos y salir del modo de edición
      _limpiarCampos();
      setState(() {
        _editDocumentId = null;
      });
    } catch (e) {
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }

  // Función para limpiar los campos y generar un nuevo código
  void _limpiarCampos() {
    _municipioController.clear();
    _capacidadController.clear();
    _encargadoController.clear();
    setState(() {
      _provincia = 'Azua';
      _editDocumentId = null;
      // Generar un nuevo código para la provincia por defecto
      _generarCodigoCentro(_provincia!).then((codigo) {
        setState(() {
          _codigoGenerado = codigo;
        });
      });
    });
  }

  // Función para mostrar el diálogo con los datos actuales
  void _mostrarDatos() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFFF59E0B)],
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Datos Ingresados',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
                SizedBox(height: 20),
                _buildDialogText('Código:', _codigoGenerado ?? 'No generado'),
                _buildDialogText('Provincia:', _provincia ?? 'No especificada'),
                _buildDialogText('Municipio / Ubicación:', _municipioController.text.isEmpty ? 'No especificado' : _municipioController.text),
                _buildDialogText('Capacidad:', _capacidadController.text.isEmpty ? 'No especificada' : _capacidadController.text),
                _buildDialogText('Encargado:', _encargadoController.text.isEmpty ? 'No especificado' : _encargadoController.text),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(); // Cierra el diálogo
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                        'Cerrar',
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Función para mostrar el diálogo con la lista de centros
  void _mostrarCentros() {
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
                      'Lista de Centros de Acopio',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      constraints: BoxConstraints(maxHeight: 400),
                      child: SingleChildScrollView(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: _firestore.collection('centros_de_acopios').snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            }
                            final centros = snapshot.data?.docs ?? [];
                            if (centros.isEmpty) {
                              return Center(child: Text('No hay centros registrados'));
                            }

                            return DataTable(
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
                                    'Provincia',
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
                              rows: centros.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                return DataRow(
                                  color: MaterialStateColor.resolveWith((states) =>
                                      centros.indexOf(doc) % 2 == 0 ? Colors.grey.shade100 : Colors.white),
                                  cells: [
                                    DataCell(
                                      Text(
                                        data['codigo'] ?? 'N/A',
                                        style: TextStyle(fontSize: 16, color: Colors.black87),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        data['provincia'] ?? 'N/A',
                                        style: TextStyle(fontSize: 16, color: Colors.black87),
                                      ),
                                    ),
                                    DataCell(
                                      ElevatedButton(
                                        onPressed: () {
                                          // Cargar los datos del centro en los campos
                                          setState(() {
                                            _editDocumentId = doc.id;
                                            _provincia = data['provincia'];
                                            _codigoGenerado = data['codigo'];
                                            _municipioController.text = data['municipio'] ?? '';
                                            _capacidadController.text = data['capacidad'] ?? '';
                                            _encargadoController.text = data['encargado'] ?? '';
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
                            );
                          },
                        ),
                      ),
                    ),
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
                    Icons.list,
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

  // Método auxiliar para construir las filas de texto en el diálogo
  Widget _buildDialogText(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AnimatedOpacity(
                            duration: Duration(milliseconds: 1000),
                            opacity: _animation.value,
                            child: Text(
                              'REGISTRO DE CENTROS DE ACOPIOS',
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
                                labelStyle: TextStyle(color: Colors.black87),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                              ),
                              value: _provincia,
                              items: _provincias.map((String item) {
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
                                setState(() {
                                  _provincia = value;
                                  // Generar un nuevo código cuando cambie la provincia (solo si no estás editando)
                                  if (_editDocumentId == null) {
                                    _generarCodigoCentro(value!).then((codigo) {
                                      setState(() {
                                        _codigoGenerado = codigo;
                                      });
                                    });
                                  }
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                          // Campo para mostrar el código generado (no editable)
                          AnimatedContainer(
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
                              readOnly: true, // No editable
                              initialValue: _codigoGenerado ?? 'Generando...',
                              decoration: InputDecoration(
                                labelText: 'Código del Centro',
                                labelStyle: TextStyle(color: Colors.black87),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              ),
                              style: TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                          ),
                          _buildTextField('Municipio / Ubicación', _municipioController),
                          _buildTextField('Capacidad', _capacidadController),
                          _buildTextField('Nombre del Coordinador / Encargado', _encargadoController),
                          SizedBox(height: 30),
                          _buildInfoCard(),
                          SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildNeonButton('REGISTRAR', onTap: _registrarCentro),
                              _buildNeonButton('MOSTRAR CENTROS', onTap: _mostrarCentros),
                              _buildNeonButton('VISUALIZAR', onTap: _mostrarDatos),
                              if (_editDocumentId != null) // Mostrar el botón "ACTUALIZAR" solo si estás editando
                                _buildNeonButton('ACTUALIZAR', onTap: _actualizarCentro),
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

  // Método para construir el botón con efecto neón
  Widget _buildNeonButton(String text, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: MouseRegion(
        onEnter: (_) => setState(() {}),
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

  // Método para construir el fondo animado
  Widget _buildAnimatedBackground() {
    return CustomPaint(
      painter: _BackgroundPainter(_animation.value),
      child: Container(),
    );
  }

  // Método para construir los campos de texto
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
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black87),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        style: TextStyle(fontSize: 16, color: Colors.black87),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  // Método para construir la tarjeta de información con capacidad dinámica
  Widget _buildInfoCard() {
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
      child: Text(
        'Con ${_capacidadController.text.isEmpty ? "una capacidad no especificada" : _capacidadController.text} y una variedad de productos que abarca desde alimentos frescos hasta materiales industriales, este centro de acopio es ideal para las necesidades logísticas que se puedan presentar.',
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
          height: 1.5,
          shadows: [
            Shadow(color: Colors.black12, offset: Offset(1, 1), blurRadius: 3),
          ],
        ),
        textAlign: TextAlign.center,
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