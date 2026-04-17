import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

import '../../../../../controller/report_controller.dart';
import '../../../../../utils/colors.dart';

class SaleByCountry extends StatefulWidget {
  final ReportController controller;
  final String title;
  const SaleByCountry({super.key, required this.controller, this.title = 'Ventas por País'});

  @override
  State<SaleByCountry> createState() => _SaleByCountryState();
}

class _SaleByCountryState extends State<SaleByCountry> {
  var dataMap = <String, double>{};
  var colorList = <Color>[];
  int totalCount = 0;

  Map<String, double> convertIntMapToDouble(Map<String, int> intMap) {
    return intMap.map((key, value) => MapEntry(key, value.toDouble()));
  }

  List<Color> generateRandomColorList(int length) {
    Random random = Random();
    List<Color> randomColors = List.generate(length, (index) {
      if (index == 0) {
        return AppColor.appPrimary; // First color is constant
      }
      return Color.fromARGB(
        255,
        random.nextInt(150) + 50,
        random.nextInt(150) + 50,
        random.nextInt(150) + 50,
      );
    });
    return randomColors;
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didUpdateWidget(SaleByCountry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _initializeData();
    }
  }

  void _initializeData() {
    var bannModel = widget.controller.ReportData!.data.statistics;
    // Ensure sale is handled safely as a Map
    Map<String, int> sourceData = bannModel.sale ?? {};
    
    totalCount = bannModel.saleCount ?? 0;
    dataMap = convertIntMapToDouble(sourceData);
    colorList = generateRandomColorList(max(1, dataMap.length));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (dataMap.isEmpty) {
      return SizedBox();
    }
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.dashboardCardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColor.appPrimary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.monetization_on,
                      color: AppColor.appPrimary,
                      size: 16,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Text(
                  "$totalCount Total",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColor.appPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 30),

          // Chart with Center Text
          Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                chartRadius: width / 2.0,
                dataMap: dataMap,
                ringStrokeWidth: 24,
                chartType: ChartType.ring,
                baseChartColor: Colors.white.withOpacity(0.05),
                colorList: colorList,
                chartValuesOptions: const ChartValuesOptions(
                  showChartValues: false,
                ),
                legendOptions: const LegendOptions(
                  showLegends: false,
                ),
                totalValue: totalCount.toDouble(),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "100%", // Assuming total represents 100% of the dataset displayed
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    "DOMINIO",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: Colors.grey,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 30),

          // Custom Legend List
          _buildCustomLegend(),
        ],
      ),
    );
  }

  Widget _buildCustomLegend() {
    var entries = dataMap.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: List.generate(entries.length, (index) {
        var entry = entries[index];
        var color = colorList[index % colorList.length];
        var percentage = totalCount > 0 
            ? (entry.value / totalCount * 100).toStringAsFixed(1)
            : "0.0";

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 4,
                    )
                  ]
                ),
              ),
              SizedBox(width: 12),
              Text(
                entry.key,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "$percentage%",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColor.appPrimary,
                    ),
                  ),
                  Text(
                    "Volumen: ${entry.value.toInt()}",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
