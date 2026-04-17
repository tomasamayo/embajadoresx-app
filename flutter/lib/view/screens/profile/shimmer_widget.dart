import 'package:flutter/material.dart';
import 'package:affiliatepro_mobile/controller/dashboard_controller.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../utils/colors.dart';
import '../../../../utils/text.dart';

class ProfielShimmerWidget extends StatelessWidget {
  const ProfielShimmerWidget({super.key, required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: AppColor.dashboardBgColor,
        appBar: AppBar(
          backgroundColor: AppColor.dashboardBgColor,
          leading: const Icon(Icons.menu),
          title: Text(AppText.profile),
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: width * 0.04, vertical: height * 0.03),
                child: Column(children: <Widget>[
                   Container(
                    width:  height * 0.2,
                    height: height * 0.2,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(width * 0.03)),
                    child: Shimmer.fromColors(
                        baseColor: Colors.grey.withOpacity(0.1),
                        highlightColor: Colors.white.withOpacity(0.3),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.8),
                              borderRadius:
                                  BorderRadius.circular(width * 0.7)),
                        )),
                  ),
                    SizedBox(
                    height: height * 0.04,
                  ),
                  Container(
                    width: double.infinity,
                    height: height * 0.5,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(width * 0.03)),
                    child: Shimmer.fromColors(
                        baseColor: Colors.grey.withOpacity(0.1),
                        highlightColor: Colors.white.withOpacity(0.3),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.8),
                              borderRadius:
                                  BorderRadius.circular(width * 0.03)),
                        )),
                  ),

                ]))));
  }
}
