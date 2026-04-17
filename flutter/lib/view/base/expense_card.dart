import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class ExpenseCard extends StatelessWidget {
  const ExpenseCard({super.key, required this.title, required this.data});

  final String title, data;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: width * 0.02),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(-1, -1),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(2, 2),
            ),
          ],
          color: AppColor.appPrimaryLight,
          borderRadius: BorderRadius.circular(20)),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: width * 0.04,
                  color: AppColor.appPrimary,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 4,
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                data,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: width * 0.035,
                    color: AppColor.appWhite,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400),
              ),
            )
          ]),
    );
  }
}
