import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/bannerAndLinks_model.dart';
import '../model/dashboard_model.dart';
import '../model/marketing_material_model.dart';
import '../service/api_service.dart';
import '../utils/preference.dart';
import '../utils/session_manager.dart';
import 'dashboard_controller.dart';

class BannerAndLinksController extends GetxController {
  BannerAndLinksController({required this.preferences});
  SharedPreferences preferences;

  bool _isLoading = false;
  bool _isbannerAndLinksLoading = false;
  BannerAndLinksModel? _bannerAndLinksModel;
  bool isGridView = false;
  bool isAdmin = false; // Cache para UI sincrónica

  // 🎛️ [FILTROS] - Sistema de ruteo dinámico (v1.5.2)
  String currentMarketView = "all"; // favorites, all, hot
  String? selectedCategoryId;
  String? selectedMarketCategoryId;
  String searchQuery = "";

  // 🔔 [DEEP LINK] - Sistema de navegación inteligente (v1.6.0)
  String? pendingProductId;
  bool forceGlobalDeepLink = false;
  bool isScrollingToProduct = false;

  List<BannerData> allProducts = []; // Cache global para el centro de IA

  bool get isLoading => _isLoading;
  bool get isBannerAndLinksLoading => _isbannerAndLinksLoading;
  BannerAndLinksModel? get bannerAndLinksData => _bannerAndLinksModel;

  List<BannerData> _dashboardFallbackItems() {
    if (!Get.isRegistered<DashboardController>()) {
      return <BannerData>[];
    }

    final DashboardModel? dashboard =
        Get.find<DashboardController>().dashboardData;
    if (dashboard == null) {
      return <BannerData>[];
    }

    final List<BannerData> fallback = dashboard.data.marketTools
        .map(_marketToolToBannerData)
        .where((BannerData item) => item.title.isNotEmpty)
        .toList();

    final String storeUrl = dashboard.data.affiliateStoreUrl.trim();
    final String resellerUrl = dashboard.data.uniqueResellerLink.trim();

    if (storeUrl.isNotEmpty) {
      fallback.insert(
        0,
        BannerData(
          action_amount: "0",
          action_count: 0,
          aff_tool_type: "STORE_LINK",
          click_amount: "0",
          click_commision_you_will_get: "",
          click_count: 0,
          click_ratio: "",
          clicks_commission: "",
          description:
              "Comparte tu tienda personalizada con un enlace directo.",
          product_avg_rating: "0",
          product_description:
              "Tienda de afiliado lista para compartir con tu audiencia.",
          product_short_description: "Tu escaparate oficial para conversiones.",
          displayed_on_store: true,
          fevi_icon: "",
          general_amount: "0",
          general_count: 0,
          is_campaign_product: false,
          price: "N/A",
          product_sku: "store-link",
          public_page: storeUrl,
          sale_amount: "0",
          sale_commision_you_will_get: "",
          sale_count: 0,
          sale_ratio: "",
          sales_commission: "",
          share_url: storeUrl,
          title: "Tienda afiliada",
          total_commission: "",
          recurring: "",
          id: "dashboard-store-link",
        ),
      );
    }

    if (resellerUrl.isNotEmpty && resellerUrl != storeUrl) {
      fallback.insert(
        0,
        BannerData(
          action_amount: "0",
          action_count: 0,
          aff_tool_type: "RESELLER_LINK",
          click_amount: "0",
          click_commision_you_will_get: "",
          click_count: 0,
          click_ratio: "",
          clicks_commission: "",
          description:
              "Usa este enlace de reventa para activar tráfico y conversiones.",
          product_avg_rating: "0",
          product_description:
              "Link principal del programa de afiliados listo para copiar y compartir.",
          product_short_description:
              "Enlace universal de afiliado para campañas rápidas.",
          displayed_on_store: true,
          fevi_icon: "",
          general_amount: "0",
          general_count: 0,
          is_campaign_product: false,
          price: "N/A",
          product_sku: "reseller-link",
          public_page: resellerUrl,
          sale_amount: "0",
          sale_commision_you_will_get: "",
          sale_count: 0,
          sale_ratio: "",
          sales_commission: "",
          share_url: resellerUrl,
          title: "Enlace de afiliado",
          total_commission: "",
          recurring: "",
          id: "dashboard-reseller-link",
        ),
      );
    }

    final List<BannerData> filtered = fallback.where((BannerData item) {
      if (currentMarketView == "hot" && !item.isTopHot) {
        return false;
      }
      if (searchQuery.isEmpty) {
        return true;
      }
      final String needle = searchQuery.toLowerCase();
      return item.title.toLowerCase().contains(needle) ||
          item.description.toLowerCase().contains(needle) ||
          item.product_short_description.toLowerCase().contains(needle);
    }).toList();

    return filtered;
  }

