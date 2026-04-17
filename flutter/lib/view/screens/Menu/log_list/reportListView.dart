import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/loglist_controller.dart';
import '../../../../controller/dashboard_controller.dart';
import '../../../../utils/colors.dart';
import 'listComponents/list_card.dart';
import '../../../../model/loglist_model.dart';

class LoglistListView extends StatelessWidget {
  const LoglistListView({super.key, required this.controller});

  final LoglistController controller;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var bannModel = controller.LoglistData!.data.clicks;
    final List<Click> unique = [];
    final Set<String> seen = {};
    for (final c in bannModel) {
      final key = '${c.clickType.trim().toLowerCase()}|${c.baseUrl.trim().toLowerCase()}';
      if (!seen.contains(key)) {
        seen.add(key);
        unique.add(c);
      }
    }

    final dash = Get.find<DashboardController>();
    final isVendor = dash.loginModel?.data?.isVendor == "1";
    List<Click> visible = unique;
    String? storeUrl;
    String? resellerUrl;

    if (isVendor) {
      storeUrl = dash.dashboardData?.data.affiliateStoreUrl;
      resellerUrl = dash.dashboardData?.data.uniqueResellerLink;
      if ((storeUrl != null && storeUrl.isNotEmpty) ||
          (resellerUrl != null && resellerUrl.isNotEmpty)) {
        visible = unique.where((c) {
          final url = c.baseUrl.trim();
          if (storeUrl != null && storeUrl.isNotEmpty && url == storeUrl) {
            return true;
          }
          if (resellerUrl != null &&
              resellerUrl.isNotEmpty &&
              url == resellerUrl) {
            return true;
          }
          return false;
        }).toList();
      }
    }

    String? _titleFor(Click c) {
      if (!isVendor) return null;
      final url = c.baseUrl.trim();
      if (storeUrl != null && storeUrl.isNotEmpty && url == storeUrl) {
        return "URL de la tienda";
      }
      if (resellerUrl != null && resellerUrl.isNotEmpty && url == resellerUrl) {
        return "Invitar a proveedores";
      }
      return null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: visible.isNotEmpty
          ? ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visible.length,
              itemBuilder: (context, index) {
                final click = visible[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: LoglistCard(
                    data: click,
                    titleOverride: _titleFor(click),
                  ),
                );
              },
            )
          : Container(
              padding: const EdgeInsets.symmetric(vertical: 80),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Icon(
                      Icons.history_outlined,
                      size: 80,
                      color: AppColor.appGrey.withOpacity(0.3),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Sin Registros",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
