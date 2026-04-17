import 'package:flutter/material.dart';
import 'package:affiliatepro_mobile/service/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:affiliatepro_mobile/view/screens/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlockedUserPage extends StatefulWidget {
  const BlockedUserPage({super.key});

  @override
  State<BlockedUserPage> createState() => _BlockedUserPageState();
}

class _BlockedUserPageState extends State<BlockedUserPage> {
  List<dynamic> plans = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token') ?? '';

    final response = await ApiService.instance.getData(
      'Subscription_Plan/get_membership_plan',
      token: 'Bearer $token',
    );

    if (response?['status'] == true && response?['data']['plans'] != null) {
      setState(() {
        plans = response?['data']['plans'];
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Acceso Denegado")),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : plans.isEmpty
          ? Center(child: Text("No hay planes disponibles. Por favor visita el sitio web."))
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("Precio: ${plan['price']}"),
                  SizedBox(height: 8),
                  Text(plan['description'] ?? '', maxLines: 3, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      String paymentUrl = "${ApiService.instance.baseUrl}/membership/buy/${plan['id']}";
                      final uri = Uri.parse(paymentUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No se puede abrir la página de pago')),
                        );
                      }
                    },
                    child: Text("Comprar este plan"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton.icon(
          icon: Icon(Icons.logout),
          label: Text("Volver al Inicio de Sesión"),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
            );
          },
        ),
      ),
    );
  }
}