import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/reports_model.dart';
import '../service/api_service.dart';
import '../utils/preference.dart';

class ReportController extends GetxController {
  ReportController({required this.preferences});
  SharedPreferences preferences;

  bool _isLoading = false;
  bool _isReportLoading = false;
  ReportModel? _ReportModel;

  bool get isLoading => _isLoading;
  bool get isReportLoading => _isReportLoading;
  ReportModel? get ReportData => _ReportModel;

  String paid = 'paid';
  String action = 'actions';

  changeIsLoading(bool data) {
    _isLoading = data;
    update();
  }

  changeReportLoading(bool data) {
    _isReportLoading = data;
    update();
  }

  updateReportData(ReportModel model) {
    _ReportModel = model;
    update();
  }

  updateActionAndPaid(paidStatus, type) {
    if (paidStatus != null) paid = paidStatus;
    if (type != null) action = type;
  }

  getReportData(int pageId, int perPage) async {
    changeReportLoading(true);
    final userModel = await SharedPreference.getUserData();
    final userId = userModel?.data?.userId ?? "37"; // REQUERIMIENTO V1.2.1.1: Blindaje de persistencia
    final token = userModel?.data?.token;
    String endPoint = 'User_Reports/get_user_reports';

    // v54.0.0: page_id y per_page obligatorios (20)
    final Map<String, dynamic> requestBody = {
      'user_id': userId, // Inyectar user_id explícitamente para evitar pérdida de sesión
      'page_id': pageId > 0 ? pageId : 1,
      'per_page': 20,
    };

    try {
      final value = await ApiService.instance.postData(endPoint, requestBody);
      debugPrint('Get Report : ${jsonEncode(value)}');

      if (value != null &&
          value is Map<String, dynamic> &&
          value.containsKey('status') &&
          value['status'] == true &&
          value.containsKey('data') &&
          value['data'] != null) {
        updateReportData(ReportModel.fromJson(value));
      } else {
        updateReportData(ReportModel(
          status: false,
          message: 'No data returned',
          data: Data(
            referStatus: false,
            statistics: Statistics(),
          ),
        ));
      }
    } catch (e) {
      debugPrint('Error loading report: $e');
      updateReportData(ReportModel(
        status: false,
        message: 'Error occurred',
        data: Data(
          referStatus: false,
          statistics: Statistics(),
        ),
      ));
    }
    changeReportLoading(false);
  }
}
