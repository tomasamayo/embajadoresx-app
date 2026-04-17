import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:affiliatepro_mobile/controller/Payments_controller.dart';
import 'package:affiliatepro_mobile/utils/colors.dart';
import 'package:affiliatepro_mobile/utils/text.dart';
import 'package:affiliatepro_mobile/view/screens/Menu/payments/paymentsListView.dart';
import 'package:affiliatepro_mobile/view/screens/Menu/payments/shimmer_widget.dart';
import 'package:affiliatepro_mobile/view/screens/Menu/payments/widgets/numberAdjuster.dart';
import '../../../../controller/dashboard_controller.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  @override
  void initState() {
    if (!Get.isRegistered<PaymentsController>()) {
      Get.put(PaymentsController(preferences: Get.find<DashboardController>().preferences));
    }
    Get.find<PaymentsController>().getPaymentsData();
    super.initState();
  }

  refresh(int pageId, int perPage) {
    Get.find<PaymentsController>().getPaymentsData();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return GetBuilder<PaymentsController>(
      builder: (PaymentsController) {
        if (PaymentsController.isLoading ||
            PaymentsController.isPaymentsLoading) {
          return PaymentsShimmerWidget(
            controller: PaymentsController,
          );
        } else {
          // ignore: non_constant_identifier_names
          var PaymentsModel = PaymentsController.PaymentsData;
          return Scaffold(
            backgroundColor: const Color(0xFF0F1210),
            body: Stack(
              children: [
                // Background Gradient
                Positioned(
                  top: -150,
                  right: -100,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.6,
                        colors: [
                          AppColor.appPrimary.withOpacity(0.25),
                          AppColor.appPrimary.withOpacity(0.05),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -150,
                  left: -100,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.6,
                        colors: [
                          AppColor.appPrimary.withOpacity(0.15),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
                
                Column(
                  children: [
                    AppBar(
                      foregroundColor: AppColor.appWhite,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      toolbarHeight: height * 0.08,
                      centerTitle: true,
                      title: Text(
                        AppText.my_payments,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
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
                    NumberAdjuster(
                      paymentsController: PaymentsController,
                    ),
                    Expanded(
                      child: PaymentsListView(
                        controller: PaymentsController,
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
}
