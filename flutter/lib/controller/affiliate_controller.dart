// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../model/bannerAndLinks_model.dart';
// import '../model/user_model.dart';
// import '../service/api_service.dart';
// import '../utils/preference.dart';

// class AffiliateController extends GetxController {
//   AffiliateController({required this.preferences});
//   SharedPreferences preferences;

//   bool _isLoading = false;
//   bool _isaffiliateLoading = false;
//   BannerAndLinksModel? _affiliateModel;

//   bool get isLoading => _isLoading;
//   bool get isaffiliateLoading => _isaffiliateLoading;
//   AffiliateModel? get affiliateData => _affiliateModel;

//   changeIsLoading(bool data) {
//     _isLoading = data;
//     update();
//   }

//   changeAffiliateLoading(bool data) {
//     _isaffiliateLoading = data;
//     update();
//   }

//   updateAffiliateData(AffiliateModel model) {
//     _affiliateModel = model;
//     update();
//   }

//   getAffiliateData() async {
//     changeAffiliateLoading(true);
//     final userModel = await SharedPreference.getUserData();
//     final token = userModel?.data?.token;
//     String endPoint = 'User/my_affiliate_links';
//     Map<String, String> bodyParams = {};
//     await ApiService.instance
//         .postData2(endPoint, bodyParams, token: token)
//         .then((value) {
//       debugPrint('Get Affiliate : $value');
//       if (value != null) {
//         updateAffiliateData(AffiliateModel.fromJson(value));
//       }
//     });
//     changeAffiliateLoading(false);
//   }
// }
