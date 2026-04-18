import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:affiliatepro_mobile/controller/network_controller.dart';
import 'package:affiliatepro_mobile/controller/main_controller.dart';
import 'package:affiliatepro_mobile/model/network_model.dart';
import 'package:affiliatepro_mobile/view/theme/ex_futuristic_theme.dart';
import 'package:affiliatepro_mobile/view/widgets/ex_affiliate_drawer.dart';
import 'package:affiliatepro_mobile/view/widgets/ex_fx_background.dart';
import 'package:affiliatepro_mobile/view/widgets/ex_glass_card.dart';
import 'package:affiliatepro_mobile/view/widgets/ex_remote_image.dart';

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
        final List<ReferredUsersTree> referred =
            network?.data.referredUsersTree ?? <ReferredUsersTree>[];
        final int directNodes = referred.length;
        final int totalRows =
            network?.data.pagination?.totalRows ?? users.length;
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
                            directNodes: directNodes,
                            totalRows: totalRows,
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
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                        sliver: SliverToBoxAdapter(
                          child: _NetworkStatsStrip(
                            directNodes: directNodes,
                            paidSales: network
                                    ?.data.referTotal.totalProductSale.paid
                                    ?.toString() ??
                                '0',
                            pendingSales: network
                                    ?.data.referTotal.totalProductSale.request
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
                      else if (users.isEmpty && referred.isEmpty)
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
                      else if (users.isEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
                          sliver: SliverList.separated(
                            itemCount: referred.length,
                            itemBuilder: (BuildContext context, int index) {
                              return _ReferredNodeCard(node: referred[index]);
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
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
    required this.directNodes,
    required this.totalRows,
    required this.rankName,
    required this.infoText,
    required this.clicks,
    required this.sales,
  });

  final int totalUsers;
  final int directNodes;
  final int totalRows;
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
                      '${totalUsers > 0 ? totalUsers : totalRows} nodos detectados',
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
          const SizedBox(height: 12),
          Text(
            '$directNodes afiliados directos sincronizados en esta vista.',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
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

class _NetworkStatsStrip extends StatelessWidget {
  const _NetworkStatsStrip({
    required this.directNodes,
    required this.paidSales,
    required this.pendingSales,
  });

  final int directNodes;
  final String paidSales;
  final String pendingSales;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _MiniStat(
            label: 'Directos',
            value: '$directNodes',
            accent: ExFuturisticTheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniStat(
            label: 'Pagadas',
            value: paidSales,
            accent: ExFuturisticTheme.cyan,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniStat(
            label: 'Pendientes',
            value: pendingSales,
            accent: ExFuturisticTheme.amber,
          ),
        ),
      ],
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

class _ReferredNodeCard extends StatelessWidget {
  const _ReferredNodeCard({required this.node});

  final ReferredUsersTree node;

  @override
  Widget build(BuildContext context) {
    return ExGlassCard(
      radius: 24,
      child: Row(
        children: <Widget>[
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ExFuturisticTheme.primary.withOpacity(0.14),
            ),
            child: Center(
              child: Text(
                _initials(node.title),
                style: const TextStyle(
                  color: ExFuturisticTheme.primary,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  node.title.isEmpty ? 'Embajador EX' : node.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  node.email.isEmpty ? 'Sin email visible' : node.email,
                  style: const TextStyle(
                    color: Colors.white60,
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
                '\$${node.all_commition}',
                style: const TextStyle(
                  color: ExFuturisticTheme.primary,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${node.click} clics',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _initials(String value) {
    final List<String> parts = value
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'EX';
    }
    return parts.take(2).map((String part) => part[0]).join().toUpperCase();
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
            child: ClipOval(
              child: ExRemoteImage(
                imageUrl: user.photoUrl ?? '',
                fit: BoxFit.cover,
                fallback: Center(
                  child: Text(
                    name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: ExFuturisticTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
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
