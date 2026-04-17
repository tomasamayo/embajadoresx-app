import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/payments_detail_model.dart';
import '../service/api_service.dart';
import '../utils/preference.dart';

class PaymentDetailController extends GetxController {
  bool _isLoading = false;
  bool _isPaymentDetailLoading = false;
  PaymentResponseModel? _PaymentDetailModel;

  bool get isLoading => _isLoading;
  bool get isPaymentDetailLoading => _isPaymentDetailLoading;
  PaymentResponseModel? get PaymentDetailData => _PaymentDetailModel;

  changeIsLoading(bool data) {
    _isLoading = data;
    update();
  }

  changePaymentDetailLoading(bool data) {
    _isPaymentDetailLoading = data;
    update();
  }

  updatePaymentDetailData(PaymentResponseModel model) {
    _PaymentDetailModel = model;
    update();
  }

  addBankAccount(
      String bankName,
      String accountNumber,
      String accountName,
      String countryCode,
      Map<String, String> countrySpecificFields,
      ) async {
    changePaymentDetailLoading(true);
    final userModel = await SharedPreference.getUserData();
    final token = userModel?.data?.token;
    String endPoint = 'user/payment_details';

    final Map<String, dynamic> requestBody = {
      'payment_bank_name': bankName,
      'payment_account_number': accountNumber,
      'payment_account_name': accountName,
      'payment_country': countryCode,
      ...countrySpecificFields, // This correctly spreads the country-specific fields
    };

    await ApiService.instance.postData(endPoint, requestBody).then((value) {
      String prettyPrintedValue = JsonEncoder.withIndent('  ').convert(value);
      debugPrint('Add Bank Account: $prettyPrintedValue');
      if (value != null) {
        // Optionally update local data
      }
    });

    changePaymentDetailLoading(false);
    getPaymentsData();
  }

  addPaypalAccount(String paypalEmail) async {
    changePaymentDetailLoading(true);
    final userModel = await SharedPreference.getUserData();
    final token = userModel?.data?.token;
    String endPoint = 'user/payment_details';

    final Map<String, dynamic> requestBody = {
      'add_paypal': 'Submit',
      'paypal_email': paypalEmail,
    };

    await ApiService.instance.postData(endPoint, requestBody).then((value) {
      String prettyPrintedValue = JsonEncoder.withIndent('  ').convert(value);
      debugPrint('Add PayPal Account: $prettyPrintedValue');
    });

    changePaymentDetailLoading(false);
    getPaymentsData();
  }

  addPrimaryPaymentMethod(String paymentMethod) async {
    changePaymentDetailLoading(true);
    final userModel = await SharedPreference.getUserData();
    final token = userModel?.data?.token;
    String endPoint = 'user/payment_details';

    final Map<String, dynamic> requestBody = {
      'add_primary_payment': 'Submit',
      'primary_payment_method': paymentMethod,
    };

    await ApiService.instance.postData(endPoint, requestBody).then((value) {
      String prettyPrintedValue = JsonEncoder.withIndent('  ').convert(value);
      debugPrint('Add Primary Payment Method: $prettyPrintedValue');
    });

    changePaymentDetailLoading(false);
    getPaymentsData();
  }

  getPaymentsData() async {
    changePaymentDetailLoading(true);
    final userModel = await SharedPreference.getUserData();
    final token = userModel?.data?.token;
    String endPoint = 'user/get_payment_details';

    await ApiService.instance.getData(endPoint, token: token).then((value) {
      if (value != null) {
        String prettyPrintedValue = JsonEncoder.withIndent('  ').convert(value);
        debugPrint('Get Payments Data: $prettyPrintedValue');
        updatePaymentDetailData(PaymentResponseModel.fromJson(value));
      } else {
         debugPrint('Get Payments Data: null value received');
      }
    }).catchError((error) {
       debugPrint('Get Payments Data Error: $error');
    });

    changePaymentDetailLoading(false);
  }
}