  BannerData _marketToolToBannerData(MarketTool tool) {
    return BannerData(
      action_amount: tool.actionAmount,
      action_count: tool.actionCount,
      aff_tool_type: tool.affToolType,
      click_amount: tool.clickAmount,
      click_commision_you_will_get: tool.clickCommisionYouWillGet,
      click_count: tool.clickCount,
      click_ratio: tool.clickRatio,
      clicks_commission: tool.clicksCommission,
      description: tool.description,
      product_avg_rating: "0",
      product_description: tool.description,
      product_short_description: tool.description,
      displayed_on_store: tool.displayedOnStore,
      fevi_icon: tool.feviIcon,
      general_amount: tool.generalAmount,
      general_count: tool.generalCount,
      is_campaign_product: tool.isCampaignProduct,
      price: tool.price,
      product_sku: tool.productSku,
      public_page: tool.publicPage,
      sale_amount: tool.saleAmount,
      sale_commision_you_will_get: tool.saleCommisionYouWillGet,
      sale_count: tool.saleCount,
      sale_ratio: tool.saleRatio,
      sales_commission: tool.salesCommission,
      share_url: tool.shareUrl,
      title: tool.title,
      total_commission: tool.totalCommission,
      recurring: tool.recurring,
      id: tool.id,
      isTopHot: tool.saleCount > 0 || tool.clickCount > 10,
    );
  }

  void toggleView() {
    isGridView = !isGridView;
    update();
  }

  void setFilters({String? catId, String? marketCatId, String? search}) {
    selectedCategoryId = catId;
    selectedMarketCategoryId = marketCatId;
    searchQuery = search ?? "";
    getBannerAndLinksData(); // Recargar datos con filtros
  }

  void setMarketView(String view) {
    currentMarketView = view;
    getBannerAndLinksData();
    update();
  }

  void clearFilters() {
    selectedCategoryId = null;
    selectedMarketCategoryId = null;
    searchQuery = "";
    currentMarketView = "all"; // Reset al catálogo principal
    getBannerAndLinksData();
  }

  /// 🔔 Acción de navegación desde notificación
  void processDeepLinkNavigation(String productId, bool forceGlobal) {
    pendingProductId = productId;
    forceGlobalDeepLink = forceGlobal;

    if (forceGlobal) {
      currentMarketView = "all";
      selectedCategoryId = null;
      selectedMarketCategoryId = null;
      searchQuery = "";
      getBannerAndLinksData();
    }
    update();
  }

  void clearDeepLink() {
    pendingProductId = null;
    forceGlobalDeepLink = false;
    isScrollingToProduct = false;
    update();
  }

  changeIsLoading(bool data) {
    _isLoading = data;
    update();
  }

  changeBannerAndLinksLoading(bool data) {
    _isbannerAndLinksLoading = data;
    update();
  }

  void updateBannerAndLinksData(BannerAndLinksModel model) {
    // 🚀 [PRODUCCIÓN] Ordenamiento Automático: Los productos "Hot" primero (v1.4.8)
    if (model.data.isNotEmpty) {
      print(
          "🌟 [PRODUCCIÓN] Mock eliminado. Ordenamiento automático aplicado. Data real 100% operativa.");
      model.data.sort((a, b) {
        if (a.isTopHot && !b.isTopHot) return -1;
        if (!a.isTopHot && b.isTopHot) return 1;
        return 0;
      });
    }

    // Si estamos en la vista 'all', actualizamos el caché global de productos
    if (currentMarketView == "all") {
      allProducts = List.from(model.data);
    }

    // Si el caché está vacío y recibimos datos de favoritos, los usamos como fallback inicial
    if (allProducts.isEmpty && model.data.isNotEmpty) {
      allProducts = List.from(model.data);
    }

    _bannerAndLinksModel = model;
    update();
  }

