import 'package:flutter/material.dart';
import '../../../../../model/Payments_model.dart';
import '../../../../../utils/colors.dart';
import '../../../wallet/components/dateConverter.dart';

class CardDetail extends StatefulWidget {
  PaymentsData data;
  CardDetail({super.key, required this.data});

  @override
  State<CardDetail> createState() => _CardDetailState();
}

class _CardDetailState extends State<CardDetail> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
        child: Column(
          children: [
            _buildDetailItem(Icons.category_outlined, 'Módulo', widget.data.module.toString()),
            _buildDetailItem(Icons.fingerprint, 'ID de Pago', '#${widget.data.id}'),
            _buildDetailItem(Icons.person_outline, 'ID de Usuario', widget.data.userId.toString()),
            _buildDetailItem(Icons.alternate_email, 'Usuario', widget.data.username.toString()),
            _buildDetailItem(Icons.attach_money, 'Monto Total', '\$${widget.data.price}', isHighlight: true),
            _buildDetailItem(Icons.account_balance_wallet_outlined, 'Pasarela', widget.data.paymentGateway.toString()),
            _buildDetailItem(Icons.info_outline, 'ID de Estado', widget.data.statusId.toString()),
            _buildDetailItem(Icons.calendar_today_outlined, 'Fecha y Hora', formatDate(widget.data.datetime)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, {bool isHighlight = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isHighlight ? AppColor.appPrimary : Colors.white).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isHighlight ? AppColor.appPrimary : Colors.white.withOpacity(0.7),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    color: isHighlight ? AppColor.appPrimary : Colors.white,
                    fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (isHighlight)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColor.appPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'USD',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  color: AppColor.appPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
