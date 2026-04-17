import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../utils/colors.dart';
import '../../../../../utils/text.dart';
import '../../../../controller/payments_detail_controller.dart';

class PaymentDetailShimmerWidget extends StatelessWidget {
  const PaymentDetailShimmerWidget({super.key, required this.controller});

  final PaymentDetailController controller;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColor.dashboardBgColor,
      appBar: AppBar(
        backgroundColor: AppColor.dashboardBgColor,
        title: Text(AppText.my_payment_detail),
         automaticallyImplyLeading: false,
         centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.04, vertical: height * 0.03),
          child: SizedBox(
            height: height,
            child: ListView(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: height * 0.2,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width * 0.03)),
                  child: Shimmer.fromColors(
                      baseColor: Colors.grey.withOpacity(0.1),
                      highlightColor: Colors.white.withOpacity(0.3),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(width * 0.03)),
                      )),
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Container(
                  width: double.infinity,
                  height: height * 0.2,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width * 0.03)),
                  child: Shimmer.fromColors(
                      baseColor: Colors.grey.withOpacity(0.1),
                      highlightColor: Colors.white.withOpacity(0.3),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(width * 0.03)),
                      )),
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Container(
                  width: double.infinity,
                  height: height * 0.2,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width * 0.03)),
                  child: Shimmer.fromColors(
                      baseColor: Colors.grey.withOpacity(0.1),
                      highlightColor: Colors.white.withOpacity(0.3),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(width * 0.03)),
                      )),
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Container(
                  width: double.infinity,
                  height: height * 0.2,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width * 0.03)),
                  child: Shimmer.fromColors(
                      baseColor: Colors.grey.withOpacity(0.1),
                      highlightColor: Colors.white.withOpacity(0.3),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(width * 0.03)),
                      )),
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Container(
                  width: double.infinity,
                  height: height * 0.2,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width * 0.03)),
                  child: Shimmer.fromColors(
                      baseColor: Colors.grey.withOpacity(0.1),
                      highlightColor: Colors.white.withOpacity(0.3),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(width * 0.03)),
                      )),
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Container(
                  width: double.infinity,
                  height: height * 0.2,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width * 0.03)),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey.withOpacity(0.1),
                    highlightColor: Colors.white.withOpacity(0.3),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(width * 0.03)),
                    ),
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