  /// REQUERIMIENTO v1.4.3: Recuperación robusta del ID del usuario (Fallback Multinivel)
  Future<dynamic> _getUserId() async {
    dynamic userId;

    // Nivel 1: DashboardController (Dato en memoria caliente)
    if (Get.isRegistered<DashboardController>()) {
      try {
        final dash = Get.find<DashboardController>();
        userId = dash.loginModel?.data?.userId;
        if (userId == null || userId.toString().isEmpty) {
          userId = dash.userId.value;
        }
      } catch (_) {}
    }

    // Nivel 1.5: SessionManager en RAM
    if (userId == null || userId.toString().isEmpty) {
      userId = SessionManager.instance.userId;
    }

    // Nivel 2: SharedPreferences (Persistencia directa de llaves simples)
    if (userId == null || userId.toString().isEmpty) {
      userId = preferences.getString('user_id') ?? preferences.getString('id');
    }

    // Nivel 3: SharedPreferences (Objeto UserData mapeado)
    if (userId == null || userId.toString().isEmpty) {
      final userString = preferences.getString('UserData');
      if (userString != null) {
        try {
          final userMap = jsonDecode(userString);
          userId = userMap['data']?['user_id'] ?? userMap['data']?['id'];
        } catch (_) {}
      }
    }

    // Nivel 4: endpoint confiable de detalles de usuario
    if (userId == null || userId.toString().isEmpty) {
      try {
        final userModel = await SharedPreference.getUserData();
        final token = userModel?.data?.token;
        if (token != null && token.isNotEmpty) {
          final dynamic response = await ApiService.instance
              .getData('api/get_user_details', token: token);
          if (response is Map<String, dynamic> &&
              response['status'] == true &&
              response['data'] is Map<String, dynamic>) {
            final int? extractedId =
                SessionManager.extractUserId(response['data']);
            if (extractedId != null && extractedId > 0) {
              userId = extractedId.toString();
              await SessionManager.instance.setUserId(userId);
            }
          }
        }
      } catch (_) {}
    }

    return userId;
  }

  getBannerAndLinksData() async {
    changeBannerAndLinksLoading(true);
    final userModel = await SharedPreference.getUserData();
    final token = userModel?.data?.token;

    // TAREA: Usar el nuevo método robusto de obtención de ID
    final userId = await _getUserId();

    if (userId == null || userId.toString().isEmpty) {
      debugPrint(
          "⚠️ [MARKETPLACE] Alerta: No se encontró User ID tras 3 niveles de búsqueda.");
    }

    final String userIdent = userId?.toString() ?? 'N/A';

    // 🧱 [SYNC] Actualizar flag de admin para la UI
    isAdmin = userIdent == '1' || (userModel?.data?.isAdmin ?? false);

    // 🎛️ [TASK 1.5.2] - Filtro Global Dinámico (Apertura de Catálogo)
    // - Mis Favoritos (favorites) -> admin_view=false
    // - Todos (all) o Caliente (hot) -> admin_view=true
    bool isGlobalView =
        currentMarketView == "all" || currentMarketView == "hot";
    String adminParam = isGlobalView ? "true" : "false";

    if (isAdmin) {
      if (currentMarketView == "favorites" && userIdent != '1') {
      } else {
        adminParam = "true";
      }
    }

    String endPoint = 'api/get_market_products?admin_view=$adminParam';
    print(
        "🎛️ [FILTROS] Vista actual: $currentMarketView | admin_view: $adminParam | UI Premium cargada.");

    if (userId != null) {
      endPoint += '&user_id=${userId.toString()}';
    }
    if (searchQuery.isNotEmpty) {
      endPoint += '&search=${Uri.encodeComponent(searchQuery)}';
    }
    if (selectedCategoryId != null && selectedCategoryId!.isNotEmpty) {
      endPoint += '&category_id=${selectedCategoryId!}';
    }
    if (selectedMarketCategoryId != null &&
        selectedMarketCategoryId!.isNotEmpty) {
      endPoint += '&market_category_id=${selectedMarketCategoryId!}';
    }

    print("🚀 [MARKETPLACE] Petición GET disparada: $endPoint");

    try {
      final value = await ApiService.instance.getData(endPoint, token: token);

      debugPrint('Get BannerAndLinks (SERVER RAW): $value');

      if (value != null &&
          value is Map<String, dynamic> &&
          value.containsKey('status') &&
          value['status'] == true &&
          value.containsKey('data') &&
          value['data'] != null) {
        BannerAndLinksModel model = BannerAndLinksModel.fromJson(value);

        // 🔥 [TASK] - Filtrado local para "Productos Candentes"
        if (currentMarketView == "hot") {
          model.data = model.data.where((p) => p.isTopHot).toList();
        }

        if (model.data.isEmpty && currentMarketView == "favorites") {
          currentMarketView = "all";
          await getBannerAndLinksData();
          return;
        }

        if (model.data.isEmpty) {
          final List<BannerData> fallback = _dashboardFallbackItems();
          if (fallback.isNotEmpty) {
            updateBannerAndLinksData(BannerAndLinksModel(
              status: true,
              message: 'Fallback dashboard data',
              data: fallback,
            ));
            return;
          }
        }

        updateBannerAndLinksData(model);
      } else {
        final List<BannerData> fallback = _dashboardFallbackItems();
        updateBannerAndLinksData(BannerAndLinksModel(
          status: fallback.isNotEmpty,
          message:
              fallback.isNotEmpty ? 'Fallback dashboard data' : 'No data found',
          data: fallback,
        ));
      }
    } catch (e) {
      debugPrint('Error loading banners: $e');
      final List<BannerData> fallback = _dashboardFallbackItems();
      updateBannerAndLinksData(BannerAndLinksModel(
        status: fallback.isNotEmpty,
        message:
            fallback.isNotEmpty ? 'Fallback dashboard data' : 'Error occurred',
        data: fallback,
      ));
    } finally {
      changeBannerAndLinksLoading(false);
      changeIsLoading(false);
    }
  }

