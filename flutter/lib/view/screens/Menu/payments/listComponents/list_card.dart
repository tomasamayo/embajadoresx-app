import 'package:flutter/material.dart';
import '../../../../../model/Payments_model.dart';
import '../../../../../utils/colors.dart';
import 'card_detail.dart';

class PaymentsCard extends StatelessWidget {
  PaymentsData data;
  PaymentsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    showbottomSheet() {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return FractionallySizedBox(
            heightFactor: 0.55,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1A1D1A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.only(top: 12, bottom: 20),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Detalles del Pago",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 25),
                  Expanded(
                    child: CardDetail(data: data),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return GestureDetector(
      onTap: () {
        showbottomSheet();
      },
      child: Container(
        width: width,
        padding: EdgeInsets.all(width * 0.05),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColor.appPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.payments_outlined,
                        color: AppColor.appPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '\$${data.price}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColor.appPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    data.module.toString().toUpperCase(),
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.category_outlined,
                      color: Colors.white.withOpacity(0.4),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Módulo',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
                Text(
                  '#${data.id}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String convertSnakeCaseToTitleCase(String input) {
    List<String> words = input.split('_');
    List<String> capitalizedWords = [];

    for (String word in words) {
      String capitalizedWord = word[0].toUpperCase() + word.substring(1);
      capitalizedWords.add(capitalizedWord);
    }

    return capitalizedWords.join(' ');
  }

  Widget itemList(width, text1, text2) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text1,
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: width * 0.032,
                color: AppColor.appGrey,
                fontWeight: FontWeight.w400),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColor.appPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(width * 0.05),
              ),
              child: Text(
                text2,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: width * 0.03,
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
