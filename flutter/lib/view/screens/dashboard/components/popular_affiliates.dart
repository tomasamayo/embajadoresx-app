import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:affiliatepro_mobile/controller/dashboard_controller.dart';
import 'package:affiliatepro_mobile/model/dashboard_model.dart';
import 'package:affiliatepro_mobile/utils/colors.dart';

class PopularAffiliatesWidget extends StatelessWidget {
  const PopularAffiliatesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (controller) {
        final topAffiliates = controller.dashboardData?.data.topAffiliate ?? [];

        if (controller.isDashboardDataLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColor.appPrimary),
          );
        }

        if (topAffiliates.isEmpty) {
          return _buildEmptyState();
        }

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F1210).withOpacity(0.9),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FadeInLeft(
                      child: const Text(
                        "Top Afiliados",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    FadeInRight(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColor.appPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColor.appPrimary.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.trending_up, color: AppColor.appPrimary, size: 14),
                            SizedBox(width: 4),
                            Text(
                              "Popular",
                              style: TextStyle(
                                color: AppColor.appPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    physics: const BouncingScrollPhysics(),
                    itemCount: topAffiliates.length,
                    itemBuilder: (context, index) {
                      final affiliate = topAffiliates[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 500),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: _buildAffiliateCard(affiliate),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAffiliateCard(dynamic affiliate) {
    final bool isPositive = true; // Based on your description of green/red colors
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            // Rank Number
            // Container(
            //   width: 24,
            //   child: Text(
            //     "${index + 1}",
            //     style: TextStyle(
            //       color: Colors.white.withOpacity(0.3),
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
            
            // Avatar with Neon Border
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColor.appPrimary, Color(0xFF00FF88)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.appPrimary.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFF1A1D1A),
                backgroundImage: affiliate.avatar.isNotEmpty 
                    ? NetworkImage(affiliate.avatar) 
                    : null,
                child: affiliate.avatar.isEmpty 
                    ? const Icon(Icons.person, color: Colors.white54) 
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            
            // Name and Country
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          "${affiliate.firstname} ${affiliate.lastname}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (affiliate.isVerified == 1) ...[
                        const SizedBox(width: 5),
                        const Icon(Icons.verified, color: Colors.blue, size: 14),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: Colors.white54),
                      const SizedBox(width: 4),
                      Text(
                        affiliate.country,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  affiliate.allCommition,
                  style: TextStyle(
                    color: isPositive ? const Color(0xFF00FF88) : const Color(0xFFFF4D4D),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  "Comisión",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined, size: 64, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          const Text(
            "No hay afiliados populares aún",
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
