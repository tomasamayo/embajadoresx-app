import 'package:flutter/material.dart';
import '../../../../controller/Payments_controller.dart';
import '../../../../utils/colors.dart';
import 'listComponents/list_card.dart';

class PaymentsListView extends StatelessWidget {
  const PaymentsListView({super.key, required this.controller});

  final PaymentsController controller;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final model = controller.PaymentsData;
    final items = model?.data ?? const [];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: items.isNotEmpty
          ? ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PaymentsCard(
                    data: items[index],
                  ),
                );
              },
            )
          : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.payment_outlined,
                      size: 80,
                      color: AppColor.appGrey.withOpacity(0.3),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Sin Pagos",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColor.appWhite,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "No hay pagos registrados aún.",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: AppColor.appGrey,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
