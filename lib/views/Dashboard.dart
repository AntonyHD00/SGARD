import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // Variables para almacenar datos reales
  int _totalDonaciones = 0;
  int _centrosActivos = 0;
  String _articuloMasDonado = 'N/A';
  Map<String, int> _donacionesPorProvincia = {};
  Map<String, int> _distribucionArticulos = {};
  Map<String, int> _tendenciaDonaciones = {};

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

    // Cargar datos reales al iniciar
    _cargarDatos();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Función para cargar datos reales desde Firestore
  Future<void> _cargarDatos() async {
    try {
      // 1. Total de donaciones
      final donacionesSnapshot = await _firestore.collection('donaciones').get();
      setState(() {
        _totalDonaciones = donacionesSnapshot.docs.length;
      });

      // 2. Centros activos
      final centrosSnapshot = await _firestore.collection('centros_de_acopios').get();
      setState(() {
        _centrosActivos = centrosSnapshot.docs.length;
      });

      // 3. Artículo más donado y distribución de artículos
      Map<String, int> articulosCount = {};
      for (var doc in donacionesSnapshot.docs) {
        final articulo = doc['articulo'] as String;
        articulosCount[articulo] = (articulosCount[articulo] ?? 0) + 1;
      }
      setState(() {
        _distribucionArticulos = articulosCount;
        if (articulosCount.isNotEmpty) {
          _articuloMasDonado = articulosCount.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key;
        }
      });

      // 4. Donaciones por provincia
      Map<String, int> donacionesPorProvincia = {};
      for (var doc in donacionesSnapshot.docs) {
        final provincia = doc['provincia'] as String;
        donacionesPorProvincia[provincia] = (donacionesPorProvincia[provincia] ?? 0) + 1;
      }
      setState(() {
        _donacionesPorProvincia = donacionesPorProvincia;
      });

      // 5. Tendencia de donaciones (últimos 6 meses)
      Map<String, int> tendencia = {
        'Ene': 0,
        'Feb': 0,
        'Mar': 0,
        'Abr': 0,
        'May': 0,
        'Jun': 0,
      };
      final now = DateTime.now();
      for (var doc in donacionesSnapshot.docs) {
        final timestamp = (doc['timestamp'] as Timestamp?)?.toDate();
        if (timestamp != null) {
          final monthDiff = (now.year - timestamp.year) * 12 + now.month - timestamp.month;
          if (monthDiff >= 0 && monthDiff < 6) {
            final monthName = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'][5 - monthDiff];
            tendencia[monthName] = (tendencia[monthName] ?? 0) + 1;
          }
        }
      }
      setState(() {
        _tendenciaDonaciones = tendencia;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

  // Función para mostrar el diálogo de detalles
  void _mostrarDetalles() {
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
                      'Detalles de Donaciones por Provincia',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildDetallesTable(),
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
                    Icons.info,
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
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AnimatedOpacity(
                          duration: Duration(milliseconds: 1000),
                          opacity: _animation.value,
                          child: Text(
                            'DASHBOARD DE DONACIONES',
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatCard(
                              'Total Donaciones',
                              _totalDonaciones.toString(),
                              Icons.volunteer_activism,
                            ),
                            _buildStatCard(
                              'Centros Activos',
                              _centrosActivos.toString(),
                              Icons.location_city,
                            ),
                            _buildStatCard(
                              'Artículos Más Donados',
                              _articuloMasDonado,
                              Icons.local_dining,
                            ),
                          ],
                        ),
                        SizedBox(height: 40),
                        _buildBarChart(),
                        SizedBox(height: 40),
                        _buildPieChart(),
                        SizedBox(height: 40),
                        _buildLineChart(),
                        SizedBox(height: 40),
                        Center(child: _buildNeonButton('VER DETALLES', onTap: _mostrarDetalles)),
                      ],
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

  Widget _buildStatCard(String title, String value, IconData icon) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      width: 200,
      padding: EdgeInsets.all(20),
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
      child: Column(
        children: [
          Icon(icon, size: 40, color: Color(0xFFDC2626)),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(fontSize: 16, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
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
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    // Obtener las 4 provincias con más donaciones
    final sortedProvincias = _donacionesPorProvincia.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topProvincias = sortedProvincias.take(4).toList();

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
          Text(
            'Donaciones por Provincia',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: topProvincias.isNotEmpty
                    ? topProvincias.first.value.toDouble() + 10
                    : 100,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        );
                        if (value.toInt() < topProvincias.length) {
                          return Text(topProvincias[value.toInt()].key, style: style);
                        }
                        return Text('', style: style);
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(topProvincias.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: topProvincias[index].value.toDouble(),
                        color: [
                          Color(0xFFDC2626),
                          Color(0xFFF59E0B),
                          Color(0xFF1E3A8A),
                          Colors.grey,
                        ][index % 4],
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    // Obtener los 4 artículos más donados
    final sortedArticulos = _distribucionArticulos.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topArticulos = sortedArticulos.take(4).toList();
    final totalArticulos = _distribucionArticulos.values.reduce((a, b) => a + b);

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
          Text(
            'Distribución de Artículos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: topArticulos.isEmpty
                    ? [
                        PieChartSectionData(
                          value: 1,
                          title: 'Sin datos',
                          color: Colors.grey,
                          titleStyle: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ]
                    : topArticulos.asMap().entries.map((entry) {
                        int index = entry.key;
                        var articulo = entry.value;
                        return PieChartSectionData(
                          value: articulo.value.toDouble(),
                          title: '${articulo.key}\n${((articulo.value / totalArticulos) * 100).toStringAsFixed(1)}%',
                          color: [
                            Color(0xFFDC2626),
                            Color(0xFFF59E0B),
                            Color(0xFF1E3A8A),
                            Colors.grey,
                          ][index % 4],
                          titleStyle: TextStyle(fontSize: 14, color: Colors.white),
                        );
                      }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
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
          Text(
            'Tendencia de Donaciones (Últimos 6 Meses)',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        );
                        switch (value.toInt()) {
                          case 0:
                            return Text('Ene', style: style);
                          case 1:
                            return Text('Feb', style: style);
                          case 2:
                            return Text('Mar', style: style);
                          case 3:
                            return Text('Abr', style: style);
                          case 4:
                            return Text('May', style: style);
                          case 5:
                            return Text('Jun', style: style);
                          default:
                            return Text('', style: style);
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: _tendenciaDonaciones.values.isNotEmpty
                    ? _tendenciaDonaciones.values.reduce((a, b) => a > b ? a : b).toDouble() + 10
                    : 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      FlSpot(0, _tendenciaDonaciones['Ene']?.toDouble() ?? 0),
                      FlSpot(1, _tendenciaDonaciones['Feb']?.toDouble() ?? 0),
                      FlSpot(2, _tendenciaDonaciones['Mar']?.toDouble() ?? 0),
                      FlSpot(3, _tendenciaDonaciones['Abr']?.toDouble() ?? 0),
                      FlSpot(4, _tendenciaDonaciones['May']?.toDouble() ?? 0),
                      FlSpot(5, _tendenciaDonaciones['Jun']?.toDouble() ?? 0),
                    ],
                    isCurved: true,
                    color: Color(0xFFDC2626),
                    barWidth: 4,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetallesTable() {
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
                'Total Donaciones',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Artículo Más Donado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          rows: _donacionesPorProvincia.entries.map((entry) {
            final provincia = entry.key;
            final total = entry.value;

            // Calcular el artículo más donado en esta provincia
            Map<String, int> articulosProvincia = {};
            _firestore
                .collection('donaciones')
                .where('provincia', isEqualTo: provincia)
                .get()
                .then((snapshot) {
              for (var doc in snapshot.docs) {
                final articulo = doc['articulo'] as String;
                articulosProvincia[articulo] = (articulosProvincia[articulo] ?? 0) + 1;
              }
            });

            final articuloMasDonado = articulosProvincia.isNotEmpty
                ? articulosProvincia.entries
                    .reduce((a, b) => a.value > b.value ? a : b)
                    .key
                : 'N/A';

            return DataRow(
              color: MaterialStateColor.resolveWith((states) =>
                  _donacionesPorProvincia.keys.toList().indexOf(provincia) % 2 == 0
                      ? Colors.grey.shade100
                      : Colors.white),
              cells: [
                DataCell(
                  Text(
                    provincia,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
                DataCell(
                  Text(
                    total.toString(),
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
                DataCell(
                  Text(
                    articuloMasDonado,
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

  Widget _buildNeonButton(String text, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {},
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