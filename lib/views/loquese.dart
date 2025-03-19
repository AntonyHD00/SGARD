import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
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
                              '2,500',
                              Icons.volunteer_activism,
                            ),
                            _buildStatCard(
                              'Centros Activos',
                              '6',
                              Icons.location_city,
                            ),
                            _buildStatCard(
                              'Artículos Más Donados',
                              'Arroz',
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
                        Center(child: _buildNeonButton('VER DETALLES')),
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
            'Donaciones por Centro',
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
                maxY: 1000,
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
                        switch (value.toInt()) {
                          case 0:
                            return Text('Consuelo', style: style);
                          case 1:
                            return Text('SPM', style: style);
                          case 2:
                            return Text('Los Llanos', style: style);
                          case 3:
                            return Text('Quisqueya', style: style);
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
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(toY: 500, color: Color(0xFFDC2626)),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(toY: 800, color: Color(0xFFF59E0B)),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(toY: 300, color: Color(0xFF1E3A8A)),
                    ],
                  ),
                  BarChartGroupData(
                    x: 3,
                    barRods: [
                      BarChartRodData(toY: 600, color: Color(0xFFDC2626)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
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
                sections: [
                  PieChartSectionData(
                    value: 40,
                    title: 'Arroz',
                    color: Color(0xFFDC2626),
                    titleStyle: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: 30,
                    title: 'Habichuelas',
                    color: Color(0xFFF59E0B),
                    titleStyle: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: 20,
                    title: 'Aceite',
                    color: Color(0xFF1E3A8A),
                    titleStyle: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: 10,
                    title: 'Otros',
                    color: Colors.grey,
                    titleStyle: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
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
                maxY: 1000,
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      FlSpot(0, 300),
                      FlSpot(1, 500),
                      FlSpot(2, 400),
                      FlSpot(3, 700),
                      FlSpot(4, 600),
                      FlSpot(5, 800),
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

  Widget _buildNeonButton(String text) {
    return GestureDetector(
      onTap: () {},
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
