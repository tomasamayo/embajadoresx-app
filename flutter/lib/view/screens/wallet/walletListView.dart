import 'package:flutter/material.dart';
import 'package:affiliatepro_mobile/controller/wallet_controller.dart';

import '../../../utils/colors.dart';
import 'listComponents/list_card.dart';

class WalletTransactionsListView extends StatelessWidget {
  const WalletTransactionsListView({super.key, required this.controller});

  final WalletController controller;

  @override
  Widget build(BuildContext context) {
    var bannModel = controller.walletData?.data.transaction ?? [];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Container(
        // Decoration removed to match the transparent/individual card style
        child: bannModel.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 0),
                physics: const NeverScrollableScrollPhysics(), // Scroll handled by parent
                itemCount: bannModel.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 4), // Reduced padding
                    child: WalletCard(
                      data: bannModel[index],
                    ),
                  );
                },
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 60,
                        color: AppColor.appGrey.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No hay transacciones",
                        style: TextStyle(
                          color: AppColor.appGrey,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
