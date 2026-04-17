import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:affiliatepro_mobile/utils/colors.dart' as app_colors;

class WeeklyGrowthChartWidget extends StatefulWidget {
  final List<double> weeklyData;

  const WeeklyGrowthChartWidget({
    super.key,
    required this.weeklyData, // Ahora es obligatorio recibir los datos
  });

  @override
  State<WeeklyGrowthChartWidget> createState() => _WeeklyGrowthChartWidgetState();
}

class _WeeklyGrowthChartWidgetState extends State<WeeklyGrowthChartWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color neonGreen = Color(0xFF00FF88);
    const Color neonRed = Color(0xFFFF0000); // Rojo Neón para "Sin actividad"

    // 1. Lógica de Color Dinámico: 
    // Evaluamos si todos los valores son 0 o si la lista está vacía
    final bool isAllZero = widget.weeklyData.isEmpty || widget.weeklyData.every((val) => val == 0);
    
    // 2. Lógica de Balance: Rojo si es 0, Verde Neón si hay ganancias
    final Color chartColor = isAllZero ? neonRed : neonGreen;

    // TAREA 1 (v3.3.0): Sincronización DINÁMICA con DateTime.now()
    // Identificamos el día actual del sistema (1 = Lunes, ..., 6 = Sábado, 7 = Domingo)
    final DateTime now = DateTime.now();
    final int systemWeekday = now.weekday; // 1-7
    
    // Mapeo para fl_chart (donde Lunes es índice 0 y Domingo es índice 6)
    final int currentDayIndex = systemWeekday - 1; 

    // Aseguramos que la lista tenga 7 elementos para la gráfica semanal
    // El backend suele enviar una lista de 7 valores. Si el pico está desplazado,
    // es porque el backend envía los últimos 7 días terminando en HOY.
    final List<double> displayData = widget.weeklyData.length >= 7 
        ? widget.weeklyData.sublist(0, 7) 
        : [...widget.weeklyData, ...List.filled(7 - widget.weeklyData.length, 0.0)];

    final List<double> rawData = displayData.take(7).toList();
    
    // TAREA 1 & 2 (v3.3.0): Alineación dinámica del pico y reseteo de días futuros
    final List<FlSpot> spots = [];
    
    // Si el backend envía los datos ordenados de Lunes a Domingo (fijo):
    for (int i = 0; i < 7; i++) {
      double value = (i < rawData.length) ? rawData[i].toDouble() : 0.0;
      
      // REGLA: Si el índice es mayor al día actual del sistema, es un día futuro.
      // Forzamos 0 para evitar "montañas" en el Domingo si hoy es Sábado.
      if (i > currentDayIndex) {
        value = 0.0;
      }
      
      spots.add(FlSpot(i.toDouble(), value));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 0.0, right: 0.0, bottom: 25.0), // REQUERIMIENTO V1.2.1.1: Padding lateral eliminado
      child: AspectRatio(
        aspectRatio: 2.2,
        child: SizeTransition(
          sizeFactor: _animation,
          axis: Axis.horizontal,
          axisAlignment: -1.0,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40, // REQUERIMIENTO V1.2.1.1: Espacio reservado para etiquetas
                    interval: 1.0, // REQUERIMIENTO V1.2.1: Intervalo FORZADO a 1.0 para evitar duplicidad de letras
                    getTitlesWidget: (value, meta) {
                      // REQUERIMIENTO V1.2.2 (Hotfix): Solo valores enteros exactos entre 0 y 6 para evitar duplicidad de 'D'
                      if (value % 1 != 0 || value < 0 || value > 6) {
                        return const SizedBox.shrink();
                      }

                      const style = TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        fontFamily: 'Poppins',
                      );
                      String text = '';
                      switch (value.toInt()) {
                        case 0: text = 'L'; break;
                        case 1: text = 'M'; break;
                        case 2: text = 'M'; break;
                        case 3: text = 'J'; break;
                        case 4: text = 'V'; break;
                        case 5: text = 'S'; break;
                        case 6: text = 'D'; break;
                        default: return const SizedBox.shrink(); 
                      }
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 10,
                        child: Text(text, style: style),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: -0.6, // REQUERIMIENTO V1.2.2: Ajuste para visibilidad total con padding (Hotfix)
              maxX: 6.6,  // REQUERIMIENTO V1.2.2: Ajuste para visibilidad total con padding (Hotfix)
              minY: 0,
              maxY: isAllZero ? 10 : (rawData.reduce((a, b) => a > b ? a : b) * 1.5),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.4,
                  gradient: LinearGradient(
                    colors: [
                      chartColor,
                      chartColor.withOpacity(0.8),
                    ],
                  ),
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        chartColor.withOpacity(0.2), // Resplandor más sutil
                        chartColor.withOpacity(0.05),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: Colors.black.withOpacity(0.8),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        '\$${spot.y.toStringAsFixed(2)}',
                        TextStyle(color: chartColor, fontWeight: FontWeight.bold),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
