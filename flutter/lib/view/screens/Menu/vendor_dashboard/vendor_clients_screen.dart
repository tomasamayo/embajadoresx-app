import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../controller/vendor_clients_controller.dart';

class VendorClientsScreen extends StatefulWidget {
  const VendorClientsScreen({super.key});

  @override
  State<VendorClientsScreen> createState() => _VendorClientsScreenState();
}

class _VendorClientsScreenState extends State<VendorClientsScreen> {
  late VendorClientsController controller;
  bool _isControllerReady = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
        if (!controller.isMoreLoading.value && controller.currentPage < controller.totalPages) {
          controller.getClients(refresh: false);
        }
      }
    });
  }

  Future<void> _initController() async {
    final prefs = await SharedPreferences.getInstance();
    controller = Get.put(VendorClientsController(preferences: prefs));
    setState(() {
      _isControllerReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isControllerReady) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00FF88))),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Clientes de la tienda",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            fontFamily: 'Poppins',
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0A), Color(0xFF001A0F)],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value && controller.clients.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF00FF88)));
            }
            return RefreshIndicator(
              onRefresh: () => controller.getClients(refresh: true),
              color: const Color(0xFF00FF88),
              backgroundColor: const Color(0xFF1A1A1A),
              child: controller.clients.isEmpty ? _buildEmptyState() : _buildClientsList(),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildClientsList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: controller.clients.length + (controller.isMoreLoading.value ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == controller.clients.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator(color: Color(0xFF00FF88))),
          );
        }

        final client = controller.clients[index];
        return FadeInUp(
          duration: Duration(milliseconds: 400 + (index % 10 * 100)),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.2), width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: client.avatar,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: const Color(0xFF1A1A1A)),
                      errorWidget: (context, url, error) => Container(
                        color: const Color(0xFF1A1A1A),
                        child: const Icon(Icons.person, color: Color(0xFF00FF88), size: 24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        client.email,
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 10, color: const Color(0xFF00FF88).withOpacity(0.5)),
                          const SizedBox(width: 4),
                          Text(
                            "Cliente desde: ${client.createdAt}",
                            style: TextStyle(color: const Color(0xFF00FF88).withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeIn(
        duration: const Duration(milliseconds: 800),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.white.withOpacity(0.05)),
            const SizedBox(height: 20),
            const Text(
              "Clientes de la tienda: Aún no tienes registros", 
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
