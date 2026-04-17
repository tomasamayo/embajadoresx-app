import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/Payments_model.dart';
import '../service/api_service.dart';
import '../utils/preference.dart';

class PaymentsController extends GetxController {
  PaymentsController({required this.preferences});
  SharedPreferences preferences;

  bool _isLoading = false;
  bool _isPaymentsLoading = false;
  PaymentsListModel? _PaymentsModel;

  int _pageId = 1;
  int _perPage = 1;
  
  int get pageIdd => _pageId;
  int get perPagee => _perPage;

  bool get isLoading => _isLoading;
  bool get isPaymentsLoading => _isPaymentsLoading;
  PaymentsListModel? get PaymentsData => _PaymentsModel;

  changeIsLoading(bool data) {
    _isLoading = data;
    update();
  }

  changePaymentsLoading(bool data) {
    _isPaymentsLoading = data;
    update();
  }

  updatePaymentsData(PaymentsListModel model) {
    _PaymentsModel = model;
    update();
  }

  updatePageIdandPerPage(pageIdFunction, perPageFunction) {
    _pageId = pageIdFunction;
    _perPage = perPageFunction;
    update();
  }

  getPaymentsData() async {
    changePaymentsLoading(true);
    final userModel = await SharedPreference.getUserData();
    final token = userModel?.data?.token;
    String endPoint = 'user/all_transaction?per_page=$_perPage&page_id=$_pageId';
  
    await ApiService.instance.getData(endPoint, token: token).then((value) {
      if (value == null || value is! Map<String, dynamic>) {
        updatePaymentsData(PaymentsListModel(status: false, message: 'No data', data: []));
        return;
      }
      try {
        updatePaymentsData(PaymentsListModel.fromJson(value));
      } catch (e) {
        debugPrint('Get Payments parse error: $e');
        updatePaymentsData(PaymentsListModel(status: false, message: 'Error', data: []));
      }
    });

    changePaymentsLoading(false);
  }
}
