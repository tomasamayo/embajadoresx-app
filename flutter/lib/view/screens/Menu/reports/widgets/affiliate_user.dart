import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

import '../../../../../controller/report_controller.dart';
import '../../../../../utils/colors.dart';

class AffiliateUser extends StatefulWidget {
  final ReportController controller;
  const AffiliateUser({super.key, required this.controller});

  @override
  State<AffiliateUser> createState() => _AffiliateUserState();
}

class _AffiliateUserState extends State<AffiliateUser> {
  var dataMap = <String, double>{
    "Flutter": 5,
    "light": 4,
  };
  var colorList = <Color>[
    const Color.fromRGBO(33, 150, 243, 1),
    Color.fromARGB(255, 156, 243, 33),
  ];
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
      random.nextInt(200) + 55, // Adjusted range for red channel (55-255)
      random.nextInt(200) + 55, // Adjusted range for green channel (55-255)
      random.nextInt(200) + 55, // Adjusted range for blue channel (55-255)
    );
  });
  return randomColors;
}

  @override
  void initState() {
    super.initState();
    dataMap = convertIntMapToDouble(
        widget.controller.ReportData!.data.statistics.affiliateUser!);
    colorList = generateRandomColorList(
        widget.controller.ReportData!.data.statistics.affiliateUserCount!);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    var bannModel = widget.controller.ReportData!.data.statistics;
    dataMap = convertIntMapToDouble(bannModel.affiliateUser!);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          itemList(
            width,
            'Usuarios Referidos por País',
            bannModel.affiliateUserCount.toString(),
          ),
          const SizedBox(height: 50),
          PieChart(
             chartRadius: 180,
            dataMap: dataMap,
            ringStrokeWidth: 50,
            chartType: ChartType.ring,
            baseChartColor: AppColor.appGrey.withOpacity(0.5),
            colorList: colorList,
            chartValuesOptions: ChartValuesOptions(
              showChartValuesInPercentage: true,
            ),
            totalValue: widget
                .controller.ReportData!.data.statistics.affiliateUserCount!
                .toDouble(),
          ),
        ],
      ),
    );
  }

  Widget itemList(width, text1, text2) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text1,
            style: TextStyle(
                fontFamily: 'Poppin',
                fontSize: width * 0.06,
                color: AppColor.appBlack,
                fontWeight: FontWeight.w300),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.appSuperPrimaryLight,
                borderRadius: BorderRadius.circular(width * 0.01),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13.0),
                child: Text(
                  text2,
                  style: TextStyle(
                      fontFamily: 'Poppin',
                      fontSize: width * 0.06,
                      color: AppColor.appBlack,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
