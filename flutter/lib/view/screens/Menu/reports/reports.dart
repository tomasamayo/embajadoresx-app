import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:affiliatepro_mobile/controller/report_controller.dart';
import 'package:affiliatepro_mobile/utils/colors.dart';
import 'package:affiliatepro_mobile/utils/text.dart';
import 'package:affiliatepro_mobile/view/screens/Menu/reports/shimmer_widget.dart';
import 'package:affiliatepro_mobile/view/screens/Menu/reports/widgets/click_by_country.dart';
import 'package:affiliatepro_mobile/view/screens/Menu/reports/widgets/sale_by_country.dart';
import '../../../../controller/dashboard_controller.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  void initState() {
    if (!Get.isRegistered<ReportController>()) {
      Get.put(ReportController(preferences: Get.find<DashboardController>().preferences));
    }
    Get.find<ReportController>().getReportData(1, 100);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return GetBuilder<ReportController>(
      builder: (ReportController) {
        if (ReportController.isLoading || ReportController.isReportLoading) {
          return ReportsShimmerWidget(
            controller: ReportController,
          );
        } else {
          var ReportModel = ReportController.ReportData;
          return Scaffold(
            backgroundColor: const Color(0xFF0F1210), // Fondo oscuro
            body: Stack(
              children: [
                // Background Gradient
                Positioned(
                  top: -200,
                  right: -100,
                  child: Container(
                    width: 500,
                    height: 500,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.6,
                        colors: [
                          AppColor.appPrimary.withOpacity(0.3),
                          AppColor.appPrimary.withOpacity(0.05),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                
                Column(
                  children: [
                    // Custom AppBar
                    AppBar(
                      foregroundColor: AppColor.appWhite,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      toolbarHeight: height * 0.08,
                      centerTitle: true,
                      title: Text(
                        AppText.reports,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      actions: [
                        Container(
                          height: width * 0.10,
                          width: width * 0.10,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: NetworkImage(Get.find<DashboardController>()
                                      .loginModel!
                                      .data!
                                      .profileAvatar!)),
                              color: AppColor.dashboardCardColor,
                              border: Border.all(color: Colors.white.withOpacity(0.2))
                          ),
                        ),
                        SizedBox(
                          width: width * 0.04,
                        )
                      ],
                    ),
                    
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: width * 0.04, vertical: height * 0.02),
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: height * 0.02,
                              ),
                              _buildSummaryGrid(width, ReportController),
                              SizedBox(
                                height: height * 0.03,
                              ),
                              Click(ReportController),
                              SizedBox(
                                height: height * 0.03,
                              ),
                              Sale(ReportController),
                              SizedBox(
                                height: height * 0.03,
                              ),
                              User(ReportController),
                              Empty(ReportController),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildSummaryGrid(double width, ReportController controller) {
    var stats = controller.ReportData?.data.statistics;
    int clicks = stats?.clicksCount ?? 0;
    int sales = stats?.saleCount ?? 0;
    
    // Calculate Conversion Rate (avoid division by zero)
    double conversionRate = clicks > 0 ? (sales / clicks) * 100 : 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            width, 
            "CLICS TOTALES", 
            "$clicks", 
            Icons.ads_click,
            AppColor.appPrimary
          ),
        ),
        SizedBox(width: width * 0.04),
        Expanded(
          child: _buildSummaryCard(
            width, 
            "CONVERSIÓN", 
            "${conversionRate.toStringAsFixed(1)}%", 
            Icons.trending_up,
            Colors.blueAccent // Or another accent color
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(double width, String title, String value, IconData icon, Color accentColor) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                    letterSpacing: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget Empty(ReportController ReportController) {
    var stats = ReportController.ReportData?.data.statistics;
    if ((stats?.clicks?.isEmpty ?? true) &&
        (stats?.affiliateUser == null || stats!.affiliateUser!.isEmpty) &&
        (stats?.sale?.isEmpty ?? true)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: 60,
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Sin Reportes",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "No hay datos disponibles por el momento.",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget Click(ReportController ReportController) {
    if (ReportController.ReportData?.data.statistics.clicks?.isEmpty ?? true) {
      return Container();
    } else {
      return ClickByCountry(
        controller: ReportController,
      );
    }
  }

  Widget User(ReportController ReportController) {
    if (ReportController.ReportData?.data.statistics.affiliateUser == null ||
        ReportController.ReportData!.data.statistics.affiliateUser!.isEmpty) {
      return Container();
    } else {
      return ClickByCountry(
        controller: ReportController,
        title: 'Usuarios por País',
      );
    }
  }

  Widget Sale(ReportController ReportController) {
    if (ReportController.ReportData?.data.statistics.sale?.isEmpty ?? true) {
      return Container();
    } else {
      return SaleByCountry(
        controller: ReportController,
      );
    }
  }
}
