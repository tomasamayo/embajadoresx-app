import 'package:flutter/material.dart';

import '../../../utils/colors.dart';
import '../../../utils/text.dart';
import '../../base/custom_app_bar.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.dashboardBgColor,
      body: Column(children: <Widget>[
        CustomAppBar(
          title: AppText.payment,
          isProfile: true,
        ),
      ]),
    );
  }
}
