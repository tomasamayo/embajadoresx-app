import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/notification_controller.dart';
import '../../../controller/main_controller.dart';
import '../../../controller/bannerAndLinks_controller.dart';
import '../../../utils/colors.dart';
import '../academy_screen.dart';
import '../membership/membership_buy.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late NotificationsController controller;

  @override
  void initState() {
    super.initState();
    try {
      controller = Get.find<NotificationsController>();
    } catch (e) {
      controller = Get.put(NotificationsController());
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getNotificationsData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1210),
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColor.appPrimary.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 50),
              // Custom Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Notificaciones',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Text(
                              'ALERTAS EN TIEMPO REAL',
                              style: TextStyle(
                                color: AppColor.appPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => controller.getNotificationsData(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColor.appPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColor.appPrimary.withOpacity(0.2)),
                        ),
                        child: Icon(Icons.refresh, color: AppColor.appPrimary, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: GetBuilder<NotificationsController>(
                  builder: (c) {
                    if (c.isLoading) {
                      return Center(child: CircularProgressIndicator(color: AppColor.appPrimary));
                    }
                    if (c.notificationsData == null || c.notificationsData!.data.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_off_outlined, size: 80, color: Colors.white.withOpacity(0.1)),
                            const SizedBox(height: 20),
                            const Text(
                              'No hay notificaciones',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      color: AppColor.appPrimary,
                      backgroundColor: const Color(0xFF1A1D1A),
                      onRefresh: () async => controller.getNotificationsData(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        physics: const BouncingScrollPhysics(),
                        itemCount: c.notificationsData!.data.length,
                        itemBuilder: (_, i) {
                          final n = c.notificationsData!.data[i];
                          return Dismissible(
                            key: Key(n.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) async {
                              await controller.deleteNotificationOptimistically(i);
                            },
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.only(right: 25),
                              alignment: Alignment.centerRight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.black.withOpacity(0.0),
                                    Colors.red.withOpacity(0.4),
                                  ],
                                ),
                                border: Border.all(color: Colors.red.withOpacity(0.1)),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
                                  SizedBox(height: 4),
                                  Text(
                                    'BORRAR',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            child: NotificationCard(item: n),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final dynamic item;
  const NotificationCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    IconData getIcon() {
      switch (item.type.toLowerCase()) {
        case 'product':
          return Icons.inventory_2_rounded;
        case 'academy':
          return Icons.school_rounded;
        case 'withdraw':
          return Icons.payments_rounded;
        case 'commission':
          return Icons.insert_chart_outlined_rounded;
        case 'missed_commission':
          return Icons.warning_amber_rounded;
        default:
          return Icons.notifications_active_rounded;
      }
    }

    Color getAccentColor() {
      switch (item.type.toLowerCase()) {
        case 'product':
          return const Color(0xFF4A90E2); // Blue
        case 'academy':
          return const Color(0xFFFFD700); // Gold
        case 'withdraw':
          return Colors.redAccent;
        case 'commission':
          return AppColor.appPrimary; // Green
        case 'missed_commission':
          return Colors.orangeAccent; // Alerta Ámbar
        default:
          return AppColor.appPrimary;
      }
    }


    return InkWell(
      onTap: () {
        Navigator.pop(context); // Cierra el modal de notificaciones

        switch (item.type.toLowerCase()) {
          case 'product':
            // 1. Ir a la pestaña de Banners y Enlaces
            final mainCtrl = Get.find<MainController>();
            mainCtrl.changePageIndex(2); 

            // 2. Activar filtro global por defecto
            final bannerCtrl = Get.find<BannerAndLinksController>();
            bannerCtrl.processDeepLinkNavigation(item.actionId.toString(), true);
            break;

          case 'academy':
            // Navegar directamente a la Academia EX
            Get.to(() => const AcademyScreen());
            break;

          case 'missed_commission':
            // Navegar a compra de planes/membresías
            Get.to(() => const MembershipBuyPage());
            break;

          default:
            // Para otros tipos, solo cerramos el modal (ya hecho arriba)
            break;
        }
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Side Glow Indicator
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      getAccentColor(),
                      getAccentColor().withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
            // Side Radial Glow
            Positioned(
              left: -20,
              top: 20,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      getAccentColor().withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: getAccentColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(getIcon(), color: getAccentColor(), size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 12,
                                height: 1.4,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.2), size: 14),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white10, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.white.withOpacity(0.3), size: 14),
                          const SizedBox(width: 6),
                          Text(
                            item.createdDate,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 11,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}