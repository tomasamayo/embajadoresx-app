import 'package:flutter/material.dart';

import '../../../../../model/Orders_model.dart';
import '../../../../../utils/colors.dart';

class CardDetail extends StatefulWidget {
  Order data;
  CardDetail({super.key, required this.data});

  @override
  State<CardDetail> createState() => _CardDetailState();
}

class _CardDetailState extends State<CardDetail> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            _buildDetailItem(
              width,
              'ID del Pedido',
              '#${widget.data.id}',
              Icons.tag,
            ),
            _buildDetailItem(
              width,
              'Tipo de Comisión',
              widget.data.commissionType ?? 'N/A',
              Icons.account_balance_wallet_outlined,
            ),
            _buildDetailItem(
              width,
              'IDs de Producto',
              widget.data.productIds ?? 'N/A',
              Icons.inventory_2_outlined,
            ),
            _buildDetailItem(
              width,
              'Moneda',
              widget.data.currency ?? 'N/A',
              Icons.monetization_on_outlined,
            ),
            _buildDetailItem(
              width,
              'IP de Compra',
              widget.data.ip ?? 'N/A',
              Icons.lan_outlined,
            ),
            _buildDetailItem(
              width,
              'Código de País',
              widget.data.countryCode ?? 'N/A',
              Icons.public,
            ),
            _buildDetailItem(
              width,
              'URL de Referencia',
              widget.data.baseUrl ?? 'N/A',
              Icons.link,
            ),
            _buildDetailItem(
              width,
              'Usuario',
              widget.data.userName ?? 'N/A',
              Icons.person_outline,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(double width, String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.appPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColor.appPrimary,
              size: 18,
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
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
