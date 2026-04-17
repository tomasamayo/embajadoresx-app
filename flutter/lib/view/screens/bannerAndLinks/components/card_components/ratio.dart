import 'package:flutter/material.dart';

import '../../../../../model/bannerAndLinks_model.dart';
import '../../../../../utils/colors.dart';

class Ratio extends StatelessWidget {
  BannerData data;
  Ratio({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        color: AppColor.appSuperPrimaryLight,
        borderRadius: BorderRadius.circular(width * 0.02),
      ),
      child: Padding(
        padding: EdgeInsets.all(width * 0.01),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           data.click_ratio != '' ?Row(
              children: [
                Text(
                  'Click: ',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: width * 0.033,
                      color: AppColor.appWhite,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  data.click_ratio.toString(),
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: width * 0.033,
                      color: AppColor.appGrey,
                      fontWeight: FontWeight.w300),
                ),
              ],
            ): Container(),
            data.sale_ratio != ''
                ? Row(
                    children: [
                      Text(
                        'Venta: ',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: width * 0.033,
                            color: AppColor.appWhite,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        data.sale_ratio,
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: width * 0.033,
                            color: AppColor.appGrey,
                            fontWeight: FontWeight.w300),
                      ),
                    ],
                  )
                : Container(),
                  data.product_sku != ''
                ? Row(
                    children: [
                      // Text(
                      //   'Product Click: ',
                      //   style: TextStyle(
                      //       fontFamily: 'Poppins',
                      //       fontSize: width * 0.033,
                      //       color: AppColor.appPrimary,
                      //       fontWeight: FontWeight.w500),
                      // ),
                      // Text(
                      //   data.product_sku,
                      //   style: TextStyle(
                      //       fontFamily: 'Poppins',
                      //       fontSize: width * 0.033,
                      //       color: AppColor.appPrimary,
                      //       fontWeight: FontWeight.w300),
                      // ),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
