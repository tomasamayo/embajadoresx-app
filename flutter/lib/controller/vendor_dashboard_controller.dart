import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/api_service.dart';
import '../model/vendor_stats_model.dart';

class VendorDashboardController extends GetxController {
  final SharedPreferences preferences;
  VendorDashboardController({required this.preferences});

  var isLoading = false.obs;
  var vendorStats = Rxn<VendorStatsModel>();

  @override
  void onInit() {
    super.onInit();
    getVendorStats();
  }

  Future<void> getVendorStats() async {
    try {
      isLoading(true);
      final token = preferences.getString('token');
      if (token == null) return;

      final response = await ApiService.instance.getData(
        'Subscription_Plan/get_vendor_stats',
        token: token,
      );

      if (response != null) {
        vendorStats.value = VendorStatsModel.fromJson(response);
      }
    } catch (e) {
      print("Error fetching vendor stats: $e");
    } finally {
      isLoading(false);
    }
  }
}
