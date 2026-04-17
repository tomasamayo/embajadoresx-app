import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:affiliatepro_mobile/utils/colors.dart';
import 'package:affiliatepro_mobile/utils/text.dart';
import 'package:affiliatepro_mobile/view/screens/Menu/payment_details/paymentDetailInputs.dart';
import 'package:affiliatepro_mobile/view/screens/Menu/payment_details/shimmer_widget.dart';
import '../../../../controller/dashboard_controller.dart';
import '../../../../controller/payments_detail_controller.dart';

class PaymentDetailPage extends StatefulWidget {
  const PaymentDetailPage({super.key});

  @override
  State<PaymentDetailPage> createState() => _PaymentDetailPageState();
}

class _PaymentDetailPageState extends State<PaymentDetailPage> {
  @override
  void initState() {
    // fetchPayment();
    super.initState();
  }
  fetchPayment() {
    Get.find<PaymentDetailController>().getPaymentsData();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return GetBuilder<PaymentDetailController>(
      builder: (PaymentDetailController) {
        if (PaymentDetailController.isLoading ||
            PaymentDetailController.isPaymentDetailLoading) {
          return PaymentDetailShimmerWidget(
            controller: PaymentDetailController,
          );
        } else {
          // ignore: non_constant_identifier_names
          var PaymentDetailModel = PaymentDetailController.PaymentDetailData;
          return Scaffold(
              backgroundColor: const Color(0xFF0F1210), // Fondo oscuro profundo
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
                      AppBar(
                        foregroundColor: AppColor.appWhite,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        toolbarHeight: height * 0.08,
                        centerTitle: true,
                        title: Text(
                          AppText.my_payment_detail,
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
                      Expanded(
                        child: PaymentDetailInputs(
                            paymentDetailController: PaymentDetailController),
                      ),
                    ],
                  ),
                ],
              ));
        }
      },
    );
  }
}
