import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GeneratedCopy {
  final String productTitle;
  final String copy;
  final String socialMedia;
  final DateTime date;

  GeneratedCopy({
    required this.productTitle,
    required this.copy,
    required this.socialMedia,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'productTitle': productTitle,
    'copy': copy,
    'socialMedia': socialMedia,
    'date': date.toIso8601String(),
  };

  factory GeneratedCopy.fromJson(Map<String, dynamic> json) => GeneratedCopy(
    productTitle: json['productTitle'],
    copy: json['copy'],
    socialMedia: json['socialMedia'],
    date: DateTime.parse(json['date']),
  );
}

class CopyHistoryService {
  static const String _key = 'ai_copy_history_v2';
  
  static Future<void> saveCopy(String productTitle, String copy, String socialMedia) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    
    final newCopy = GeneratedCopy(
      productTitle: productTitle,
      copy: copy,
      socialMedia: socialMedia,
      date: DateTime.now(),
    );

    history.insert(0, newCopy);
    if (history.length > 10) history.removeLast();

    final String encoded = jsonEncode(history.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  static Future<List<GeneratedCopy>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_key);
    if (encoded == null) return [];
    
    final List<dynamic> decoded = jsonDecode(encoded);
    return decoded.map((item) => GeneratedCopy.fromJson(item)).toList();
  }
}
