import 'package:flutter/material.dart';
import '../../../../controller/orders_controller.dart';
import '../../../../utils/colors.dart';
import 'listComponents/list_card.dart';

class OrdersListView extends StatelessWidget {
  const OrdersListView({super.key, required this.controller});

  final OrderController controller;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var bannModel = controller.OrderData!.data.orders;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: bannModel.isNotEmpty
          ? ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // SingleChildScrollView handles scrolling
              itemCount: bannModel.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: OrdersCard(
                    data: bannModel[index],
                  ),
                );
              },
            )
          : SizedBox(
              height: height * 0.6,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 80,
                      color: AppColor.appGrey.withOpacity(0.3),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Sin Pedidos",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColor.appWhite,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "No hay pedidos realizados aún.",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: AppColor.appGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
