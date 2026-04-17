import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:affiliatepro_mobile/controller/dashboard_controller.dart';
import 'package:affiliatepro_mobile/controller/main_controller.dart';
import 'package:affiliatepro_mobile/model/dashboard_model.dart';
import 'package:affiliatepro_mobile/model/user_model.dart' as user_model;
import 'package:affiliatepro_mobile/view/screens/Menu/benefits/benefits.dart';
import 'package:affiliatepro_mobile/view/screens/notifications/notifications.dart';
import 'package:affiliatepro_mobile/view/screens/profile/profile.dart';
import 'package:affiliatepro_mobile/view/theme/ex_futuristic_theme.dart';
import 'package:affiliatepro_mobile/view/widgets/ex_affiliate_drawer.dart';
import 'package:affiliatepro_mobile/view/widgets/ex_fx_background.dart';
import 'package:affiliatepro_mobile/view/widgets/ex_glass_card.dart';
import 'package:affiliatepro_mobile/view/widgets/ex_neon_button.dart';

class DashboardPageV2 extends StatefulWidget {
  const DashboardPageV2({super.key});

  @override
  State<DashboardPageV2> createState() => _DashboardPageV2State();
}

class _DashboardPageV2State extends State<DashboardPageV2> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final DashboardController controller = Get.find<DashboardController>();
      controller.getUser();
      controller.getDashboardData();
      controller.refreshAllBalances();
      _checkShowcase();
    });
  }

  Future<void> _checkShowcase() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool hasSeenTour = prefs.getBool('guia_vista') ?? false;
    if (hasSeenTour || !mounted) {
      return;
    }

    final DashboardController dashboardController =
        Get.find<DashboardController>();
    final MainController mainController = Get.find<MainController>();

    if (dashboardController.isLoading ||
        dashboardController.isDashboardDataLoading) {
      Future<void>.delayed(const Duration(milliseconds: 700), _checkShowcase);
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted ||
        mainController.perfilKey.currentContext == null ||
        mainController.saldoUSDKey.currentContext == null ||
        mainController.saldoExCoinKey.currentContext == null) {
      Future<void>.delayed(const Duration(milliseconds: 500), _checkShowcase);
      return;
    }

    final BuildContext? showcaseContext =
        mainController.dashboardContextKey.currentContext;
    if (showcaseContext == null) {
      return;
    }

    mainController.isTourActive = true;
    ShowCaseWidget.of(showcaseContext).startShowCase(<GlobalKey>[
      mainController.perfilKey,
      mainController.saldoUSDKey,
      mainController.saldoExCoinKey,
      mainController.btnEnlacesKey,
      mainController.btnEventosKey,
      mainController.btnRankingKey,
      mainController.btnRedKey,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final MainController mainController = Get.find<MainController>();

    return GetBuilder<DashboardController>(
      builder: (DashboardController dashboardController) {
        final DashboardModel? dashboardData = dashboardController.dashboardData;
        final user_model.Data? user = dashboardController.loginModel?.data;

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
                  onRefresh: () async {
                    await dashboardController.refreshAllBalances();
                  },
                  child: SingleChildScrollView(
                    controller: mainController.dashboardScrollController,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildHeader(
                          user: user,
                          dashboardController: dashboardController,
                          mainController: mainController,
                        ),
                        const SizedBox(height: 24),
                        _buildActionCard(dashboardController),
                        const SizedBox(height: 18),
                        _buildBalanceRow(
                          dashboardData: dashboardData,
                          dashboardController: dashboardController,
                          mainController: mainController,
                        ),
                        const SizedBox(height: 18),
                        _buildQuickActions(mainController),
                        const SizedBox(height: 18),
                        _buildRankModule(dashboardData, dashboardController),
                        const SizedBox(height: 18),
                        _buildWeeklyModule(dashboardData),
                        const SizedBox(height: 18),
                        _buildActivityFeed(dashboardData),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: ExFuturisticTheme.primary,
            foregroundColor: const Color(0xFF07100C),
            elevation: 0,
            onPressed: () => Get.to(() => const NotificationsPage()),
            child: const Icon(Icons.auto_awesome_rounded),
          ),
        );
      },
    );
  }

  Widget _buildHeader({
    required user_model.Data? user,
    required DashboardController dashboardController,
    required MainController mainController,
  }) {
    final String fullName =
        "${user?.firstname ?? ''} ${user?.lastname ?? ''}".trim();
    final String displayName = fullName.isEmpty ? "Embajador EX" : fullName;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Showcase.withWidget(
            key: mainController.perfilKey,
            width: 260,
            height: 170,
            overlayOpacity: 0.82,
            overlayColor: Colors.black,
            container: _tourTooltip(
              title: 'Perfil',
              description:
                  'Desde aquí validas tu identidad, visualizas tu cuenta y accedes a la nueva interfaz premium.',
            ),
            child: ExGlassCard(
              padding: const EdgeInsets.all(16),
              radius: 30,
              borderColor: ExFuturisticTheme.primary.withOpacity(0.16),
              glowColor: ExFuturisticTheme.primary,
              child: Row(
                children: <Widget>[
                  _AvatarGlow(
                    name: displayName,
                    avatarUrl: user?.profileAvatar,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Nexus online',
                          style: ExFuturisticTheme.overline.copyWith(
                            color: ExFuturisticTheme.primarySoft,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _greeting(displayName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            height: 1.02,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed: () => Get.to(() => const ProfilePage()),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(Icons.arrow_forward_rounded,
                              color: ExFuturisticTheme.primary, size: 18),
                          label: const Text(
                            'Ver perfil',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          children: <Widget>[
            _IconPanelButton(
              icon: Icons.notifications_none_rounded,
              onTap: () => Get.to(() => const NotificationsPage()),
            ),
            const SizedBox(height: 10),
            _IconPanelButton(
              icon: Icons.menu_rounded,
              onTap: () =>
                  mainController.dashboardContextKey.currentState?.openDrawer(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(DashboardController dashboardController) {
    final bool verified = dashboardController.isVerified.value == 1;
    final String title = verified ? 'Cuenta verificada' : 'Acción requerida';
    final String description = verified
        ? 'Tu perfil ya puede operar con mayor confianza dentro del ecosistema.'
        : 'Completa tu setup de cobros y tu verificación premium.';

    return ExGlassCard(
      radius: 32,
      padding: const EdgeInsets.all(14),
      borderColor: verified
          ? ExFuturisticTheme.primary.withOpacity(0.14)
          : Colors.white.withOpacity(0.10),
      child: Row(
        children: <Widget>[
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: verified
                  ? ExFuturisticTheme.primary.withOpacity(0.14)
                  : Colors.white.withOpacity(0.05),
            ),
            child: Icon(
              verified ? Icons.verified_rounded : Icons.shield_outlined,
              color: verified
                  ? ExFuturisticTheme.primary
                  : ExFuturisticTheme.primarySoft,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.45,
                    fontFamily: 'Poppins',
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ExNeonButton(
            label: verified ? 'Perfecto' : 'Configurar',
            compact: true,
            onTap: () => Get.to(() => const ProfilePage()),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceRow({
    required DashboardModel? dashboardData,
    required DashboardController dashboardController,
    required MainController mainController,
  }) {
    final String usdBalance = _money(
      dashboardData?.data.userTotals.userBalance ?? '0',
    );
    final String exCoinBalance = _number(
      dashboardController.excoinBalance.value,
    );
    final String clicks = _number(
      dashboardData?.data.userTotals.totalClicksCount ?? 0,
      decimals: 0,
    );
    final String actions = _number(
      dashboardData?.data.referTotal.totalAction.clickCount ?? '0',
      decimals: 0,
    );

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Showcase.withWidget(
                key: mainController.saldoUSDKey,
                width: 260,
                height: 170,
                overlayOpacity: 0.82,
                overlayColor: Colors.black,
                container: _tourTooltip(
                  title: 'Saldo USD',
                  description:
                      'Aquí ves tu balance disponible en dinero real y el rendimiento directo del negocio.',
                ),
                child: _MetricCard(
                  title: 'Saldo USD',
                  value: usdBalance,
                  accent: ExFuturisticTheme.primary,
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Showcase.withWidget(
                key: mainController.saldoExCoinKey,
                width: 260,
                height: 170,
                overlayOpacity: 0.82,
                overlayColor: Colors.black,
                container: _tourTooltip(
                  title: 'ExCoin',
                  description:
                      'Tu balance interno del ecosistema, conectado al nuevo diseño premium.',
                ),
                child: _MetricCard(
                  title: 'Saldo ExCoin',
                  value: exCoinBalance,
                  accent: ExFuturisticTheme.amber,
                  icon: Icons.auto_awesome_motion_outlined,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _MetricCard(
                title: 'Clics',
                value: clicks,
                accent: ExFuturisticTheme.blue,
                icon: Icons.ads_click_outlined,
                compact: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Acciones',
                value: actions,
                accent: ExFuturisticTheme.purple,
                icon: Icons.bolt_outlined,
                compact: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(MainController mainController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Accesos directos', style: ExFuturisticTheme.sectionTitle),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _QuickActionCard(
                icon: Icons.link_rounded,
                label: 'Mis enlaces',
                color: ExFuturisticTheme.blue,
                onTap: () => mainController.changePageIndex(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.workspace_premium_outlined,
                label: 'Mi plan',
                color: ExFuturisticTheme.amber,
                onTap: () => Get.to(() => const BenefitsPage()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.person_outline_rounded,
                label: 'Perfil',
                color: ExFuturisticTheme.primary,
                onTap: () => Get.to(() => const ProfilePage()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRankModule(
    DashboardModel? dashboardData,
    DashboardController dashboardController,
  ) {
    final String planName = dashboardController.planName.value.isNotEmpty
        ? dashboardController.planName.value
        : dashboardData?.data.userPlan.planName ?? 'Sin plan';
    final String rankName = dashboardController.currentRank.value.isNotEmpty
        ? dashboardController.currentRank.value
        : dashboardData?.data.currentRankName ?? 'Nivel Inicial';
    final double clickProgress = _toDouble(
      dashboardData?.data.userTotals.totalClicksCount ?? 0,
    );
    final double progress =
        clickProgress <= 0 ? 0.08 : (clickProgress / 100).clamp(0.08, 1.0);

    return ExGlassCard(
      radius: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Rango y performance',
            style: ExFuturisticTheme.overline.copyWith(
              color: ExFuturisticTheme.primarySoft,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      rankName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Plan activo: $planName',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontFamily: 'Poppins',
                        fontSize: 13,
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
                  gradient: ExFuturisticTheme.neonGradient(
                    start: ExFuturisticTheme.primary.withOpacity(0.18),
                    end: ExFuturisticTheme.cyan.withOpacity(0.16),
                  ),
                  border: Border.all(
                    color: ExFuturisticTheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  _money(
                      dashboardData?.data.referTotal.totalProductSale.amounts ??
                          0),
                  style: const TextStyle(
                    color: ExFuturisticTheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.06),
              valueColor: const AlwaysStoppedAnimation<Color>(
                ExFuturisticTheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Progreso basado en actividad y clics del ecosistema.',
            style: const TextStyle(
              color: Colors.white54,
              fontFamily: 'Poppins',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyModule(DashboardModel? dashboardData) {
    final List<double> source =
        dashboardData?.data.weeklyChartData ?? <double>[];
    final List<double> values = source.length >= 7
        ? source.take(7).toList()
        : <double>[12, 28, 21, 35, 48, 32, 55];
    final double maxValue = values.fold<double>(1, (double max, double value) {
      return value > max ? value : max;
    });
    const List<String> labels = <String>['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return ExGlassCard(
      radius: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Pulso semanal', style: ExFuturisticTheme.sectionTitle),
          const SizedBox(height: 6),
          const Text(
            'Actividad visible del motor comercial durante la semana.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.45,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List<Widget>.generate(values.length, (int index) {
                final double heightFactor = values[index] / maxValue;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        AnimatedContainer(
                          duration: Duration(milliseconds: 420 + (index * 70)),
                          curve: Curves.easeOutCubic,
                          height: 26 + (72 * heightFactor),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: ExFuturisticTheme.neonGradient(
                              start: index.isEven
                                  ? ExFuturisticTheme.primary
                                  : ExFuturisticTheme.cyan,
                              end: ExFuturisticTheme.primarySoft,
                            ),
                            boxShadow: ExFuturisticTheme.glow(
                              color: index.isEven
                                  ? ExFuturisticTheme.primary
                                  : ExFuturisticTheme.cyan,
                              opacity: 0.16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          labels[index],
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityFeed(DashboardModel? dashboardData) {
    final List<Map<String, dynamic>> activities =
        dashboardData?.data.recentActivities ?? <Map<String, dynamic>>[];

    return ExGlassCard(
      radius: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Actividad reciente', style: ExFuturisticTheme.sectionTitle),
          const SizedBox(height: 12),
          if (activities.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text(
                  'Aún no tienes actividad reciente visible.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            )
          else
            ...activities.take(3).map((Map<String, dynamic> item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: Colors.white.withOpacity(0.04),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: ExFuturisticTheme.primary.withOpacity(0.12),
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          color: ExFuturisticTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _activityTitle(item),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _activitySubtitle(item),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _tourTooltip({
    required String title,
    required String description,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF121816),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ExFuturisticTheme.primary.withOpacity(0.3)),
        boxShadow: ExFuturisticTheme.glow(opacity: 0.16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: ExFuturisticTheme.primary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.45,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  String _greeting(String fullName) {
    final List<String> parts = fullName.trim().split(RegExp(r'\s+'));
    final String first = parts.isEmpty ? fullName : parts.first;
    return 'Hola,\n$first';
  }

  String _money(dynamic value) {
    final double parsed = _toDouble(value);
    return '\$${parsed.toStringAsFixed(2)}';
  }

  String _number(dynamic value, {int decimals = 0}) {
    final double parsed = _toDouble(value);
    return parsed.toStringAsFixed(decimals);
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '0') ?? 0;
  }

  String _activityTitle(Map<String, dynamic> activity) {
    final List<String> keys = <String>[
      'title',
      'message',
      'action',
      'description'
    ];
    for (final String key in keys) {
      final dynamic value = activity[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return 'Actividad registrada';
  }

  String _activitySubtitle(Map<String, dynamic> activity) {
    final List<String> keys = <String>['created_at', 'date', 'time', 'status'];
    for (final String key in keys) {
      final dynamic value = activity[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return 'Actualización del ecosistema';
  }
}

class _AvatarGlow extends StatelessWidget {
  const _AvatarGlow({required this.name, this.avatarUrl});

  final String name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final String initials = name
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .take(2)
        .map((String part) => part[0])
        .join()
        .toUpperCase();

    return Container(
      width: 76,
      height: 76,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: ExFuturisticTheme.neonGradient(),
        boxShadow: ExFuturisticTheme.glow(opacity: 0.24),
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: ExFuturisticTheme.bg,
        ),
        child: ClipOval(
          child: (avatarUrl != null && avatarUrl!.isNotEmpty)
              ? Image.network(
                  avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallback(initials),
                )
              : _fallback(initials),
        ),
      ),
    );
  }

  Widget _fallback(String initials) {
    return Center(
      child: Text(
        initials.isEmpty ? 'EX' : initials,
        style: const TextStyle(
          color: ExFuturisticTheme.primary,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

class _IconPanelButton extends StatelessWidget {
  const _IconPanelButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ExGlassCard(
      radius: 22,
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.accent,
    required this.icon,
    this.compact = false,
  });

  final String title;
  final String value;
  final Color accent;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ExGlassCard(
      radius: 28,
      padding: EdgeInsets.all(compact ? 16 : 18),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          accent.withOpacity(0.12),
          Colors.white.withOpacity(0.03),
        ],
      ),
      borderColor: accent.withOpacity(0.18),
      glowColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: compact ? 42 : 46,
            height: compact ? 42 : 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: accent.withOpacity(0.16),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          SizedBox(height: compact ? 18 : 22),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: compact ? Colors.white : accent,
              fontSize: compact ? 24 : 32,
              height: 0.96,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ExGlassCard(
      radius: 26,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      onTap: onTap,
      child: Column(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.18),
              boxShadow: ExFuturisticTheme.glow(color: color, opacity: 0.12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
