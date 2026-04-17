import 'package:flutter/material.dart';
import 'package:affiliatepro_mobile/model/wallet_model.dart';
import 'package:affiliatepro_mobile/utils/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WalletDataTripplets extends StatelessWidget {
  const WalletDataTripplets({super.key, required this.model});
  final WalletModel model;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.5,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildMetricCard(
            "SALDO", 
            "\$${model.data.userTotals.userBalance}", 
            FontAwesomeIcons.wallet,
            Colors.green
          ),
          _buildMetricCard(
            "BALANCE PAGADO", 
            "\$${model.data.walletUnpaidAmount}", 
            FontAwesomeIcons.circleDollarToSlot,
            Colors.green
          ),
          _buildMetricCard(
            "ACCIONES", 
            "${model.data.userTotals.clickActionTotal.toInt()}/\$${model.data.userTotals.clickActionTotal}", 
            FontAwesomeIcons.arrowTrendUp,
            Colors.green
          ),
          _buildMetricCard(
            "CLICS", 
            "${model.data.userTotals.totalClicksCount.toInt()}/\$${model.data.userTotals.totalClicksCommission}", 
            FontAwesomeIcons.arrowPointer,
            Colors.green
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF002200), // Dark Green Neon
            const Color(0xFF000000), // Black
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.appPrimary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColor.appPrimary, // Vibrant Green Neon
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Center(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColor.appWhite,
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: -0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 5), 
        ],
      ),
    );
  }
}
