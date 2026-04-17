import 'package:flutter/material.dart';

import '../../../../controller/payments_detail_controller.dart';
import '../../../../utils/colors.dart';
import '../../Menu/payment_details/paymentDetail.dart';

class NotificationBar extends StatelessWidget {
  const NotificationBar({super.key, required this.controller});

  final PaymentDetailController controller;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var model = controller.PaymentDetailData;
    return model == null
        ? const SizedBox()
        : Builder(
            builder: (context) {
              final paymentMsg = model.data.notification!.paymentList == 'Bank details are not set!'
                  ? 'Los detalles bancarios no están configurados.'
                  : (model.data.notification!.paymentList ?? '');
              final paypalMsg = model.data.notification!.paypalAccounts == 'PayPal account details are not set!'
                  ? 'La cuenta PayPal no está configurada.'
                  : (model.data.notification!.paypalAccounts ?? '');
              final primaryMsg = model.data.notification!.primaryPaymentMethod == 'Primary payment method is not set!'
                  ? 'El método de pago principal no está definido.'
                  : (model.data.notification!.primaryPaymentMethod ?? '');
              final displayMsg = paymentMsg.isNotEmpty
                  ? paymentMsg
                  : (paypalMsg.isNotEmpty ? paypalMsg : primaryMsg);

              if (displayMsg.isEmpty) return const SizedBox();

              return ClipRRect(
                borderRadius: BorderRadius.circular(width * 0.04),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width * 0.04),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF141716), Color(0xFF141716)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: width * 0.02),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColor.appPrimary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.security, color: AppColor.appPrimary, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'Acción requerida',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PaymentDetailPage(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColor.appPrimary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Configurar',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
