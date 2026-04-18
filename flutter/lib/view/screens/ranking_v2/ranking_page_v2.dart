import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:affiliatepro_mobile/controller/dashboard_controller.dart';
import 'package:affiliatepro_mobile/controller/main_controller.dart';
import 'package:affiliatepro_mobile/service/api_service.dart';
import 'package:affiliatepro_mobile/utils/preference.dart';
import 'package:affiliatepro_mobile/view/theme/ex_futuristic_theme.dart';
import 'package:affiliatepro_mobile/view/widgets/ex_affiliate_drawer.dart';
import 'package:affiliatepro_mobile/view/widgets/ex_fx_background.dart';
import 'package:affiliatepro_mobile/view/widgets/ex_glass_card.dart';
import 'package:affiliatepro_mobile/view/widgets/ex_remote_image.dart';

class RankingPageV2 extends StatefulWidget {
  const RankingPageV2({super.key});

  @override
  State<RankingPageV2> createState() => _RankingPageV2State();
}

class _RankingPageV2State extends State<RankingPageV2> {
  bool _isLoading = true;
  bool _hasError = false;
  List<dynamic> _rankingData = <dynamic>[];
  int _currentUserPosition = 0;
  Map<String, dynamic>? _currentUserRanking;

  @override
  void initState() {
    super.initState();
    _fetchRanking();
  }

  Future<void> _fetchRanking() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final userModel = await SharedPreference.getUserData();
    final String? token = userModel?.data?.token;
    String? userIdStr = userModel?.data?.userId?.toString();

    if ((userIdStr == null || userIdStr.isEmpty || userIdStr == 'null') &&
        Get.isRegistered<DashboardController>()) {
      userIdStr = Get.find<DashboardController>().userId.value;
    }

    if (userIdStr == null || userIdStr.isEmpty) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      userIdStr = prefs.getString('user_id') ?? prefs.getString('id');
    }

    final dynamic response = await ApiService.instance
        .getGlobalRanking(token: token, userId: userIdStr);

    if (!mounted) return;

    if (response != null && response['status'] == true) {
      _rankingData = response['data'] ?? <dynamic>[];
      _currentUserPosition = _rankingData
              .indexWhere((dynamic u) => u['user_id'].toString() == userIdStr) +
          1;
      _currentUserRanking = _currentUserPosition > 0
          ? _rankingData[_currentUserPosition - 1]
          : null;
      setState(() {
        _isLoading = false;
        _hasError = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final MainController mainController = Get.find<MainController>();
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
              onRefresh: _fetchRanking,
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
                                  'Rango global',
                                  style: ExFuturisticTheme.overline.copyWith(
                                    color: ExFuturisticTheme.primarySoft,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Ranking premium',
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
                  if (_isLoading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(
                            color: ExFuturisticTheme.primary),
                      ),
                    )
                  else if (_hasError)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'No se pudo sincronizar el ranking global en este momento.',
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
                  else ...<Widget>[
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      sliver: SliverToBoxAdapter(
                        child: _RankingHero(
                          totalUsers: _rankingData.length,
                          currentUserPosition: _currentUserPosition,
                          currentUserAmount:
                              _currentUserRanking?['amount']?.toString() ?? '0',
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                      sliver: SliverToBoxAdapter(
                        child: _Podium(topThree: _rankingData.take(3).toList()),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 120),
                      sliver: SliverList.separated(
                        itemCount: _rankingData.length > 3
                            ? _rankingData.length - 3
                            : 0,
                        itemBuilder: (BuildContext context, int index) {
                          final dynamic user = _rankingData[index + 3];
                          return _RankingRow(
                            position: index + 4,
                            user: user,
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingHero extends StatelessWidget {
  const _RankingHero({
    required this.totalUsers,
    required this.currentUserPosition,
    required this.currentUserAmount,
  });

  final int totalUsers;
  final int currentUserPosition;
  final String currentUserAmount;

  @override
  Widget build(BuildContext context) {
    return ExGlassCard(
      radius: 30,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Top sincronizado',
                  style: ExFuturisticTheme.overline.copyWith(
                    color: ExFuturisticTheme.primarySoft,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$totalUsers usuarios compitiendo',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  currentUserPosition > 0
                      ? 'Tu posición actual: #$currentUserPosition'
                      : 'Aún no apareces en el top visible.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: ExFuturisticTheme.neonGradient(
                start: ExFuturisticTheme.amber.withOpacity(0.18),
                end: ExFuturisticTheme.primary.withOpacity(0.16),
              ),
            ),
            child: Text(
              '\$$currentUserAmount',
              style: const TextStyle(
                color: ExFuturisticTheme.amber,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.topThree});

  final List<dynamic> topThree;

  @override
  Widget build(BuildContext context) {
    if (topThree.isEmpty) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List<Widget>.generate(
        topThree.length,
        (int index) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _PodiumCard(user: topThree[index], place: index + 1),
          ),
        ),
      ),
    );
  }
}

class _PodiumCard extends StatelessWidget {
  const _PodiumCard({required this.user, required this.place});

  final dynamic user;
  final int place;

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = <Color>[
      ExFuturisticTheme.amber,
      ExFuturisticTheme.cyan,
      const Color(0xFFB8845B),
    ];
    final Color accent = colors[(place - 1).clamp(0, 2)];
    final String name =
        '${user['firstname'] ?? ''} ${user['lastname'] ?? ''}'.trim();

    return ExGlassCard(
      radius: 26,
      padding: const EdgeInsets.all(14),
      borderColor: accent.withOpacity(0.2),
      glowColor: accent,
      child: Column(
        children: <Widget>[
          CircleAvatar(
            radius: place == 1 ? 34 : 28,
            backgroundColor: accent.withOpacity(0.18),
            child: ClipOval(
              child: ExRemoteImage(
                imageUrl: user['avatar']?.toString() ?? '',
                fit: BoxFit.cover,
                fallback: Center(
                  child: Text(
                    name.isEmpty ? 'EX' : name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '#$place',
            style: TextStyle(
              color: accent,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name.isEmpty ? 'Usuario EX' : name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${user['amount'] ?? 0}',
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

class _RankingRow extends StatelessWidget {
  const _RankingRow({required this.position, required this.user});

  final int position;
  final dynamic user;

  @override
  Widget build(BuildContext context) {
    final String name =
        '${user['firstname'] ?? ''} ${user['lastname'] ?? ''}'.trim();
    return ExGlassCard(
      radius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 32,
            child: Text(
              '$position',
              style: const TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: ExFuturisticTheme.primary.withOpacity(0.14),
            child: ClipOval(
              child: ExRemoteImage(
                imageUrl: user['avatar']?.toString() ?? '',
                fit: BoxFit.cover,
                fallback: Center(
                  child: Text(
                    name.isEmpty ? 'E' : name.substring(0, 1).toUpperCase(),
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
                  name.isEmpty ? 'Usuario EX' : name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  (user['rank'] ?? 'Sin rango').toString(),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${user['amount'] ?? 0}',
            style: const TextStyle(
              color: ExFuturisticTheme.primary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
