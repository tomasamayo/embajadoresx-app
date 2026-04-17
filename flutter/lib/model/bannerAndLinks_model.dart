import 'dart:convert';
import 'package:flutter/foundation.dart';

BannerAndLinksModel dashboardModelFromJson(String str) =>
    BannerAndLinksModel.fromJson(json.decode(str));

class BannerAndLinksModel {
  BannerAndLinksModel({
    required this.status,
    required this.message,
    required this.data,
  });

  bool status;
  String message;
  List<BannerData> data;

  factory BannerAndLinksModel.fromJson(Map<String, dynamic> json) =>
      BannerAndLinksModel(
        status: json["status"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] != null && json["data"] is List
            ? List<BannerData>.from(
                (json["data"] as List).map((x) => BannerData.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class BannerData {
  BannerData({
    required this.action_amount,
    required this.action_count,
    required this.aff_tool_type,
    required this.click_amount,
    required this.click_commision_you_will_get,
    required this.click_count,
    required this.click_ratio,
    required this.clicks_commission,
    required this.description,
    required this.product_avg_rating,
    required this.product_description,
    required this.product_short_description,
    required this.displayed_on_store,
    required this.fevi_icon,
    required this.general_amount,
    required this.general_count,
    required this.is_campaign_product,
    required this.price,
    required this.product_sku,
    required this.public_page,
    required this.sale_amount,
    required this.sale_commision_you_will_get,
    required this.sale_count,
    required this.sale_ratio,
    required this.sales_commission,
    required this.share_url,
    required this.title,
    required this.total_commission,
    required this.recurring,
    required this.id,
    this.is_favorite = false,
    this.isTopHot = false,
    this.totalAffiliates = 0,
    this.affiliatesAvatars = const [],
  });

  String id;
  bool is_favorite;
  bool isTopHot;
  int totalAffiliates;
  List<String> affiliatesAvatars;
  String aff_tool_type;
  bool is_campaign_product;
  String public_page;
  String share_url;
  String fevi_icon;
  String title;
  String recurring;
  String sale_commision_you_will_get;
  String click_commision_you_will_get;
  String description;
  String product_avg_rating; // Cambiado a String para cumplir con la estructura obligatoria ("5", "0")
  String product_description;
  String product_short_description;
  String price;
  String product_sku;
  String sales_commission;
  String clicks_commission;
  String total_commission;
  bool displayed_on_store;
  dynamic sale_count;
  String sale_amount;
  dynamic click_count;
  String click_amount;
  String click_ratio;
  dynamic general_count;
  String general_amount;
  String sale_ratio;
  dynamic action_count;
  String action_amount;

  // Método público para que el controlador/scraper inyecte la calificación
  static String extractRatingFromMap(Map<String, dynamic> json) {
    return _extractAverageRating(json);
  }

  factory BannerData.fromJson(Map<String, dynamic> json) {
    if (json["aff_tool_type"]?.toString().toUpperCase() == "STORE_PRODUCT") {
      debugPrint("DEBUG STORE_PRODUCT [${json["title"]}]: ${json.keys.toList()}");
    }
    
    // REGLA DE ORO: PRIORIDAD ABSOLUTA AL DATO DE LA API
    final rawRating = json["product_avg_rating"];
    debugPrint("API RAW RATING para ${json["title"]}: $rawRating (Tipo: ${rawRating.runtimeType})");
    
    final String rating = (rawRating ?? _extractAverageRating(json)).toString();
    
    if (rating != "0") {
      debugPrint("SUCCESS: Rating detectado para ${json["title"]}: $rating");
    }
    final rawProductDescription = _extractProductDescription(json);
    // REQUERIMIENTO v1.4.6: Soporte para nueva estructura de llaves y tipos de datos (Fix Double Crash)
    final String title = json["name"]?.toString() ?? json["title"]?.toString() ?? "";
    final String fevi_icon = json["image"]?.toString() ?? json["fevi_icon"]?.toString() ?? "";
    final String share_url = json["url"]?.toString() ?? json["share_url"]?.toString() ?? "";
    final String price = json["formatted_price"]?.toString() ?? json["price"]?.toString() ?? "";
    debugPrint("🛡️ [FIX] Mapeo actualizado a la nueva estructura del JSON. Crash de tipo double resuelto.");

    return BannerData(
        aff_tool_type: json["aff_tool_type"] ?? "",
        public_page: json["public_page"] ?? "",
        fevi_icon: fevi_icon,
        title: title,
        share_url: share_url,
        click_commision_you_will_get: json["click_commision_you_will_get"] ?? "",
        click_ratio: json["click_ratio"] ?? "",
        recurring: json["recurring"] ?? "",
        general_count: json["general_count"] ?? 0,
        general_amount: json["general_amount"] ?? "",
        sale_commision_you_will_get: (json["sale_commision_you_will_get"] == null || json["sale_commision_you_will_get"].toString().isEmpty) ? "Variable" : json["sale_commision_you_will_get"].toString(),
        sale_ratio: json["sale_ratio"] ?? "",
        sale_count: json["sale_count"] ?? 0,
        sale_amount: json["sale_amount"] ?? "",
        click_count: json["click_count"] ?? 0,
        click_amount: json["click_amount"] ?? "",
        action_count: json["action_count"] ?? 0,
        action_amount: json["action_amount"] ?? "",
        is_campaign_product: json["is_campaign_product"] ?? false,
        description: json["description"]?.toString() ?? "",
        product_avg_rating: rating, // Ahora es String "5" o "0"
        product_description: _formatProductDescription(
          raw: rawProductDescription,
          title: (json["title"] ?? "").toString(),
          rating: rating,
        ),
        product_short_description: (json["product_short_description"] ?? 
                                   json["product"]?["product_short_description"] ?? 
                                   json["short_description"] ?? 
                                   "").toString(),
        price: price,
        product_sku: json["product_sku"] ?? "",
        sales_commission: json["sales_commission"] ?? "",
        clicks_commission: json["clicks_commission"] ?? "",
        total_commission: json["total_commission"] ?? "",
        displayed_on_store: json["displayed_on_store"] ?? false,
        id: _parseId(json),
        is_favorite: json["is_favorite"] == true || json["is_favorite"]?.toString() == "1",
        isTopHot: json["is_top_hot"] == true || json["is_top_hot"]?.toString() == "1" || json["is_top_hot"] == "true",
        totalAffiliates: int.tryParse(json["sales"]?.toString() ?? json["total_affiliates"]?.toString() ?? "0") ?? 0,
        affiliatesAvatars: json["affiliates_avatars"] != null && json["affiliates_avatars"] is List
            ? List<String>.from(json["affiliates_avatars"].map((x) => x.toString()))
            : [],
      );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "is_favorite": is_favorite,
        "aff_tool_type": aff_tool_type,
        "is_campaign_product": is_campaign_product,
        "public_page": public_page,
        "share_url": share_url,
        "fevi_icon": fevi_icon,
        "title": title,
        "recurring": recurring,
        "sale_commision_you_will_get": sale_commision_you_will_get,
        "click_commision_you_will_get": click_commision_you_will_get,
        "description": description,
        "product_description": product_description,
        "product_short_description": product_short_description,
        "price": price,
        "product_sku": product_sku,
        "sales_commission": sales_commission,
        "clicks_commission": clicks_commission,
        "total_commission": total_commission,
        "displayed_on_store": displayed_on_store,
        "product_avg_rating": product_avg_rating, // INYECTADO AQUÍ PARA QUE APAREZCA EN CONSOLA
        "sale_count": sale_count,
        "sale_amount": sale_amount,
        "click_count": click_count,
        "click_amount": click_amount,
        "click_ratio": click_ratio,
        "general_count": general_count,
        "general_amount": general_amount,
        "sale_ratio": sale_ratio,
        "action_count": action_count,
        "action_amount": action_amount,
        "is_top_hot": isTopHot,
        "total_affiliates": totalAffiliates,
        "affiliates_avatars": List<dynamic>.from(affiliatesAvatars.map((x) => x)),
      };

  static String _extractProductDescription(Map<String, dynamic> json) {
    // 1. Captura directa del campo actualizado en la API
    if (json.containsKey("product_description") && json["product_description"] != null) {
      return json["product_description"].toString();
    }
    
    // 2. Fallback recursivo por si el campo viene anidado
    String? foundDesc = _findFieldRecursive(json, "product_description");
    if (foundDesc != null && foundDesc.isNotEmpty) return foundDesc;

    return "";
  }

  static String _extractAverageRating(Map<String, dynamic> json) {
    // 1. REGLA DE ORO: EXTRAER DESDE TEXTO (Alta Fidelidad)
    final String fullJsonString = json.toString();
    
    // Buscar patrón: "(X Comentarios de clientes)" o "X Comentarios de clientes"
    final commentsRegex = RegExp(r'\(?(\d+(\.\d+)?)\s+comentarios\s+de\s+clientes\)?', caseSensitive: false);
    final commentsMatch = commentsRegex.firstMatch(fullJsonString);
    if (commentsMatch != null) {
      final val = commentsMatch.group(1) ?? "0";
      debugPrint("HIGH-FIDELITY: Found rating via text (Comments): $val");
      return val;
    }

    // Buscar patrón: "X estrellas" o "X.X estrellas"
    final starsTextRegex = RegExp(r'(\d+(\.\d+)?)\s+estrellas', caseSensitive: false);
    final starsTextMatch = starsTextRegex.firstMatch(fullJsonString);
    if (starsTextMatch != null) {
      final val = starsTextMatch.group(1) ?? "0";
      debugPrint("HIGH-FIDELITY: Found rating via text (Stars Text): $val");
      return val;
    }

    // Buscar patrón: Estrellas doradas (⭐) en el texto descriptivo o títulos
    final starsRegex = RegExp(r'(⭐+)');
    final productDesc = json["product_description"]?.toString() ?? "";
    final productTitle = json["title"]?.toString() ?? "";
    final productContent = json["product"]?.toString() ?? ""; // Ampliamos la búsqueda al objeto product
    
    final starsInDesc = starsRegex.firstMatch(productDesc);
    final starsInTitle = starsRegex.firstMatch(productTitle);
    final starsInContent = starsRegex.firstMatch(productContent);
    
    if (starsInDesc != null || starsInTitle != null || starsInContent != null) {
      int starCount = 0;
      if (starsInDesc != null) starCount = starsInDesc.group(1)!.length;
      else if (starsInTitle != null) starCount = starsInTitle.group(1)!.length;
      else if (starsInContent != null) starCount = starsInContent.group(1)!.length;

      if (starCount > 0) {
        debugPrint("HIGH-FIDELITY: Found rating via text (Stars): $starCount");
        return starCount.toString();
      }
    }

    // 2. BÚSQUEDA EN CLAVES ESTÁNDAR (Como fallback)
    const fields = [
      "product_avg_rating", "avg_rating", "average_rating", "rating",
      "product_rating", "productRating", "avgRating", "rating_avg",
      "total_rating", "stars"
    ];

    dynamic v;
    for (final f in fields) {
      if (json[f] != null && json[f].toString().toLowerCase() != 'null') {
        v = json[f];
        break;
      }
    }
    
    if (v == null && json["product"] != null) {
      final p = json["product"];
      if (p is Map) {
        for (final f in fields) {
          if (p[f] != null && p[f].toString().toLowerCase() != 'null') {
            v = p[f];
            break;
          }
        }
      } else if (p is List && p.isNotEmpty && p[0] is Map) {
        final first = p[0] as Map;
        for (final f in fields) {
          if (first[f] != null && first[f].toString().toLowerCase() != 'null') {
            v = first[f];
            break;
          }
        }
      }
    }
    
    if (v == null) {
      for (final f in fields) {
        final found = _findFieldRecursive(json, f);
        if (found != null && found.toLowerCase() != 'null') {
          v = found;
          break;
        }
      }
    }
    
    if (v == null) {
      final meta = json["product_meta"] ?? json["meta"];
      if (meta is Map && (meta["_wc_average_rating"] != null || meta["average_rating"] != null)) {
        v = meta["_wc_average_rating"] ?? meta["average_rating"];
      }
    }

    if (v == null) return "0"; // CLAVE OBLIGATORIA: Si no hay nada, pon '0'

    final s = v.toString().trim();
    if (s.isEmpty || s == "null") return "0";

    return s; // Retorna el número extraído como String ("5", "4.5", etc)
  }

  static String _starsForRating(String rating) {
    final val = double.tryParse(rating) ?? 0.0;
    final r = val.round().clamp(0, 5);
    if (r <= 0) return "";
    return List<String>.filled(r, "⭐").join();
  }

  static String _formatProductDescription({
    required String raw,
    required String title,
    required String rating,
  }) {
    // ELIMINADAS LAS ESTRELLAS DEL INICIO SEGÚN INSTRUCCIÓN UI
    if (raw.trim().isEmpty) return "";

    String html = raw;

    final lower = html.toLowerCase();
    final stopMarkers = <String>[
      "reseñas",
      "resenas",
      "reviews",
      "valoraciones",
      "comentarios",
      "massiell",
      "masiell",
      "<footer",
      "footer",
    ];
    int? stopAt;
    for (final m in stopMarkers) {
      final i = lower.indexOf(m);
      if (i >= 0) {
        stopAt = stopAt == null ? i : (i < stopAt ? i : stopAt);
      }
    }
    if (stopAt != null && stopAt! > 0) {
      html = html.substring(0, stopAt);
    }

    final normalizedTitle = title.trim();
    if (normalizedTitle.isNotEmpty) {
      final i = html.toLowerCase().indexOf(normalizedTitle.toLowerCase());
      if (i > 0) {
        html = html.substring(i);
      }
    }

    final h1i = html.toLowerCase().indexOf("<h1");
    if (h1i > 0 && (normalizedTitle.isEmpty || h1i < 1200)) {
      html = html.substring(h1i);
    }

    html = html.replaceAll("\r\n", "\n").replaceAll("\r", "\n");
    if (!html.contains("<")) {
      html = html.replaceAll("\n\n", "<br><br>").replaceAll("\n", "<br>");
    }

    html = html.replaceAll("✅", "<br>✅");
    html = html.replaceAll("<br><br><br>", "<br><br>");
    html = html.trim();

    return html;
  }

  // Función auxiliar para buscar un campo en cualquier nivel del JSON
  static String? _findFieldRecursive(dynamic data, String targetKey) {
    if (data is Map<String, dynamic>) {
      if (data.containsKey(targetKey) && data[targetKey] != null) {
        return data[targetKey].toString();
      }
      for (var value in data.values) {
        final result = _findFieldRecursive(value, targetKey);
        if (result != null) return result;
      }
    } else if (data is List) {
      for (var item in data) {
        final result = _findFieldRecursive(item, targetKey);
        if (result != null) return result;
      }
    }
    return null;
  }

  static String _parseId(Map<String, dynamic> json) {
    final primaryFields = ["ads_id", "id", "tool_id", "product_id"];
    for (var field in primaryFields) {
      final value = json[field];
      if (value == null) continue;
      final stringId = value.toString().trim();
      if (stringId.isEmpty || stringId == "0") continue;
      if (RegExp(r'^\d+$').hasMatch(stringId)) return stringId;
    }

    final urlFields = ["share_url", "public_page"];
    for (final field in urlFields) {
      final raw = json[field]?.toString() ?? "";
      final idFromUrl = _extractNumericIdFromUrl(raw);
      if (idFromUrl != null && idFromUrl.isNotEmpty && idFromUrl != "0") {
        return idFromUrl;
      }
    }

    return (json["product_id"] ??
            json["ads_id"] ??
            json["id"] ??
            json["product_sku"] ??
            "")
        .toString();
  }

  static String? _extractNumericIdFromUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;

    final uri = Uri.tryParse(trimmed);
    if (uri == null) return null;

    const queryKeys = ["product_id", "productId", "pid", "id", "tool_id", "ads_id"];
    for (final k in queryKeys) {
      final v = uri.queryParameters[k];
      if (v != null && RegExp(r'^\d+$').hasMatch(v) && v != "0") return v;
    }

    final segments = uri.pathSegments;
    for (int i = 0; i < segments.length - 1; i++) {
      final s = segments[i].toLowerCase();
      final next = segments[i + 1];
      if (next.isEmpty) continue;
      if (["product", "products", "producto", "productos", "p"].contains(s)) {
        if (RegExp(r'^\d+$').hasMatch(next) && next != "0") return next;
      }
      if (["details", "detail"].contains(s)) {
        if (RegExp(r'^\d+$').hasMatch(next) && next != "0") return next;
      }
    }

    final numericSegments =
        segments.where((s) => RegExp(r'^\d+$').hasMatch(s) && s != "0").toList();
    if (numericSegments.isNotEmpty) return numericSegments.last;

    final match = RegExp(r'(\d{1,10})').allMatches(uri.path).toList();
    if (match.isNotEmpty) return match.last.group(1);

    return null;
  }
}
