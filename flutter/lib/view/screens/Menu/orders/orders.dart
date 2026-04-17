import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:affiliatepro_mobile/utils/colors.dart';
import 'package:affiliatepro_mobile/utils/text.dart';
import 'package:affiliatepro_mobile/view/screens/Menu/orders/shimmer_widget.dart';
import '../../../../controller/dashboard_controller.dart';
import '../../../../controller/orders_controller.dart';
import 'ordersListView.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    if (!Get.isRegistered<OrderController>()) {
      Get.put(OrderController(preferences: Get.find<DashboardController>().preferences));
    }
    Get.find<OrderController>().getOrderData(1, 100);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return GetBuilder<OrderController>(
      builder: (OrderController) {
        if (OrderController.isLoading || OrderController.isOrderLoading) {
          return OrdersShimmerWidget(
            controller: OrderController,
          );
        } else {
          // ignore: non_constant_identifier_names
          var OrderModel = OrderController.OrderData;
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
                    AppBar(
                      foregroundColor: AppColor.appWhite,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      toolbarHeight: height * 0.08,
                      centerTitle: true,
                      title: Text(
                        AppText.my_orders,
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
                             OrdersListView(controller: OrderController,)
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
}
