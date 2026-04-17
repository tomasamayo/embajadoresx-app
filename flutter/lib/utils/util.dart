import 'dart:async';

import 'package:flutter/material.dart';
import 'package:affiliatepro_mobile/utils/reachability.dart';
import 'package:affiliatepro_mobile/utils/text.dart';

import 'colors.dart';

class Utils {
  factory Utils() {
    return _singleton;
  }

  static final Utils _singleton = Utils._internal();

  Utils._internal() {
    debugPrint("Instance created Utils");
  }

  static void showSnackBar(BuildContext context, String? message,
      {int duration = 2, SnackBarAction? action}) {
    if ((message ?? '').isEmpty) {
      return;
    }

    final snackBar = SnackBar(
      content: Text(
        message!,
      ),
      backgroundColor: AppColor.appBlack,
      duration: Duration(seconds: duration),
      action: action,
    );

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static OverlayEntry? _topSnackEntry;
  static Timer? _topSnackTimer;

  static void showTopErrorSnackBar(
    BuildContext context,
    String? message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    final text = (message ?? '').trim();
    if (text.isEmpty) return;

    _topSnackTimer?.cancel();
    _topSnackTimer = null;
    _topSnackEntry?.remove();
    _topSnackEntry = null;

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      showSnackBar(context, text, duration: duration.inSeconds);
      return;
    }

    final entry = OverlayEntry(
      builder: (context) {
        final topPadding = MediaQuery.of(context).padding.top;
        return Positioned(
          top: topPadding + 12,
          left: 16,
          right: 16,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * -16),
                  child: child,
                ),
              );
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFB00020),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        text,
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
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
    _topSnackEntry = entry;
    _topSnackTimer = Timer(duration, () {
      _topSnackEntry?.remove();
      _topSnackEntry = null;
      _topSnackTimer?.cancel();
      _topSnackTimer = null;
    });
  }

  static bool isInternetAvailable(BuildContext context,
      {bool isInternetMessageRequire = true}) {
    bool isInternet = Reachability.instance.isInterNetAvailable();
    if (!isInternet && isInternetMessageRequire) {
      Utils.showSnackBar(context, AppText.msgInternetMessage);
    }
    return isInternet;
  }
}
