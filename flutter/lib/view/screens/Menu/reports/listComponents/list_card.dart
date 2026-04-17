import 'package:flutter/material.dart';

import '../../../../../model/reports_model.dart';
import '../../../../../utils/colors.dart';
import '../../../wallet/components/dateConverter.dart';

class ReportsCard extends StatelessWidget {
  Transaction data;
  ReportsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      // height: width * 0.5,
      width: width * 0.43,
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: AppColor.appWhite,
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(-3, -3),
          ),
          BoxShadow(
            color: AppColor.appShadow,
            spreadRadius: 2,
            blurRadius: 3,
            offset: Offset(3, 4),
          ),
        ],
        color: AppColor.appPrimaryLight,
        borderRadius: BorderRadius.circular(width * 0.06),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.01),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    convertSnakeCaseToTitleCase(data.type),
                    style: TextStyle(
                        fontFamily: 'Poppin',
                        fontSize: width * 0.05,
                        color: AppColor.appPrimary,
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              itemList(
                width,
                'ID',
                data.id,
              ),
              itemList(
                width,
                'Pago',
                data.paymentMethod == null ? 'No Pagado' : 'Pagado',
              ),
              itemList(
                width,
                'Estado',
                data.status == '1' ? 'En Billetera' : 'En Espera',
              ),
              itemList(
                width,
                'Comisión',
                data.amount,
              ),
              itemList(
                width,
                'Fecha',
                formatDate(data.createdAt),
              ),
            ],
          ),
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
                fontFamily: 'Poppin',
                fontSize: width * 0.03,
                color: AppColor.appPrimary,
                fontWeight: FontWeight.w300),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.appSuperPrimaryLight,
                borderRadius: BorderRadius.circular(width * 0.01),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13.0),
                child: Text(
                  text2,
                  style: TextStyle(
                      fontFamily: 'Poppin',
                      fontSize: width * 0.03,
                      color: AppColor.appPrimary,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
