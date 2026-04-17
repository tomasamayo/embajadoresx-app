import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:affiliatepro_mobile/controller/dashboard_controller.dart';

import '../../../../utils/colors.dart';
import '../../../../utils/text.dart';

class MembershipPlan extends StatelessWidget {
  const MembershipPlan({super.key, required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    // REQUERIMIENTO V13.0: Blindaje contra datos nulos durante la carga
    if (controller.dashboardData == null) {
      return Container(
        height: height * 0.2,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColor.appPrimaryLight,
          borderRadius: BorderRadius.circular(width * 0.06),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColor.appPrimary),
        ),
      );
    }

    var model = controller.loginModel!;
    var dashModel = controller.dashboardData!.data;
    var userPlan = dashModel.userPlan;

    // REQUERIMIENTO V15.0: Forzar Realidad del Plan Ultra
    // Usamos el RxString planName del controlador para asegurar reactividad inmediata
    bool isDataPending = userPlan.statusId == "0" && controller.planName.value.isEmpty;
    
    String displayPlanName = controller.planName.value.isNotEmpty 
        ? controller.planName.value 
        : (userPlan.planName.isNotEmpty ? userPlan.planName : "Sincronizando...");

    // Cálculo dinámico de días (Basado en expire_at real del JSON)
    String remainingTime;
    if (isDataPending) {
      remainingTime = "--";
    } else if (userPlan.isLifetime == "1") {
      remainingTime = "De por vida";
    } else {
      // REQUERIMIENTO V15.1: Cálculo de días considerando solo la fecha para precisión
      final now = DateTime.now();
      final date1 = DateTime(now.year, now.month, now.day);
      final date2 = DateTime(userPlan.expireAt.year, userPlan.expireAt.month, userPlan.expireAt.day);
      final difference = date2.difference(date1).inDays;
      remainingTime = difference <= 0 ? "EXPIRADO" : "$difference días";
    }

    // Estilo de Estado de Plan
    final bool isActive = userPlan.isActive == "1";
    final String statusText = isActive ? "ACTIVO" : "EXPIRADO";
    final Color statusColor = isActive ? const Color(0xFF00FF88) : Colors.redAccent;

    return Container(
      padding: EdgeInsets.all(width * 0.03),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(-2, -2),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(3, 4),
          ),
        ],
        color: AppColor.appPrimaryLight,
        borderRadius: BorderRadius.circular(width * 0.06),
      ),
      child: Column(children: <Widget>[
        Text(
          AppText.memberShipPlan,
          style: TextStyle(
            fontSize: width * 0.05,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: AppColor.appPrimary,
          ),
        ),
        Divider(color: AppColor.appGrey.withOpacity(0.2)),
        SizedBox(
          height: height * 0.01,
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.appSuperPrimaryLight,
                  borderRadius: BorderRadius.circular(width * 0.06),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    controller.convertDate(userPlan.startedAt),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColor.appWhite,
                        fontFamily: 'Poppins',
                        fontSize: width * 0.03,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: width * 0.02,
            ),
            Text(
              "a",
              style: TextStyle(fontSize: width * 0.035, color: AppColor.appGrey),
            ),
            SizedBox(
              width: width * 0.02,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.appSuperPrimaryLight,
                  borderRadius: BorderRadius.circular(width * 0.06),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    userPlan.isLifetime == "1" ? "∞" : controller.convertDate(userPlan.expireAt),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColor.appWhite,
                        fontFamily: 'Poppins',
                        fontSize: width * 0.03,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: height * 0.01,
        ),
        Divider(color: AppColor.appGrey.withOpacity(0.2)),
        SizedBox(
          height: height * 0.01,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Tiempo Restante ",
              style: TextStyle(
                  fontSize: width * 0.035,
                  color: AppColor.appWhite,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400),
            ),
            Text(
              remainingTime,
              style: TextStyle(
                  color: AppColor.appGrey,
                  fontSize: width * 0.04,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400),
            )
          ],
        ),
        SizedBox(
          height: height * 0.01,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Plan ",
              style: TextStyle(
                  fontSize: width * 0.035,
                  color: AppColor.appWhite,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400),
            ),
            Obx(() => Text(
              controller.planName.value.isNotEmpty ? controller.planName.value : "Sincronizando...",
              style: TextStyle(
                  color: AppColor.appGrey,
                  fontSize: width * 0.04,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400),
            ))
          ],
        ),
        SizedBox(
          height: height * 0.01,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Estado del Plan ",
              style: TextStyle(
                  fontSize: width * 0.035,
                  color: AppColor.appWhite,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: statusColor.withOpacity(0.5)),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                    color: statusColor,
                    fontSize: width * 0.03,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ]),
    );
  }
}
