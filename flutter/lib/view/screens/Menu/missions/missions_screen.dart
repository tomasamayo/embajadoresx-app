import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:affiliatepro_mobile/service/api_service.dart';
import 'package:affiliatepro_mobile/service/event_service.dart';
import 'package:affiliatepro_mobile/controller/dashboard_controller.dart';
import 'package:affiliatepro_mobile/utils/preference.dart';
import 'package:affiliatepro_mobile/view/screens/dashboard/components/menu.dart';
import 'package:affiliatepro_mobile/view/screens/Menu/benefits/benefits.dart' show PremiumPrizeCard;

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  late Future<List<Map<String, dynamic>>> _additionalPrizesFuture;

  Widget _buildGradientTitle(String text) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          colors: [
            Color(0xFF00FF88),
            Color(0xFFE6FFF6),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
      },
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
          shadows: [
            Shadow(
              color: Color(0x6600FF88),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _additionalPrizesFuture = _fetchAdditionalPrizes();
    _refreshEvent();
  }

  Future<void> _refreshEvent() async {
    setState(() {
      _isLoading = true;
      _additionalPrizesFuture = _fetchAdditionalPrizes();
    });
    await Future.wait([
      EventService.instance.fetchActiveEvent(),
      _additionalPrizesFuture,
    ]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAdditionalPrizes() async {
    try {
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

      return ApiService.instance.getMyRedeemablePrizes(userId, token: token);
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> _copyPrizeLink(BuildContext context, Map<String, dynamic> prize) async {
    final link = (prize['link'] ?? prize['url'] ?? prize['affiliate_link'] ?? '').toString().trim();
    if (link.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: link));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enlace copiado')),
    );
  }

  Future<void> _sharePrize(Map<String, dynamic> prize) async {
    final link = (prize['link'] ?? prize['url'] ?? prize['affiliate_link'] ?? '').toString().trim();
    if (link.isEmpty) return;
    await Share.share(link);
  }

  Future<void> _openAdditionalPrizeModal(BuildContext context, Map<String, dynamic> prize) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final String title = (prize['title'] ?? prize['name'] ?? prize['prize_title'] ?? 'Premio').toString();
            final String description = (prize['description'] ?? prize['short_description'] ?? '').toString();

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF151520),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.25)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.45),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      if (description.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  setModalState(() => isSubmitting = true);
                                  try {
                                    final userModel = await SharedPreference.getUserData();
                                    final token = userModel?.data?.token;
                                    final userId = userModel?.data?.userId?.toString();
                                    final prizeId =
                                        (prize['id'] ?? prize['prize_id'] ?? prize['product_id'] ?? '').toString();

                                    if (token != null &&
                                        token.trim().isNotEmpty &&
                                        userId != null &&
                                        userId.trim().isNotEmpty &&
                                        userId != 'null' &&
                                        userId != '0' &&
                                        prizeId.trim().isNotEmpty) {
                                      await ApiService.instance.redeemPrize(
                                        userId: userId,
                                        prizeId: prizeId,
                                        token: token,
                                      );
                                    } else {
                                      await Future.delayed(const Duration(milliseconds: 600));
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _additionalPrizesFuture = _fetchAdditionalPrizes();
                                      });
                                    }
                                    if (context.mounted) Navigator.of(context).pop();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00FF88),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: Text(
                            isSubmitting ? "CANJEANDO..." : "CANJEAR AHORA",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              fontFamily: 'Poppins',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override 
  Widget build(BuildContext context) { 
    final eventService = EventService.instance;
    
    // REQUERIMIENTO V1.2.9: Inyección Segura (Falla de GetX fix)
    late final DashboardController dashboardCtrl;
    if (Get.isRegistered<DashboardController>()) {
      dashboardCtrl = Get.find<DashboardController>();
    } else {
      // Intento de rescate si por alguna razón el controlador se perdió
      debugPrint("⚠️ [MISSIONS] DashboardController no encontrado, intentando rescate...");
      dashboardCtrl = Get.put(DashboardController(preferences: Get.find<SharedPreferences>()), permanent: true);
    }

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true, // REQUERIMIENTO V1.2.3: Fusión total del fondo
      appBar: AppBar(
        backgroundColor: Colors.transparent, // REQUERIMIENTO V1.2.3: AppBar invisible
        elevation: 0,
        scrolledUnderElevation: 0, // REQUERIMIENTO V1.2.3: Evitar cambio de color al scroll
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "Eventos Especiales",
          style: TextStyle(
            color: Color(0xFF00FF88), // REQUERIMIENTO V1.2.3: Título Verde Neón
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      drawer: const Drawer(
        child: MenuPage(), // Abre desde la IZQUIERDA
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.5, -0.5),
            radius: 1.5,
            colors: [Color(0xFF0A2015), Color(0xFF0B0B0F)],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshEvent,
            color: const Color(0xFF00FF88),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BLOQUE 1: Rango y Diamante
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF00FF88).withOpacity(0.08),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: GetBuilder<DashboardController>(
                      builder: (dashController) {
                        return Center(
                          child: Column(
                            children: [
                              const GemaPulsante(),
                              const SizedBox(height: 12),
                              // REQUERIMIENTO V1.2.3: Rango dinámico desde DashboardController
                              Obx(() {
                                // Al usar .value de una variable Rx, el Obx ya tiene qué vigilar y no explota
                                String rankName = dashboardCtrl.currentRank.value;
                                return Text(
                                  rankName,
                                  style: const TextStyle(
                                    color: Color(0xFFFBBC05), // Color dorado/amarillo original
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                );
                              }),
                              const SizedBox(height: 24),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: const SizedBox(
                                  height: 10,
                                  width: double.infinity,
                                  child: LinearProgressIndicator(
                                    value: 0.0,
                                    backgroundColor: Color(0xFF1A1A1F),
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FF88)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "0% de progreso al siguiente nivel",
                                style: TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Poppins'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // BLOQUE 2: EVENTOS FLASH (Actualizado V2.7 - Asincronía Fix)
                  const SizedBox(height: 28),
                  Center(child: _buildGradientTitle("CENTRO DE DESAFÍOS")),
                  const SizedBox(height: 10),
                  const Text("Eventos Flash", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                  const Text("Participa y gana recompensas exclusivas", style: TextStyle(color: Colors.white60, fontSize: 14, fontFamily: 'Poppins')),
                  
                  const SizedBox(height: 24),
                  
                  // BLOQUE DE PRIORIDAD ABSOLUTA: Evento Flash (Reactivo con Obx)
                  Obx(() {
                    final event = eventService.currentEvent.value;
                    
                    // REQUERIMIENTO V4.3: Filtro estricto de visibilidad (Cronómetro + Fecha)
                    if (event != null && !event.isExpired) {
                      return EventFlashCard(event: event);
                    }
                    
                    if (!_isLoading) {
                      // REQUERIMIENTO V4.3: UI Limpia cuando no hay eventos
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bolt_outlined, 
                                color: const Color(0xFF00FF88).withOpacity(0.2), 
                                size: 80
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "¡Estén atentos!",
                                style: TextStyle(
                                  color: Colors.white, 
                                  fontSize: 20, 
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins'
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Pronto nuevos Eventos Flash",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white60, 
                                  fontSize: 14,
                                  fontFamily: 'Poppins'
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  const SizedBox(height: 48),

                  if (_isLoading)
                    const Center(child: Padding(padding: EdgeInsets.only(top: 20), child: CircularProgressIndicator(color: Color(0xFF00FF88)))),

                  const SizedBox(height: 18),
                  // REQUERIMIENTO V19.0: Se eliminó la sección de PREMIOS CANJEABLES ADICIONALES de Eventos.
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}

class EventFlashCard extends StatefulWidget {
  final EventModel event;
  const EventFlashCard({Key? key, required this.event}) : super(key: key); 
  @override 
  State<EventFlashCard> createState() => _EventFlashCardState(); 
} 
 
class _EventFlashCardState extends State<EventFlashCard> with SingleTickerProviderStateMixin { 
  late AnimationController _controller; 
  late Animation<double> _scaleAnimation; 
  Duration _tiempoRestante = Duration.zero; 
  Timer? _timer; 
  bool _aceptado = false; 
 
  @override 
  void initState() { 
    super.initState(); 
    
    _updateTimer();
    
    _cargarEstadoMision();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200)); 
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut); 
    _controller.forward(); 
  } 

  @override
  void didUpdateWidget(covariant EventFlashCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.event.remainingTime != "00:00:00" && 
        (oldWidget.event.remainingTime != widget.event.remainingTime || oldWidget.event.id != widget.event.id)) {
      if (kDebugMode) {
        print("LOG: Resync event remainingTime=${widget.event.remainingTime}");
      }
      _updateTimer();
    }
  }

  void _updateTimer() {
    _timer?.cancel();
    _timer = null;

    try {
      final String remainingTimeString = widget.event.remainingTime;
      
      if (remainingTimeString == "00:00:00") {
        if (kDebugMode) {
          print("LOG: Guard active (remainingTime is 00:00:00). Waiting for real data.");
        }
        _tiempoRestante = Duration.zero;
        return;
      }

      if (kDebugMode) {
        print("LOG: Starting countdown with $remainingTimeString");
      }
      
      List<String> partes = remainingTimeString.split(':'); 
      if (partes.length == 3) {
        int horas = int.parse(partes[0]); 
        int minutos = int.parse(partes[1]); 
        int segundos = int.parse(partes[2]); 
        
        _tiempoRestante = Duration(hours: horas, minutes: minutos, seconds: segundos); 
        
        if (_tiempoRestante.inSeconds > 0) {
          _startTimerDeRescate();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("LOG: Countdown parse error: $e");
      }
      _tiempoRestante = Duration.zero;
    }
  }

  void _startTimerDeRescate() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) { 
      if (_tiempoRestante.inSeconds > 0) { 
        if (mounted) {
          setState(() {
            _tiempoRestante = _tiempoRestante - const Duration(seconds: 1);
          });
          if (kDebugMode && _tiempoRestante.inSeconds % 10 == 0) {
            print("LOG: Countdown tick $_tiempoRestante");
          }
        }
      } else { 
        if (kDebugMode) {
          print("LOG: Event finished");
        }
        _timer?.cancel(); 
        // REQUERIMIENTO V4.3: Forzar rebuild para ocultar la tarjeta al expirar en vivo
        if (mounted) setState(() {});
      } 
    });
  }

  Future<void> _cargarEstadoMision() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('accepted_event_${widget.event.id}') == true && mounted) {
      setState(() => _aceptado = true);
    }
  }

  Future<void> _aceptarReto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('accepted_event_${widget.event.id}', true);
    if (mounted) setState(() => _aceptado = true);
  }

  @override 
  void dispose() { 
    _timer?.cancel(); 
    _controller.dispose(); 
    super.dispose(); 
  } 
 
  String _formatearTiempo(Duration d) { 
    if (d.inSeconds <= 0) return "00:00:00";
    String twoDigits(int n) => n.toString().padLeft(2, '0'); 
    final String hours = twoDigits(d.inHours);
    final String minutes = twoDigits(d.inMinutes.remainder(60));
    final String seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds"; 
  } 
 
  @override 
  Widget build(BuildContext context) { 
    // REQUERIMIENTO V4.3: Ocultar inmediatamente si el cronómetro llega a cero en tiempo real
    if (_tiempoRestante.inSeconds <= 0) {
      return const SizedBox.shrink();
    }

    // Log de Control solicitado
    print("📏 [EVENT UI] Cambio a diseño horizontal ultra-compacto completado.");

    return ScaleTransition( 
      scale: _scaleAnimation, 
      child: Container( 
        height: 145, // TAREA: Altura ultra-compacta (140-150px)
        margin: const EdgeInsets.only(bottom: 24), 
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), 
          color: const Color(0xFF151520), // Fondo oscuro sólido para el formato horizontal
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3), 
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ]
        ), 
        child: Row(
          children: [
            // 1. LADO IZQUIERDO: IMAGEN (Ancho fijo, alto total)
            SizedBox(
              width: 115,
              height: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                child: (widget.event.eventImageUrl != null && widget.event.eventImageUrl!.isNotEmpty)
                  ? Image.network(
                      widget.event.eventImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildFallbackBackgroundCompact(),
                    )
                  : _buildFallbackBackgroundCompact(),
              ),
            ),
            
            // 2. LADO DERECHO: INFORMACIÓN (Expanded)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Fila superior: Badge y Timer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), 
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF3D00).withOpacity(0.1), 
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFF3D00).withOpacity(0.3)),
                          ), 
                          child: const Text(
                            "EVENTO FLASH", 
                            style: TextStyle(color: Color(0xFFFF3D00), fontWeight: FontWeight.bold, fontSize: 8)
                          )
                        ), 
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, color: Colors.amber, size: 14), 
                            const SizedBox(width: 4), 
                            Text(
                              _formatearTiempo(_tiempoRestante), 
                              style: const TextStyle(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold, 
                                fontSize: 13,
                                fontFamily: 'monospace',
                              )
                            )
                          ]
                        )
                      ],
                    ),
                    
                    // Título (Fuente 14-15)
                    Text(
                      widget.event.title.toUpperCase(), 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Descripción Corta (Max 2 líneas)
                    Text(
                      widget.event.description, 
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11, height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Progreso y Cupos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${widget.event.progressPercentage.toInt()}% COMPLETADO", 
                          style: const TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.bold, fontSize: 10)
                        ),
                        Text(
                          "CUPOS: ${widget.event.winnersLimit - widget.event.winnersCount}",
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ],
                    ),
                    
                    // Botón Inferior: altura 35
                    SizedBox(
                      height: 35,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _aceptado ? Colors.white.withOpacity(0.05) : const Color(0xFFFF3D00), 
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                        ), 
                        onPressed: _aceptado ? null : _aceptarReto, 
                        child: Text(
                          _aceptado ? "EN CURSO..." : "ACEPTAR RETO", 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)
                        )
                      ),
                    ),
                  ], 
                ),
              ),
            ),
          ], 
        ), 
      ), 
    ); 
  }

  Widget _buildFallbackBackgroundCompact() => Container(
    width: double.infinity,
    height: double.infinity,
    color: const Color(0xFF1A1A1F),
    child: Center(
      child: Icon(
        Icons.bolt_rounded, 
        color: const Color(0xFFFF3D00).withOpacity(0.3), 
        size: 30
      ),
    ),
  );
}


  Widget _buildDefaultGradient() => Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF3A0000), Color(0xFF150000)], begin: Alignment.topLeft, end: Alignment.bottomRight)));

class GemaPulsante extends StatefulWidget { 
  const GemaPulsante({super.key}); 
  @override 
  State<GemaPulsante> createState() => _GemaPulsanteState(); 
} 

class _GemaPulsanteState extends State<GemaPulsante> with SingleTickerProviderStateMixin { 
  late AnimationController _controller; 
  @override 
  void initState() { super.initState(); _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true); } 
  @override 
  void dispose() { _controller.dispose(); super.dispose(); } 
  @override 
  Widget build(BuildContext context) { 
    return AnimatedBuilder(animation: _controller, builder: (context, child) => Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFF00FF88).withOpacity(0.1 + (_controller.value * 0.3)), blurRadius: 20 + (_controller.value * 30), spreadRadius: 5 + (_controller.value * 15))], border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.5), width: 2)), child: const Icon(Icons.diamond_outlined, color: Color(0xFF00FF88), size: 60))); 
  } 
}
