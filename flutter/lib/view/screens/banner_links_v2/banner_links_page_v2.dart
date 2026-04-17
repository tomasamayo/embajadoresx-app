import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:affiliatepro_mobile/controller/bannerAndLinks_controller.dart';
import 'package:affiliatepro_mobile/controller/main_controller.dart';
import 'package:affiliatepro_mobile/model/bannerAndLinks_model.dart';
import 'package:affiliatepro_mobile/view/theme/ex_futuristic_theme.dart';
import 'package:affiliatepro_mobile/view/widgets/ex_affiliate_drawer.dart';
import 'package:affiliatepro_mobile/view/widgets/ex_fx_background.dart';
import 'package:affiliatepro_mobile/view/widgets/ex_glass_card.dart';
import 'package:affiliatepro_mobile/view/widgets/ex_neon_button.dart';

class BannerLinksPageV2 extends StatefulWidget {
  const BannerLinksPageV2({super.key});

  @override
  State<BannerLinksPageV2> createState() => _BannerLinksPageV2State();
}

class _BannerLinksPageV2State extends State<BannerLinksPageV2> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BannerAndLinksController controller =
          Get.find<BannerAndLinksController>();
      controller.getBannerAndLinksData();
      controller.getFullCatalogForCache();
    });
  }

  @override
  Widget build(BuildContext context) {
    final MainController mainController = Get.find<MainController>();

    return GetBuilder<BannerAndLinksController>(
      builder: (BannerAndLinksController controller) {
        final List<BannerData> items =
            controller.bannerAndLinksData?.data ?? <BannerData>[];
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
                  onRefresh: () async => controller.getBannerAndLinksData(),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: <Widget>[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                        sliver: SliverToBoxAdapter(
                          child: _Header(
                            onMenu: () => mainController
                                .dashboardContextKey.currentState
                                ?.openDrawer(),
                            onToggleView: controller.toggleView,
                            isGridView: controller.isGridView,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        sliver: SliverToBoxAdapter(
                          child: _SummaryPanel(
                            totalItems: items.length,
                            marketView: controller.currentMarketView,
                            onChangeView: controller.setMarketView,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                        sliver: SliverToBoxAdapter(
                          child: _QuickFilters(
                            searchQuery: controller.searchQuery,
                            onSearchChanged: (String value) {
                              controller.setFilters(search: value);
                            },
                          ),
                        ),
                      ),
                      if (controller.isBannerAndLinksLoading)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: ExFuturisticTheme.primary,
                            ),
                          ),
                        )
                      else if (items.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(28),
                              child: Text(
                                'No hay banners o enlaces visibles con los filtros actuales.',
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
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 120),
                          sliver: controller.isGridView
                              ? SliverGrid(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 14,
                                    crossAxisSpacing: 14,
                                    childAspectRatio: 0.72,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                      return _MarketCard(
                                          item: items[index], compact: true);
                                    },
                                    childCount: items.length,
                                  ),
                                )
                              : SliverList.separated(
                                  itemCount: items.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return _MarketCard(item: items[index]);
                                  },
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 14),
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

class _Header extends StatelessWidget {
  const _Header({
    required this.onMenu,
    required this.onToggleView,
    required this.isGridView,
  });

  final VoidCallback onMenu;
  final VoidCallback onToggleView;
  final bool isGridView;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Banners y enlaces',
                style: ExFuturisticTheme.overline.copyWith(
                  color: ExFuturisticTheme.primarySoft,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Activos de conversión',
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
          onTap: onToggleView,
          child: Icon(
            isGridView ? Icons.view_agenda_rounded : Icons.grid_view_rounded,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        ExGlassCard(
          padding: const EdgeInsets.all(12),
          radius: 20,
          onTap: onMenu,
          child: const Icon(Icons.menu_rounded, color: Colors.white),
        ),
      ],
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({
    required this.totalItems,
    required this.marketView,
    required this.onChangeView,
  });

  final int totalItems;
  final String marketView;
  final ValueChanged<String> onChangeView;

  @override
  Widget build(BuildContext context) {
    return ExGlassCard(
      radius: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Centro comercial premium',
            style: ExFuturisticTheme.overline.copyWith(
              color: ExFuturisticTheme.primarySoft,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '$totalItems recursos listos para compartir',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.auto_awesome_rounded,
                  color: ExFuturisticTheme.primary, size: 28),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _ViewChip(
                label: 'Favoritos',
                selected: marketView == 'favorites',
                onTap: () => onChangeView('favorites'),
              ),
              _ViewChip(
                label: 'Global',
                selected: marketView == 'all',
                onTap: () => onChangeView('all'),
              ),
              _ViewChip(
                label: 'Hot',
                selected: marketView == 'hot',
                onTap: () => onChangeView('hot'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickFilters extends StatelessWidget {
  const _QuickFilters({
    required this.searchQuery,
    required this.onSearchChanged,
  });

  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController =
        TextEditingController(text: searchQuery);
    return ExGlassCard(
      radius: 26,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: textController,
        onSubmitted: onSearchChanged,
        style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        decoration: InputDecoration(
          icon: const Icon(Icons.search_rounded,
              color: ExFuturisticTheme.primarySoft),
          hintText: 'Buscar producto, recurso o campaña',
          hintStyle:
              const TextStyle(color: Colors.white38, fontFamily: 'Poppins'),
          border: InputBorder.none,
          suffixIcon: IconButton(
            onPressed: () => onSearchChanged(textController.text),
            icon: const Icon(Icons.arrow_forward_rounded,
                color: ExFuturisticTheme.primary),
          ),
        ),
      ),
    );
  }
}

class _ViewChip extends StatelessWidget {
  const _ViewChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ExGlassCard(
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      borderColor: selected
          ? ExFuturisticTheme.primary.withOpacity(0.28)
          : Colors.white.withOpacity(0.06),
      glowColor: selected ? ExFuturisticTheme.primary : null,
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: selected ? ExFuturisticTheme.primary : Colors.white70,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

class _MarketCard extends StatelessWidget {
  const _MarketCard({
    required this.item,
    this.compact = false,
  });

  final BannerData item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ExGlassCard(
      radius: 28,
      padding: EdgeInsets.all(compact ? 14 : 16),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          (item.isTopHot ? ExFuturisticTheme.amber : ExFuturisticTheme.primary)
              .withOpacity(0.10),
          Colors.white.withOpacity(0.03),
        ],
      ),
      borderColor:
          (item.isTopHot ? ExFuturisticTheme.amber : ExFuturisticTheme.primary)
              .withOpacity(0.14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1.2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: Colors.white.withOpacity(0.04),
                image: item.fevi_icon.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(item.fevi_icon),
                        fit: BoxFit.cover,
                        onError: (_, __) {},
                      )
                    : null,
              ),
              child: item.fevi_icon.isEmpty
                  ? const Center(
                      child: Icon(Icons.image_not_supported_outlined,
                          color: Colors.white30, size: 32),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  item.title.isEmpty ? 'Sin título' : item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              if (item.isTopHot)
                const Icon(Icons.local_fire_department_rounded,
                    color: ExFuturisticTheme.amber, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.product_short_description.isNotEmpty
                ? item.product_short_description
                : (item.description.isNotEmpty
                    ? item.description
                    : 'Recurso listo para promocionar.'),
            maxLines: compact ? 3 : 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              height: 1.45,
              fontFamily: 'Poppins',
            ),
          ),
          const Spacer(),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: _StatPill(
                  label: 'Precio',
                  value: item.price.isEmpty ? '--' : item.price,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatPill(
                  label: 'Ganancia',
                  value: item.sale_commision_you_will_get.isEmpty
                      ? item.total_commission
                      : item.sale_commision_you_will_get,
                  accent: ExFuturisticTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ExNeonButton(
              label: 'Copiar enlace',
              compact: true,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    this.accent = Colors.white,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
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
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: accent,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
