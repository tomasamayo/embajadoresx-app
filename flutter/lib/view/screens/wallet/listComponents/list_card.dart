import 'package:flutter/material.dart';
import 'package:affiliatepro_mobile/view/screens/wallet/listComponents/card_detail.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../utils/colors.dart';
import '../../../../model/wallet_model.dart';

class WalletCard extends StatelessWidget {
  Transaction data;
  WalletCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    
    showbottomSheet() {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
              ),
              height: width * 1.5,
              child: Center(
                child: SizedBox(
                  height: width,
                  child: WalletCardDetail(data: data),
                ),
              ),
            ),
          );
        },
      );
    }

    return GestureDetector(
      onTap: showbottomSheet,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E), // Dark card background
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.appPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconForType(data.type),
                color: AppColor.appPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 15),
            
            // Title and Date/ID
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.displayTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getCustomerName(),
                        style: const TextStyle(
                          color: Colors.white, // Brighter username
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Amount and Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  data.displayAmount,
                  style: TextStyle(
                    color: data.isIncome ? AppColor.appPrimary : Colors.redAccent, // Green for income, Red for expenses
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.normal, // Clean/Formal font
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: data.isStatusCompleted 
                          ? AppColor.appPrimary 
                          : data.isStatusRejected 
                              ? const Color(0xFFFF00FF) // Rejected: Fuchsia Neon
                              : AppColor.appPrimary.withOpacity(0.5), // Pending: Soft Green Neon
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    data.statusText,
                    style: TextStyle(
                      color: data.isStatusCompleted 
                          ? AppColor.appPrimary 
                          : data.isStatusRejected 
                              ? const Color(0xFFFF00FF) 
                              : Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    if (type.contains('sale')) return FontAwesomeIcons.bagShopping;
    if (type.contains('click')) return FontAwesomeIcons.arrowPointer;
    if (type.contains('action')) return FontAwesomeIcons.bolt;
    return FontAwesomeIcons.wallet;
  }

  String _getCustomerName() {
    final first = data.firstname.trim();
    final last = data.lastname.trim();
    final username = data.username.trim();

    if (username.isNotEmpty) return username;
    if (first.isEmpty && last.isEmpty) return 'Sin nombre';

    return ('$first $last').trim();
  }

  Widget itemList(width, text1, text2) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text1,
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: width * 0.035,
                color: AppColor.appGrey,
                fontWeight: FontWeight.w300),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColor.appPrimaryLight,
              borderRadius: BorderRadius.circular(width * 0.02),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
              child: Text(
                text2,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: width * 0.035,
                    color: AppColor.appWhite,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
