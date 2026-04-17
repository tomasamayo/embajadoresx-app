import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:affiliatepro_mobile/controller/network_controller.dart';
import 'package:affiliatepro_mobile/controller/main_controller.dart';
import 'package:affiliatepro_mobile/model/network_model.dart';
import 'package:affiliatepro_mobile/view/theme/ex_futuristic_theme.dart';
import 'package:affiliatepro_mobile/view/widgets/ex_affiliate_drawer.dart';
import 'package:affiliatepro_mobile/view/widgets/ex_fx_background.dart';
import 'package:affiliatepro_mobile/view/widgets/ex_glass_card.dart';

class NetworkPageV2 extends StatefulWidget {
  const NetworkPageV2({super.key});

  @override
  State<NetworkPageV2> createState() => _NetworkPageV2State();
}

class _NetworkPageV2State extends State<NetworkPageV2> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<NetworkController>().getNetworkData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final MainController mainController = Get.find<MainController>();

    return GetBuilder<NetworkController>(
      builder: (NetworkController controller) {
        final NetworkModel? network = controller.networkData;
        final List<Userslist> users = network?.data.userslist ?? <Userslist>[];
        return Scaffold(
          key: mainController.dashboardContextKey,
          backgroundColor: ExFuturisticTheme.bg,
          drawer: const ExAffiliateDrawer(),
          body: Stack(
            children: <Widget>[
              const Positioned.fill(child: ExFxBackground()),
              SafeArea(
                child: RefreshIndicator(
                  color: ExFuturisticTheme.primary,
                  backgroundColor: ExFuturisticTheme.panel,
                  onRefresh: () async => controller.getNetworkData(),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: <Widget>[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Mi red',
                                      style:
                                          ExFuturisticTheme.overline.copyWith(
                                        color: ExFuturisticTheme.primarySoft,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Comunidad activa',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ExGlassCard(
                                padding: const EdgeInsets.all(12),
                                radius: 20,
                                onTap: () => mainController
                                    .dashboardContextKey.currentState
                                    ?.openDrawer(),
                                child: const Icon(Icons.menu_rounded,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        sliver: SliverToBoxAdapter(
                          child: _NetworkHero(
                            totalUsers: controller.totalUsers.value,
                            rankName: network?.data.currentRankName ??
                                'Nivel inicial',
                            infoText: network?.data.networkInfoText ??
                                'Estado de la red sincronizado.',
                            clicks: network?.data.referTotal.totalGaneralClick
                                    .totalClicks ??
                                '0',
                            sales: network
                                    ?.data.referTotal.totalProductSale.amounts
                                    ?.toString() ??
                                '0',
                          ),
                        ),
                      ),
                      if (controller.isNetworkLoading)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: CircularProgressIndicator(
                                color: ExFuturisticTheme.primary),
                          ),
                        )
                      else if (users.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'Tu red aún no muestra nodos visibles para este usuario.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
                          sliver: SliverList.separated(
                            itemCount: users.length,
                            itemBuilder: (BuildContext context, int index) {
                              return _NetworkUserCard(user: users[index]);
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NetworkHero extends StatelessWidget {
  const _NetworkHero({
    required this.totalUsers,
    required this.rankName,
    required this.infoText,
    required this.clicks,
    required this.sales,
  });

  final int totalUsers;
  final String rankName;
  final String infoText;
  final String clicks;
  final String sales;

  @override
  Widget build(BuildContext context) {
    return ExGlassCard(
      radius: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '$totalUsers nodos detectados',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      infoText,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.45,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: ExFuturisticTheme.primary.withOpacity(0.14),
                ),
                child: Text(
                  rankName.toUpperCase(),
                  style: const TextStyle(
                    color: ExFuturisticTheme.primary,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: _MiniStat(
                  label: 'Clics',
                  value: clicks,
                  accent: ExFuturisticTheme.cyan,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  label: 'Ventas',
                  value: '\$$sales',
                  accent: ExFuturisticTheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkUserCard extends StatelessWidget {
  const _NetworkUserCard({required this.user});

  final Userslist user;

  @override
  Widget build(BuildContext context) {
    final String name =
        user.name.trim().isEmpty ? 'Embajador EX' : user.name.trim();
    return ExGlassCard(
      radius: 26,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 26,
            backgroundColor: ExFuturisticTheme.primary.withOpacity(0.14),
            backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                ? NetworkImage(user.photoUrl!)
                : null,
            child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                ? Text(
                    name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: ExFuturisticTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.rank ?? 'Bronce',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                user.gananciaMesFormat ?? '\$0.00',
                style: const TextStyle(
                  color: ExFuturisticTheme.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${user.afiliadosNuevosMes ?? 0} nuevos',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
