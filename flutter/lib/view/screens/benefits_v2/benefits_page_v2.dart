import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:affiliatepro_mobile/controller/award_levels_controller.dart';
import 'package:affiliatepro_mobile/controller/dashboard_controller.dart';
import 'package:affiliatepro_mobile/model/award_levels_model.dart';
import 'package:affiliatepro_mobile/view/theme/ex_futuristic_theme.dart';
import 'package:affiliatepro_mobile/view/widgets/ex_fx_background.dart';
import 'package:affiliatepro_mobile/view/widgets/ex_glass_card.dart';

class BenefitsPageV2 extends StatefulWidget {
  const BenefitsPageV2({super.key});

  @override
  State<BenefitsPageV2> createState() => _BenefitsPageV2State();
}

class _BenefitsPageV2State extends State<BenefitsPageV2> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<AwardLevelsController>()) {
        Get.find<AwardLevelsController>().fetch();
      }
      if (Get.isRegistered<DashboardController>()) {
        final DashboardController dashboard = Get.find<DashboardController>();
        dashboard.getUser();
        dashboard.getDashboardData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final DashboardController dashboard = Get.find<DashboardController>();
    final AwardLevelsController levels = Get.find<AwardLevelsController>();

    return Scaffold(
      backgroundColor: ExFuturisticTheme.bg,
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: ExFxBackground()),
          SafeArea(
            child: RefreshIndicator(
              color: ExFuturisticTheme.primary,
              backgroundColor: ExFuturisticTheme.panel,
              onRefresh: () async {
                await levels.fetch();
                await dashboard.refreshAllBalances();
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
                child: GetBuilder<DashboardController>(
                  builder: (_) {
                    return GetBuilder<AwardLevelsController>(
                      builder: (_) {
                        final AwardLevelsResponse? response = levels.response;
                        final List<AwardLevel> awardLevels =
                            response?.data ?? <AwardLevel>[];
                        final AwardLevel? currentLevel =
                            awardLevels.cast<AwardLevel?>().firstWhere(
                                  (AwardLevel? level) =>
                                      level?.status == 'Current Level',
                                  orElse: () => awardLevels.isNotEmpty
                                      ? awardLevels.first
                                      : null,
                                );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Beneficios EX',
                                        style:
                                            ExFuturisticTheme.overline.copyWith(
                                          color: ExFuturisticTheme.primarySoft,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Progreso y recompensas',
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
                                  onTap: () => Navigator.of(context).pop(),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _TopSummary(
                              planName: dashboard.planName.value.isNotEmpty
                                  ? dashboard.planName.value
                                  : (dashboard.loginModel?.data?.planName ??
                                      'Modo afiliado'),
                              rankName: dashboard.currentRank.value.isNotEmpty
                                  ? dashboard.currentRank.value
                                  : 'Nivel Inicial',
                              daysLeft: dashboard.daysLeftStr.value,
                              isVerified: dashboard.isVerified.value == 1,
                            ),
                            const SizedBox(height: 18),
                            _MetricsRow(
                              response: response,
                              fallbackClicks: dashboard
                                      .dashboardData
                                      ?.data
                                      .referTotal
                                      .totalGaneralClick
                                      .totalClicks ??
                                  '0',
                              fallbackSales: dashboard.dashboardData?.data
                                      .referTotal.totalProductSale.amounts ??
                                  '0',
                            ),
                            const SizedBox(height: 18),
                            if (levels.isLoading)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32),
                                  child: CircularProgressIndicator(
                                    color: ExFuturisticTheme.primary,
                                  ),
                                ),
                              )
                            else if (awardLevels.isEmpty)
                              const _EmptyLevelsFallback()
                            else ...<Widget>[
                              const Text(
                                'Niveles desbloqueables',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 220,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: awardLevels.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 12),
                                  itemBuilder: (BuildContext context, int idx) {
                                    final AwardLevel level = awardLevels[idx];
                                    return _LevelCard(
                                      level: level,
                                      isCurrent: currentLevel?.id == level.id,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 18),
                              _ProgressPanel(
                                response: response,
                                currentLevel: currentLevel,
                              ),
                            ],
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopSummary extends StatelessWidget {
  const _TopSummary({
    required this.planName,
    required this.rankName,
    required this.daysLeft,
    required this.isVerified,
  });

  final String planName;
  final String rankName;
  final String daysLeft;
  final bool isVerified;

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
                      'Estado premium',
                      style: ExFuturisticTheme.overline.copyWith(
                        color: ExFuturisticTheme.primarySoft,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rankName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Plan activo: $planName',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
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
                  color: (isVerified
                          ? ExFuturisticTheme.primary
                          : ExFuturisticTheme.amber)
                      .withOpacity(0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  isVerified ? 'VERIFICADO' : 'PENDIENTE',
                  style: TextStyle(
                    color: isVerified
                        ? ExFuturisticTheme.primary
                        : ExFuturisticTheme.amber,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Vigencia visible: $daysLeft',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({
    required this.response,
    required this.fallbackClicks,
    required this.fallbackSales,
  });

  final AwardLevelsResponse? response;
  final String fallbackClicks;
  final String fallbackSales;

  @override
  Widget build(BuildContext context) {
    final UserStats? stats = response?.userStats;
    return Row(
      children: <Widget>[
        Expanded(
          child: _MetricCard(
            label: 'Patrocinios',
            value: '${stats?.userPatrocinios ?? 0}',
            accent: ExFuturisticTheme.cyan,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            label: 'Socios',
            value: '${stats?.userSocios ?? 0}',
            accent: ExFuturisticTheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            label: 'Ventas',
            value: '\$${(stats?.totalPersonalSales ?? 0).toStringAsFixed(0)}',
            accent: ExFuturisticTheme.amber,
            fallback: '\$$fallbackSales',
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.accent,
    this.fallback,
  });

  final String label;
  final String value;
  final Color accent;
  final String? fallback;

  @override
  Widget build(BuildContext context) {
    final String shownValue =
        value == '\$0' || value == '0' ? (fallback ?? value) : value;
    return ExGlassCard(
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            shownValue,
            style: TextStyle(
              color: accent,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.isCurrent,
  });

  final AwardLevel level;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: ExGlassCard(
        radius: 28,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            (isCurrent
                    ? ExFuturisticTheme.primary
                    : ExFuturisticTheme.primarySoft)
                .withOpacity(0.12),
            Colors.white.withOpacity(0.03),
          ],
        ),
        borderColor: (isCurrent
                ? ExFuturisticTheme.primary
                : Colors.white.withOpacity(0.1))
            .withOpacity(0.25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              level.levelNumber.isEmpty ? 'Nivel' : level.levelNumber,
              style: TextStyle(
                color: isCurrent ? ExFuturisticTheme.primary : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Meta personal: \$${level.minimumEarning.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Patrocinios: ${level.minimumPatrocinios}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Socios: ${level.minimumSocios}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontFamily: 'Poppins',
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                level.physicalPrize.isEmpty
                    ? 'Sin premio físico'
                    : level.physicalPrize,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({
    required this.response,
    required this.currentLevel,
  });

  final AwardLevelsResponse? response;
  final AwardLevel? currentLevel;

  @override
  Widget build(BuildContext context) {
    final UserStats? stats = response?.userStats;
    final AwardLevel? level = currentLevel;
    final double salesProgress = level == null || level.minimumEarning <= 0
        ? 0
        : (stats?.totalPersonalSales ?? 0) / level.minimumEarning;
    final double sponsorsProgress =
        level == null || level.minimumPatrocinios <= 0
            ? 0
            : (stats?.userPatrocinios ?? 0) / level.minimumPatrocinios;
    final double partnersProgress = level == null || level.minimumSocios <= 0
        ? 0
        : (stats?.userSocios ?? 0) / level.minimumSocios;

    return ExGlassCard(
      radius: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Progreso actual',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          _ProgressRow(
            label: 'Ventas personales',
            progress: salesProgress,
            accent: ExFuturisticTheme.primary,
          ),
          const SizedBox(height: 14),
          _ProgressRow(
            label: 'Patrocinios',
            progress: sponsorsProgress,
            accent: ExFuturisticTheme.cyan,
          ),
          const SizedBox(height: 14),
          _ProgressRow(
            label: 'Socios',
            progress: partnersProgress,
            accent: ExFuturisticTheme.amber,
          ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.progress,
    required this.accent,
  });

  final String label;
  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final double safeProgress = progress.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: safeProgress,
            minHeight: 10,
            backgroundColor: Colors.white.withOpacity(0.08),
            color: accent,
          ),
        ),
      ],
    );
  }
}

class _EmptyLevelsFallback extends StatelessWidget {
  const _EmptyLevelsFallback();

  @override
  Widget build(BuildContext context) {
    return ExGlassCard(
      radius: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Text(
            'Sincronización parcial',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Tus beneficios premium aún no cargan el detalle completo de niveles, pero el plan, rango y métricas principales ya quedaron visibles en esta interfaz.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
