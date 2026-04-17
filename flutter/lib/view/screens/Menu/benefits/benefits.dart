import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../controller/award_levels_controller.dart';
import '../../../../model/award_levels_model.dart';
import '../../../../service/api_service.dart';
import '../../../../utils/preference.dart';

class BenefitsPage extends StatefulWidget {
  const BenefitsPage({super.key});

  @override
  State<BenefitsPage> createState() => _BenefitsPageState();
}

class _BenefitsPageState extends State<BenefitsPage> with SingleTickerProviderStateMixin {
  final AwardLevelsController ctrl = Get.find<AwardLevelsController>();

  // Colores Premium
  static const Color neonGreen = Color(0xFF00FF88);
  static const Color deepBlack = Color(0xFF000000);
  static const Color darkGray = Color(0xFF1A1A1A);

  // Estado del Carrusel
  late PageController _carouselController;
  late AnimationController _pulseController;
  int _selectedRankIndex = 0;
  bool _isInitialized = false;
  late Future<List<Map<String, dynamic>>> _additionalPrizesFuture;

  @override
  void initState() {
    super.initState();
    _carouselController = PageController(viewportFraction: 0.7);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    ctrl.fetch();
    _additionalPrizesFuture = _fetchAdditionalPrizes();
  }

  @override
  void dispose() {
    _carouselController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TAREA 4: ACTUALIZAR LOG
    print('📊 [UI BENEFICIOS] Cuarta misión renderizada: Volumen de equipo.');

    return Scaffold(
      body: Stack(
        children: [
          // 1. Fondo Radial Premium
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Color(0xFF0A1510), // Verde muy oscuro sutil
                    deepBlack,
                  ],
                ),
              ),
            ),
          ),
          
          // Brillos verdes sutiles (Partículas estáticas)
          ...List.generate(5, (index) => Positioned(
            top: index * 200.0,
            left: index * 100.0,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: neonGreen.withOpacity(0.05),
                    blurRadius: 100,
                    spreadRadius: 20,
                  )
                ],
              ),
            ),
          )),

          GetBuilder<AwardLevelsController>(
            builder: (c) {
              if (c.isLoading) {
                return const Center(child: CircularProgressIndicator(color: neonGreen));
              }
              final res = c.response;
              if (res == null || res.data.isEmpty) {
                return const Center(
                  child: Text('Sin datos de niveles', style: TextStyle(color: neonGreen)),
                );
              }

              final levels = res.data;
              AwardLevel realCurrentLevel;
              
              try {
                realCurrentLevel = levels.firstWhere((l) => l.status == "Current Level");
                if (!_isInitialized) {
                  _selectedRankIndex = levels.indexOf(realCurrentLevel);
                  if (_selectedRankIndex < 0) _selectedRankIndex = 0;
                  _carouselController = PageController(
                    viewportFraction: 0.7,
                    initialPage: _selectedRankIndex,
                  );
                  _isInitialized = true;
                }
              } catch (_) {
                realCurrentLevel = levels.first;
                if (!_isInitialized) {
                  _selectedRankIndex = 0;
                  _carouselController = PageController(
                    viewportFraction: 0.7,
                    initialPage: _selectedRankIndex,
                  );
                  _isInitialized = true;
                }
              }

              final stats = res.userStats;
              final selectedRank = levels[_selectedRankIndex];

              return SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // REQUERIMIENTO V19.1: Header Persistente con Glassmorphism
                    SliverAppBar(
                      pinned: true,
                      floating: false,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      automaticallyImplyLeading: false,
                      expandedHeight: 70,
                      flexibleSpace: ClipRRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            color: Colors.black.withOpacity(0.8),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back_ios, color: neonGreen),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    const Text(
                                      'BENEFICIOS EX',
                                      style: TextStyle(
                                        color: neonGreen,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 2,
                                        fontSize: 18,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    const SizedBox(width: 48), // Balance para centrar título
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 2. Cabecera de Nivel (ESTÁTICA con el rango real)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: _buildLevelHeader(realCurrentLevel, selectedRank, stats),
                      ),
                    ),

                    // 5. Carrusel de Rangos (MOVIDO ARRIBA para que sea el selector)
                    SliverToBoxAdapter(
                      child: _buildRanksCarousel(levels),
                    ),

                    // 3. Sección de Misiones (DINÁMICA con AnimatedSwitcher)
                    SliverToBoxAdapter(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 0.1),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey('missions_$_selectedRankIndex'),
                          child: _buildMissionsSection(selectedRank, stats),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 30)),

                    // 4. Premios (DINÁMICO con AnimatedSwitcher)
                    SliverToBoxAdapter(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: KeyedSubtree(
                          key: ValueKey('prize_$_selectedRankIndex'),
                          child: _buildPrizesSection(selectedRank, stats, int.tryParse(realCurrentLevel.id.toString()) ?? 0),
                        ),
                      ),
                    ),
                    
                    const SliverToBoxAdapter(child: SizedBox(height: 30)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLevelHeader(AwardLevel current, AwardLevel selected, UserStats? stats) {
    // REQUERIMIENTO v1.8.0: Usar totalPersonalSales para el progreso del rango
    double salesProgress = ((stats?.totalPersonalSales ?? 0) / selected.minimumEarning).clamp(0.0, 1.0);
    double patrociniosProgress = ((stats?.userPatrocinios ?? 0) / selected.minimumPatrocinios).clamp(0.0, 1.0);
    double sociosProgress = ((stats?.userSocios ?? 0) / selected.minimumSocios).clamp(0.0, 1.0);
    double totalProgress = (salesProgress + patrociniosProgress + sociosProgress) / 3;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkGray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: neonGreen.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(color: neonGreen.withOpacity(0.1), blurRadius: 15, spreadRadius: 1)
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Estatus real: ${current.levelNumber.toUpperCase()}",
                  style: const TextStyle(
                    color: neonGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 15),
                Stack(
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: totalProgress,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: neonGreen,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(color: neonGreen.withOpacity(0.5), blurRadius: 10, spreadRadius: 1)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFE5E5E5), Color(0xFFB0B0B0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(color: neonGreen.withOpacity(0.2), blurRadius: 10)
              ],
            ),
            child: Text(
              current.levelNumber.isNotEmpty ? current.levelNumber.substring(0, 1).toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionsSection(AwardLevel selected, UserStats? stats) {
    // REQUERIMIENTO v1.8.0: Lógica de misiones basada en total_personal_sales (acumulado histórico)
    double personalSales = stats?.totalPersonalSales ?? 0.0;
    double patrocinios = (stats?.userPatrocinios ?? 0).toDouble();
    double socios = (stats?.userSocios ?? 0).toDouble();
    double volumenEquipo = stats?.userEarningTeam ?? 0.0;

    bool okPersonal = personalSales >= selected.minimumEarning;
    bool okDirects = patrocinios >= selected.minimumPatrocinios;
    bool okPartners = socios >= selected.minimumSocios;
    bool okTeamVolume = volumenEquipo >= selected.minimumEarningTeam;

    // Cálculo de progreso real basado en metas completadas (0 a 1)
    int completedGoals = 0;
    if (okPersonal) completedGoals++;
    if (okDirects) completedGoals++;
    if (okPartners) completedGoals++;
    if (okTeamVolume) completedGoals++;
    double totalProgress = completedGoals / 4.0;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkGray,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: neonGreen.withOpacity(0.2)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.1,
              child: Icon(Icons.payments, size: 150, color: neonGreen),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Misiones para subir a ${selected.levelNumber.toUpperCase()}",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 20),
              _missionItem("Ventas personales: \$${personalSales.toStringAsFixed(0)} / \$${selected.minimumEarning.toStringAsFixed(0)}", okPersonal),
              _missionItem("Patrocinios directos: ${patrocinios.toInt()} / ${selected.minimumPatrocinios}", okDirects),
              _missionItem("Socios en red: ${socios.toInt()} / ${selected.minimumSocios}", okPartners),
              _missionItem("Volumen de equipo: \$${volumenEquipo.toStringAsFixed(0)} / \$${selected.minimumEarningTeam.toStringAsFixed(0)}", okTeamVolume),
              const SizedBox(height: 25),
              const Text("PROGRESO HACIA ESTE RANGO", style: TextStyle(color: neonGreen, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                height: 15,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(7.5),
                  border: Border.all(color: neonGreen.withOpacity(0.3)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7.5),
                  child: LinearProgressIndicator(
                    value: totalProgress,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(neonGreen),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _missionItem(String title, bool completed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: neonGreen, width: 2),
            ),
            child: Icon(
              completed ? Icons.check : null,
              size: 14,
              color: neonGreen,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrizesSection(AwardLevel selected, UserStats? stats, int currentLevelId) {
    // REQUERIMIENTO v1.8.0: Lógica de premios sincronizada con totalPersonalSales
    double personalSales = stats?.totalPersonalSales ?? 0.0;
    double patrocinios = (stats?.userPatrocinios ?? 0).toDouble();
    double socios = (stats?.userSocios ?? 0).toDouble();

    bool okPersonal = personalSales >= selected.minimumEarning;
    bool okDirects = patrocinios >= selected.minimumPatrocinios;
    bool okPartners = socios >= selected.minimumSocios;

    bool isUnlocked = selected.status == "Reached" || (okPersonal && okDirects && okPartners);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "PREMIO DESBLOQUEABLE",
            style: TextStyle(color: neonGreen, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isUnlocked ? neonGreen.withOpacity(0.1) : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: isUnlocked ? neonGreen.withOpacity(0.5) : Colors.white10),
            ),
            child: Row(
              children: [
                Icon(Icons.card_giftcard, color: isUnlocked ? neonGreen : Colors.white24, size: 40),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Recompensa de Rango",
                        style: TextStyle(
                          color: isUnlocked ? Colors.white : Colors.white38,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        selected.physicalPrize,
                        style: TextStyle(
                          color: isUnlocked ? Colors.white.withOpacity(0.6) : Colors.white12,
                          fontSize: 13,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isUnlocked)
                  const Icon(Icons.lock_outline, color: Colors.white24, size: 24)
                else
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: neonGreen, size: 28),
                    onPressed: () {
                      _openAdditionalPrizeModal(context, {
                        'title': "Premio de Rango: ${selected.levelNumber}",
                        'description': "Has desbloqueado este premio por alcanzar el nivel. ¿Deseas canjearlo ahora?",
                        'id': selected.id,
                      });
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "PREMIOS CANJEABLES ADICIONALES",
            style: TextStyle(
              color: neonGreen,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.5,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 14),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _additionalPrizesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Center(child: CircularProgressIndicator(color: neonGreen)),
                );
              }

              final prizes = snapshot.data ?? <Map<String, dynamic>>[];
              if (prizes.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Center(
                    child: Text(
                      "Próximamente más premios canjeables para el rango ${selected.levelNumber.toUpperCase()}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5), // Gris Plata sutil
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: prizes.length,
                itemBuilder: (context, index) {
                  final prize = prizes[index];
                  
                  // REQUERIMIENTO V1.2.1: El botón CANJEAR solo está habilitado si el rango explorado ha sido alcanzado.
                  // Usamos el status del AwardLevel seleccionado en el carrusel.
                  final bool isRankReached = selected.status == "Reached" || selected.status == "Current Level";
                  
                  // REQUERIMIENTO V20.0: Bloqueo físico real vinculado al status del Nivel Plata (ID 4)
                  final bool isPlataLocked = ctrl.response?.data.isNotEmpty == true && 
                                           ctrl.response!.data.any((l) => l.id.toString() == "4" && l.status == "Locked");
                  
                  // REQUERIMIENTO V19.9: Sincronización estricta con el campo 'status' de la API
                  final bool isLockedByApi = prize['status'] == "Locked" || isPlataLocked;
                  
                  // El premio está bloqueado si el rango no ha sido alcanzado O si la API dice que está bloqueado.
                  final bool isBlocked = !isRankReached || isLockedByApi;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PremiumPrizeCard(
                      prize: prize,
                      isRedeemed: isBlocked, // Usamos el estado para el estilo gris mate y candado
                      onTap: isBlocked ? null : () => _openAdditionalPrizeModal(context, prize),
                      onCopyLink: () {}, 
                      onShare: () {}, 
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchAdditionalPrizes({String? filterLevelId}) async {
    final userModel = await SharedPreference.getUserData();
    final token = userModel?.data?.token;
    String? userId = userModel?.data?.userId?.toString();
    if (token == null || token.trim().isEmpty) {
      return <Map<String, dynamic>>[];
    }

    if (userId == null || userId.trim().isEmpty || userId == 'null' || userId == '0') {
      final profile = await ApiService.instance.getData('User/get_my_profile_details', token: token);
      final data = profile?['data'];
      if (data is Map<String, dynamic>) {
        userId = (data['id'] ??
                data['user_id'] ??
                data['id_usuario'] ??
                data['userId'] ??
                (data['user'] is Map ? data['user']['id'] : null) ??
                (data['user'] is Map ? data['user']['user_id'] : null))
            ?.toString();
      }
    }

    if (userId == null || userId.trim().isEmpty || userId == 'null' || userId == '0') {
      return <Map<String, dynamic>>[];
    }

    final allPrizes = await ApiService.instance.getMyRedeemablePrizes(userId, token: token);
    
    // REQUERIMIENTO V1.2.1: Filtrado dinámico por ID de rango
    if (filterLevelId != null && filterLevelId.isNotEmpty) {
      return allPrizes.where((p) {
        final pLevelId = (p['level_id'] ?? p['award_level_id'] ?? p['rank_id'] ?? p['id_nivel'])?.toString();
        return pLevelId == filterLevelId;
      }).toList();
    }
    
    return allPrizes;
  }

  void _copyPrizeLink(BuildContext context, Map<String, dynamic> prize) {
    final link = (prize['link'] ?? prize['url'] ?? prize['affiliate_link'] ?? '').toString().trim();
    if (link.isEmpty) return;
    Clipboard.setData(ClipboardData(text: link));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Enlace copiado al portapapeles",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
        backgroundColor: neonGreen,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _sharePrize(Map<String, dynamic> prize) async {
    final link = (prize['link'] ?? prize['url'] ?? prize['affiliate_link'] ?? '').toString().trim();
    if (link.isEmpty) return;
    await Share.share(link);
  }

  Future<void> _openAdditionalPrizeModal(BuildContext context, Map<String, dynamic> prize) async {
    // REQUERIMIENTO V19.0: Confirmación Neón y Mensaje de Administrador
    final String title = (prize['title'] ?? prize['name'] ?? prize['prize_title'] ?? 'Premio').toString();
    final String description = (prize['description'] ??
            prize['short_description'] ??
            "¿Deseas canjear este premio?")
        .toString();

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151520),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: neonGreen.withOpacity(0.3)),
        ),
        title: Text(
          "CONFIRMAR CANJE",
          style: TextStyle(color: neonGreen, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.5, fontFamily: 'Poppins'),
        ),
        content: Text(
          "¿Estás seguro de que deseas canjear $title?",
          style: const TextStyle(color: Colors.white70, fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: neonGreen,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("CONFIRMAR", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Disparar la petición de la API
      try {
        final userModel = await SharedPreference.getUserData();
        final token = userModel?.data?.token;
        final userId = userModel?.data?.userId?.toString();
        final prizeId = (prize['id'] ?? prize['prize_id'] ?? prize['product_id'] ?? '').toString();
        
        if (userId != null && userId.isNotEmpty && prizeId.isNotEmpty) {
          await ApiService.instance.redeemPrize(
            userId: userId,
            prizeId: prizeId,
            token: token,
          );
        }
      } catch (_) {}

      // Mostrar Mensaje de Administrador (V19.0)
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF0A1510),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: BorderSide(color: neonGreen, width: 2),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, color: neonGreen, size: 60),
                const SizedBox(height: 20),
                const Text(
                  "¡SOLICITUD ENVIADA!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: neonGreen, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.5, fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Un administrador se comunicará contigo en breve.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: neonGreen,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("ENTENDIDO", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  Widget _buildRanksCarousel(List<AwardLevel> levels) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20, top: 10, bottom: 15),
          child: Text(
            "EXPLORAR RANGOS",
            style: TextStyle(color: neonGreen, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ),
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _carouselController,
            onPageChanged: (index) {
              setState(() {
                _selectedRankIndex = index;
                // REQUERIMIENTO V1.2.1: Actualizar la lista de premios adicionales al cambiar de rango
                final levelId = levels[index].id;
                _additionalPrizesFuture = _fetchAdditionalPrizes(filterLevelId: levelId.toString());
              });
            },
            itemCount: levels.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _carouselController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_carouselController.position.haveDimensions) {
                    value = (_carouselController.page ?? 0) - index;
                    value = (1 - (value.abs() * 0.2)).clamp(0.0, 1.0);
                  } else {
                    value = index == _selectedRankIndex ? 1.0 : 0.8;
                  }

                  final bool isActive = index == _selectedRankIndex;

                  return Center(
                    child: Transform.scale(
                      scale: Curves.easeOut.transform(value),
                      child: Opacity(
                        opacity: value.clamp(0.2, 1.0),
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(
                            sigmaX: isActive ? 0.0 : 2.0,
                            sigmaY: isActive ? 0.0 : 2.0,
                          ),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(isActive ? 0 : (1 - value)),
                              BlendMode.darken,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: isActive ? [
                                  BoxShadow(
                                    color: neonGreen.withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  )
                                ] : null,
                              ),
                              child: child,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: _rankCard(levels[index], index == _selectedRankIndex),
              );
            },
          ),
        ),
        const SizedBox(height: 15),
        // REQUERIMIENTO V1.2.1: Indicadores de navegación (dots) dinámicos
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(levels.length, (index) {
              bool isActive = index == _selectedRankIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: isActive ? 24 : 8,
                decoration: BoxDecoration(
                  color: isActive ? neonGreen : neonGreen.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: isActive ? [
                    BoxShadow(
                      color: neonGreen.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ] : null,
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _rankCard(AwardLevel level, bool isActive) {
    bool isLocked = level.status == "Locked";
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: darkGray,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: neonGreen.withOpacity(isActive ? 0.8 : (level.status == "Reached" ? 0.4 : 0.1)),
          width: isActive ? 2 : 1,
        ),
        image: level.imageUrl != null 
          ? DecorationImage(
              image: CachedNetworkImageProvider(level.imageUrl!),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
            )
          : null,
      ),
      child: Stack(
        children: [
          if (isLocked)
            const Positioned(
              top: 10,
              right: 10,
              child: Icon(Icons.lock_outline, color: neonGreen, size: 20),
            ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level.levelNumber.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 18,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: neonGreen.withOpacity(isActive ? (0.2 + 0.4 * _pulseController.value) : 0.2),
                        ),
                        boxShadow: isActive ? [
                          BoxShadow(
                            color: neonGreen.withOpacity(0.1 * _pulseController.value),
                            blurRadius: 4,
                            spreadRadius: 1,
                          )
                        ] : null,
                      ),
                      child: Text(
                        level.status == "Reached" ? "ALCANZADO" : "EXPLORAR",
                        style: TextStyle(
                          color: neonGreen.withOpacity(isActive ? (0.6 + 0.4 * _pulseController.value) : 0.8), 
                          fontSize: 10, 
                          fontWeight: FontWeight.bold,
                          shadows: isActive ? [
                            Shadow(color: neonGreen.withOpacity(0.5 * _pulseController.value), blurRadius: 4)
                          ] : null,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumPrizeCard extends StatelessWidget {
  static const Color neonGreen = Color(0xFF00FF88);

  final Map<String, dynamic> prize;
  final VoidCallback? onTap;
  final VoidCallback onCopyLink;
  final VoidCallback onShare;
  final bool isRedeemed;

  const PremiumPrizeCard({
    super.key,
    required this.prize,
    this.onTap,
    required this.onCopyLink,
    required this.onShare,
    this.isRedeemed = false,
  });

  @override
  Widget build(BuildContext context) {
    final String title = (prize['title'] ?? prize['name'] ?? prize['prize_title'] ?? 'Premio').toString();
    final String description = (prize['description'] ?? prize['short_description'] ?? '').toString();
    final String imageUrl = (prize['image_url'] ?? prize['image'] ?? prize['icon'] ?? '').toString();

    final rawRating = prize['rating'];
    final double rating = rawRating is num
        ? rawRating.toDouble()
        : double.tryParse(rawRating?.toString() ?? '') ?? 0.0;
    final int starCount = rating > 0 ? rating.round().clamp(0, 5) : ((title.hashCode.abs() % 3) + 3);

    final String priceLabel = (prize['precio_label'] ?? prize['price_label'] ?? 'Precio').toString();
    final String priceValue = (prize['precio_value'] ??
            prize['price_value'] ??
            prize['price'] ??
            "\$${((title.hashCode.abs() % 70) + 9)}.99")
        .toString();
    final String gainLabel = (prize['ganancia_label'] ?? prize['earning_label'] ?? 'Ganancia').toString();
    final String gainValue = (prize['ganancia_value'] ??
            prize['earning_value'] ??
            prize['earning'] ??
            "${((title.hashCode.abs() % 20) + 10)}%")
        .toString();

    final dynamic rawRedeemed = prize['is_redeemed'];
    final bool isPrizeRedeemedByApi = rawRedeemed == true ||
        rawRedeemed == 1 ||
        rawRedeemed == "1" ||
        rawRedeemed.toString().toLowerCase() == "true";

    // REQUERIMIENTO V19.4: Estilo de Bloqueo Absoluto (Gris Mate)
    final Color lockedBgColor = const Color(0xFF2A2A2A);
    final Color lockedTextColor = Colors.white.withOpacity(0.3);

    // REQUERIMIENTO V19.7: El botón DEBE ser físicamente nulo si está bloqueado (Nivel 0)
    final VoidCallback? physicalOnTap = isRedeemed ? null : onTap;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: physicalOnTap, // Bloqueo físico absoluto del InkWell
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: isRedeemed ? Colors.white10 : neonGreen.withOpacity(0.3)),
            boxShadow: isRedeemed ? [] : [
              BoxShadow(
                color: neonGreen.withOpacity(0.05),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isRedeemed ? Colors.white.withOpacity(0.05) : neonGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isRedeemed ? Colors.white10 : neonGreen.withOpacity(0.2)),
                    ),
                    alignment: Alignment.center,
                    child: imageUrl.trim().isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              color: isRedeemed ? Colors.black.withOpacity(0.5) : null,
                              colorBlendMode: isRedeemed ? BlendMode.darken : null,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.workspace_premium, color: isRedeemed ? lockedTextColor : neonGreen, size: 28);
                              },
                            ),
                          )
                        : Icon(Icons.workspace_premium, color: isRedeemed ? lockedTextColor : neonGreen, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.toUpperCase(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isRedeemed ? lockedTextColor : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        if (description.trim().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(isRedeemed ? 0.1 : 0.5),
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              height: 1.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: physicalOnTap, // REQUERIMIENTO V19.7: Bloqueo físico absoluto (onPressed: null)
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRedeemed ? const Color(0xFF1A1A1A) : neonGreen, // Gris más oscuro si está bloqueado
                    disabledBackgroundColor: const Color(0xFF1A1A1A),
                    foregroundColor: isRedeemed ? Colors.white.withOpacity(0.2) : Colors.black,
                    disabledForegroundColor: Colors.white.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: isRedeemed ? Colors.white.withOpacity(0.05) : Colors.transparent),
                    ),
                    elevation: isRedeemed ? 0 : 8,
                    shadowColor: neonGreen.withOpacity(0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isRedeemed) ...[
                        Icon(Icons.lock_outline, size: 16, color: Colors.white.withOpacity(0.2)),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        isPrizeRedeemedByApi ? "CANJEADO" : "CANJEAR",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  static const Color neonGreen = Color(0xFF00FF88);

  final String label;
  final String value;

  const _MetricColumn({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: neonGreen,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  static const Color neonGreen = Color(0xFF00FF88);

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: neonGreen.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: neonGreen.withOpacity(0.28)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: neonGreen),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: neonGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
