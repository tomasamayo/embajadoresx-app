import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/wallet_model.dart'; // This file must define WalletModel and WalletData
import '../service/api_service.dart';
import '../utils/preference.dart';

class WalletController extends GetxController {
  WalletController();
  SharedPreferences? preferences;

  @override
  void onInit() {
    super.onInit();
    _initPrefs();
  }

  void _initPrefs() async {
    preferences = await SharedPreferences.getInstance();
  }

  bool _isLoading = false;
  bool _isWalletLoading = false;
  WalletModel? _walletModel;

  bool get isLoading => _isLoading;
  bool get isWalletLoading => _isWalletLoading;
  WalletModel? get walletData => _walletModel;

  String paid = '';
  String action = '';

  changeIsLoading(bool data) {
    _isLoading = data;
    update();
  }

  changeWalletLoading(bool data) {
    _isWalletLoading = data;
    update();
  }

  updateWalletData(WalletModel model) {
    _walletModel = model;
    update();
  }

  updateActionAndPaid({paidStatus, type}) {
    if (paidStatus != null) paid = paidStatus;
    if (type != null) action = type;
  }

  getWalletData(int pageId, int perPage) async {
    try {
      debugPrint('paid_status: $paid');
      debugPrint('type: $action');

      changeWalletLoading(true);
      final userModel = await SharedPreference.getUserData();
      final token = userModel?.data?.token;
      String endPoint = 'My_Wallet/my_wallet';

      final Map<String, dynamic> requestBody = {
        'page_id': pageId,
        'per_page': perPage,
        if (paid != '') 'paid_status': paid,
        if (action != '') 'type': action,
      };

      var value = await ApiService.instance.postData(endPoint, requestBody);
      debugPrint('Get Wallet : ${jsonEncode(value)}');

      if (value != null &&
          value is Map<String, dynamic> &&
          value.containsKey('status') &&
          value['status'] == true &&
          value.containsKey('data') &&
          value['data'] != null) {
        updateWalletData(WalletModel.fromJson(value));
      } else {
        updateWalletData(WalletModel(
          status: false,
          message: 'No wallet data',
          data: Data.fromJson({}),
        ));
      }
    } catch (e) {
      debugPrint('Error getting wallet data: $e');
      updateWalletData(WalletModel(
        status: false,
        message: 'Failed to load',
        data: Data.fromJson({}),
      ));
    } finally {
      changeWalletLoading(false);
    }
  }
}