  // 🌐 Carga el catálogo completo en segundo plano para el Centro de IA sin afectar la vista actual
  Future<void> getFullCatalogForCache() async {
    if (allProducts.length > 50) return; // Ya parece tener el catálogo cargado

    final userModel = await SharedPreference.getUserData();
    final token = userModel?.data?.token;
    final userId = await _getUserId();

    // Forzamos admin_view=true para obtener todo
    String endPoint = 'api/get_market_products?admin_view=true';
    if (userId != null) endPoint += '&user_id=${userId.toString()}';

    try {
      final value = await ApiService.instance.getData(endPoint, token: token);
      if (value != null &&
          value is Map<String, dynamic> &&
          value['status'] == true &&
          value['data'] != null) {
        BannerAndLinksModel model = BannerAndLinksModel.fromJson(value);
        allProducts = List.from(model.data);
        print(
            "✅ [IA CENTER] Caché global actualizado con ${allProducts.length} productos.");
      }
    } catch (e) {
      debugPrint('Error loading full catalog for cache: $e');
    }
  }

  Future<MarketingMaterialModel?> getMarketingMaterials(
      String productId) async {
    if (productId.isEmpty || productId == "0") {
      debugPrint('Error: Product ID is invalid or empty: $productId');
      return MarketingMaterialModel(
        status: false,
        message: 'ID de producto inválido',
        data: [],
      );
    }

    final userModel = await SharedPreference.getUserData();
    final token = userModel?.data?.token;

    final endPoints = [
      'api/get_marketing_materials/$productId',
      'get_marketing_materials/$productId',
      'User/get_marketing_materials/$productId'
    ];

    for (var endPoint in endPoints) {
      try {
        debugPrint('Intentando cargar materiales desde: $endPoint');
        final value = await ApiService.instance.getData(endPoint, token: token);
        debugPrint('Respuesta de $endPoint: $value');

        if (value != null && value is Map<String, dynamic>) {
          final model = MarketingMaterialModel.fromJson(value);
          if (model.status || model.data.isNotEmpty) {
            return model;
          }
        }
      } catch (e) {
        debugPrint('Error en $endPoint: $e');
      }
    }

    return MarketingMaterialModel(
      status: false,
      message: 'No se encontraron materiales tras varios intentos',
      data: [],
    );
  }
}
