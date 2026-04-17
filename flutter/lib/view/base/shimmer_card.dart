import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Expanded(
      child: Container(
        width: double.infinity,
        height: height * 0.2,
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(width * 0.03)),
        child: Shimmer.fromColors(
            baseColor: Colors.grey.withOpacity(0.1),
            highlightColor: Colors.white.withOpacity(0.3),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(width * 0.03)),
            )),
      ),
    );
  }
}
