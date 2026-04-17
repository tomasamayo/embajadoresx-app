import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:affiliatepro_mobile/controller/dashboard_controller.dart';
import '../../utils/colors.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key, required this.title, this.isProfile = false}); // Default `isProfile` to `false`

  final String title;
  final bool isProfile;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return AppBar(
      backgroundColor: AppColor.appPrimary,
      toolbarHeight: height * 0.08,
      centerTitle: true,
      leading: Builder(builder: (context) {
        return InkWell(
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: const Icon(
              Icons.menu,
              color: Colors.white,
            ));
      }),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      actions: [
        if (isProfile) // Use `if` statement to conditionally include the profile icon
          Container(
            height: width * 0.13,
            width: width * 0.13,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                // Use a null check and provide a fallback image URL if necessary
                image: NetworkImage(Get.find<DashboardController>().loginModel?.data?.profileAvatar ?? "fallback_image_url"),
              ),
              color: AppColor.dashboardCardColor,
            ),
          ),
        SizedBox(width: width * 0.03),
      ],
    );
  }
}