import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class CustomLoader extends StatelessWidget {
  const CustomLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24,
      height: 24,
      child:
          CircularProgressIndicator(strokeWidth: 2, color: AppColor.appPrimary),
    );
  }
}
