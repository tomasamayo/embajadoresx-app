import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:affiliatepro_mobile/controller/dashboard_controller.dart';
import 'package:affiliatepro_mobile/model/dashboard_model.dart';
import 'package:affiliatepro_mobile/utils/colors.dart';
import 'package:affiliatepro_mobile/utils/preference.dart';
import 'package:affiliatepro_mobile/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _hasError = false;
  List<dynamic> _rankingData = [];
  Map<String, dynamic>? _currentUserRanking;
  int _currentUserPosition = 0;

  @override
  void initState() {
    super.initState();
    _fetchRanking();
  }

  Future<void> _fetchRanking() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    final userModel = await SharedPreference.getUserData();
    final token = userModel?.data?.token;
    
    // REQUERIMIENTO v2.2.0: RECUPERACIÓN ULTRA-ROBUSTA DEL ID (Múltiples fuentes)
    String? userIdStr = userModel?.data?.userId?.toString();
    
    if (userIdStr == null || userIdStr.isEmpty || userIdStr == "null") {
      print("🔍 [RANKING DEBUG] userId desde UserModel es nulo. Intentando fuentes alternativas...");
      
      // Fuente 1: DashboardController (Observable caliente)
      if (Get.isRegistered<DashboardController>()) {
        userIdStr = Get.find<DashboardController>().userId.value;
        if (userIdStr.isNotEmpty) print("✅ [RANKING DEBUG] ID recuperado de DashboardController: $userIdStr");
      }
      
      // Fuente 2: SharedPreferences directas (llaves crudas)
      if (userIdStr == null || userIdStr.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        userIdStr = prefs.getString('user_id') ?? prefs.getString('id');
        if (userIdStr != null) print("✅ [RANKING DEBUG] ID recuperado de SharedPreferences crudas: $userIdStr");
      }
    } else {
      print("✅ [RANKING DEBUG] ID encontrado en UserModel: $userIdStr");
    }
    
    final response = await ApiService.instance.getGlobalRanking(token: token, userId: userIdStr);
    
    if (response != null && response['status'] == true) {
      if (mounted) {
        setState(() {
          _rankingData = response['data'] ?? [];
          final String currentUserId = userIdStr ?? "";
          
          print("🏆 [RANKING SYNC] Datos recibidos. Usuarios en lista: ${_rankingData.length}");
          
          // Buscar al usuario logueado dinámicamente (v2.0.1)
          try {
            _currentUserPosition = _rankingData.indexWhere((u) => u['user_id'].toString() == currentUserId) + 1;
            
            if (_currentUserPosition > 0) {
              _currentUserRanking = _rankingData[_currentUserPosition - 1];
              print("👤 [RANKING MATCH] Usuario encontrado en posición #$_currentUserPosition");
            } else {
              _currentUserRanking = null;
              print("⚠️ [RANKING MATCH] Usuario ($currentUserId) no encontrado en el top actual.");
            }
          } catch (e) {
            _currentUserPosition = 0;
            print("❌ [RANKING ERROR] Error al calcular posición: $e");
          }
          
          _isLoading = false;
          _hasError = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  // 2. Estadísticas Globales (Header) - Variables preparadas para la API
  String totalUsuariosApi = "10,000";
  String totalVolumenApi = "1.2M";
  
  // 4. Tarjeta Flotante (Tu Progreso) - Variables reales
  String miPosicionApi = "#42";
  double miProgresoApi = 0.65; // 0.0 a 1.0

  // --- NUEVO WIDGET AVATAR PREDETERMINADO (INITIALS AVATAR - STYLE GOOGLE/APPLE) ---
  Widget _buildDefaultAvatar(double size, String userName) {
    // Extraer las iniciales del nombre (ej: "Victoria Leandra" -> "VL")
    String initials = "";
    List<String> nameParts = userName.trim().split(' ');
    if (nameParts.isNotEmpty) {
      if (nameParts.length >= 2) {
        initials = (nameParts[0][0] + nameParts[1][0]).toUpperCase();
      } else {
        initials = nameParts[0].substring(0, nameParts[0].length >= 2 ? 2 : 1).toUpperCase();
      }
    } else {
      initials = "EX";
    }

    // Paleta de fondos oscuros premium para diferenciar usuarios
    final List<Color> bgColors = [
      const Color(0xFF1A2A3A), // Dark Blue
      const Color(0xFF2A1A3A), // Dark Purple
      const Color(0xFF3A2A1A), // Dark Brown/Orange
      const Color(0xFF1A3A2A), // Dark Green
      const Color(0xFF2A2A2A), // Dark Grey
    ];

    // Asignar color fijo basado en el nombre
    final Color bgColor = bgColors[userName.hashCode.abs() % bgColors.length];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        // Borde neón para mantener el estilo de la app
        border: Border.all(
            color: const Color(0xFF00FF88).withOpacity(0.5), width: 1.5),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  // --- NUEVO ENVOLTORIO LÓGICO PARA AVATARES (USER AVATAR WRAPPER) ---
  Widget _buildUserAvatar(double size, String userName, String? photoUrl) {
    // Si la URL existe y no es la imagen por defecto "no-image.jpg"
    bool hasValidPhoto = photoUrl != null && 
                        photoUrl.toString().trim().isNotEmpty && 
                        photoUrl != "null" && 
                        !photoUrl.toString().contains("no-image.jpg");

    if (hasValidPhoto) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: const Color(0xFF00FF88).withOpacity(0.5), width: 1.5),
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: photoUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildDefaultAvatar(size, userName),
            errorWidget: (context, url, error) => _buildDefaultAvatar(size, userName),
          ),
        ),
      );
    }

    // Si no hay foto válida, mostramos las iniciales con fondo neón
    return _buildDefaultAvatar(size, userName);
  }

  String _formatName(String name) {
    if (name.isEmpty) return "Usuario EX";
    List<String> parts = name.trim().split(' ');
    if (parts.length <= 2) return name;
    return "${parts.take(2).join(' ')}...";
  }

  // 3. Niveles en el Podio (Top 3): Agregado el parámetro nivel
  Widget construirTarjetaPodio(String posicion, String nombre, String? avatarUrl, String ganancias, String nivel, Color colorMedalla, bool esPrimerLugar) { 
    return Expanded( 
      child: Container( 
        margin: const EdgeInsets.symmetric(horizontal: 4), 
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4), 
        decoration: BoxDecoration( 
          color: const Color(0xFF1A1A1A), // Fondo del recuadro oscuro 
          borderRadius: BorderRadius.circular(16), 
          border: Border.all( 
            color: esPrimerLugar ? const Color(0xFFFFD700) : Colors.white10, 
            width: esPrimerLugar ? 1.5 : 1 
          ), 
        ), 
        child: Column( 
          mainAxisSize: MainAxisSize.min, 
          children: [ 
            // AVATAR + MEDALLA SUPERPUESTA 
            Stack( 
             clipBehavior: Clip.none, 
            alignment: Alignment.center, 
             children: [ 
               // 1. Avatar principal usando el nuevo envoltorio lógico
               _buildUserAvatar(76, nombre, avatarUrl),
               // 2. NÚMERO GIGANTE SUPERPUESTO (La "Mordida") 
               Positioned( 
                 bottom: -15, // Lo empujamos hacia abajo 
                 right: -5,   // Lo empujamos a la derecha 
                 child: Text( 
                   posicion, 
                   style: TextStyle( 
                     fontSize: 55, // TAMAÑO GIGANTE 
                     fontWeight: FontWeight.w900, 
                     fontStyle: FontStyle.italic, 
                     color: colorMedalla, // Oro, Plata o Bronce 
                     // Sombreado múltiple para crear un efecto de "borde negro" y resalte sobre la foto 
                     shadows: const [ 
                       Shadow(offset: Offset(-1.5, -1.5), color: Colors.black), 
                       Shadow(offset: Offset(1.5, -1.5), color: Colors.black), 
                       Shadow(offset: Offset(1.5, 1.5), color: Colors.black), 
                       Shadow(offset: Offset(-1.5, 1.5), color: Colors.black), 
                       Shadow(offset: Offset(2.0, 4.0), blurRadius: 4.0, color: Colors.black54), 
                     ], 
                   ), 
                 ), 
               ), 
               // 3. Corona (Solo para el 1er lugar) 
               if (esPrimerLugar) 
                 const Positioned( 
                   top: -18, 
                   child: Text("👑", style: TextStyle(fontSize: 26)), 
                 ), 
             ], 
           ), 
            const SizedBox(height: 12), 
            // NOMBRE 
            Text( 
              nombre.split(' ').take(2).join(' ') + (nombre.split(' ').length > 2 ? '...' : ''), 
              textAlign: TextAlign.center, 
              maxLines: 1, 
              overflow: TextOverflow.ellipsis, 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), 
            ), 
            const SizedBox(height: 4), 
            // GANANCIAS 
            Text( 
              ganancias, 
              style: const TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.w900, fontSize: 13), 
            ),
            // 3. Niveles en el Podio: Agregado el texto de nivel
            const SizedBox(height: 2),
            Text(
              "Nivel: $nivel",
              style: const TextStyle(color: Colors.white54, fontSize: 11, fontFamily: 'Poppins'),
            ),
          ], 
        ), 
      ), 
    ); 
  } 

  @override
  Widget build(BuildContext context) {
    const Color neonGreen = Color(0xFF00FF88);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "RANKING GLOBAL",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            letterSpacing: 1.2,
          ),
        ),
      ),
      // 1. Fondo Premium (Gradient): Envuelto el body en un Container con gradiente
      body: Container(
        decoration: const BoxDecoration( 
          gradient: LinearGradient( 
            begin: Alignment.topCenter, 
            end: Alignment.bottomCenter, 
            colors: [Color(0xFF0A1411), Color(0xFF050505)], // Verde ultra oscuro a negro 
          ), 
        ),
        child: SafeArea(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: neonGreen))
            : (_hasError || _rankingData.isEmpty)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sync_problem,
                          color: neonGreen.withOpacity(0.5),
                          size: 80,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Sincronizando ranking con el servidor...",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Vuelve a intentarlo en unos minutos.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _fetchRanking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: neonGreen,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "REINTENTAR",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    // CONTENIDO PRINCIPAL: Podio Estático + Lista Scrolleable
                    Column(
                      children: [
                        // NUEVO ENCABEZADO DE ESTADÍSTICAS V9.1
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Lado Izquierdo: Total Usuarios
                              Row(
                                children: [
                                  const Icon(Icons.group_outlined, color: neonGreen, size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${_rankingData.length} usuarios",
                                    style: const TextStyle(
                                      color: neonGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      fontFamily: 'Poppins',
                                      shadows: [
                                        Shadow(color: neonGreen, blurRadius: 8),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // Lado Derecho: Mis Ganancias (Haniel ID 37)
                              Row(
                                children: [
                                  const Icon(Icons.account_balance_wallet_outlined, color: neonGreen, size: 20),
                                  const SizedBox(width: 6),
                                  GetBuilder<DashboardController>(
                                    builder: (dash) {
                                      // Prioridad: 1. Data del Ranking, 2. Data del Dashboard (userBalance)
                                      final balance = _currentUserRanking != null 
                                          ? _currentUserRanking!['amount'].toString()
                                          : dash.dashboardData?.data.userTotals.userBalance ?? "0";
                                      
                                      return Text(
                                        "S/ $balance",
                                        style: const TextStyle(
                                          color: neonGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          fontFamily: 'Poppins',
                                          shadows: [
                                            Shadow(color: neonGreen, blurRadius: 8),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // PODIO ESTÁTICO (Top 3)
                        if (_rankingData.length >= 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // 2do Lugar
                                if (_rankingData.length > 1)
                                  construirTarjetaPodio(
                                    "2", 
                                    "${_rankingData[1]['firstname']} ${_rankingData[1]['lastname']}", 
                                    _rankingData[1]['avatar'], 
                                    "${_rankingData[1]['amount'] ?? 0}", 
                                    "${_rankingData[1]['rank']}", 
                                    const Color(0xFFC0C0C0), 
                                    false
                                  ),
                                
                                // 1er Lugar
                                construirTarjetaPodio(
                                  "1", 
                                  "${_rankingData[0]['firstname']} ${_rankingData[0]['lastname']}", 
                                  _rankingData[0]['avatar'], 
                                  "${_rankingData[0]['amount'] ?? 0}", 
                                  "${_rankingData[0]['rank']}", 
                                  const Color(0xFFFFD700), 
                                  true
                                ),

                                // 3er Lugar
                                if (_rankingData.length > 2)
                                  construirTarjetaPodio(
                                    "3", 
                                    "${_rankingData[2]['firstname']} ${_rankingData[2]['lastname']}", 
                                    _rankingData[2]['avatar'], 
                                    "${_rankingData[2]['amount'] ?? 0}", 
                                    "${_rankingData[2]['rank']}", 
                                    const Color(0xFFCD7F32), 
                                    false
                                  ),
                              ],
                            ),
                          ),

                        // LISTA SCROLLEABLE (Puesto 4 en adelante)
                        Expanded(
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 120),
                              itemCount: _rankingData.length > 3 ? _rankingData.length - 3 : 0,
                              itemBuilder: (context, index) {
                                final user = _rankingData[index + 3];
                                final position = index + 4;
                                final String fullName = "${user['firstname']} ${user['lastname']}";
                                
                                return Column(
                                  children: [
                                    ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      leading: SizedBox(
                                        width: 30,
                                        child: Text(
                                          position.toString(),
                                          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      title: Row(
                                        children: [
                                          _buildUserAvatar(40, fullName, user['avatar']),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _formatName(fullName),
                                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  "Rango: ${user['rank']}",
                                                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Text(
                                        "${user['amount'] ?? 0}",
                                        style: const TextStyle(color: neonGreen, fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                    ),
                                    const Divider(color: Colors.white10, height: 1, indent: 50),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    // TARJETA FIJA ABAJO (Tu Ranking)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          left: 20, 
                          right: 20, 
                          top: 16, 
                          bottom: 16 + MediaQuery.of(context).padding.bottom
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF151520).withOpacity(0.98),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.3)),
                          boxShadow: const [
                            BoxShadow(color: Colors.black87, blurRadius: 20, offset: Offset(0, -5))
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "Tu ranking",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins'),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _currentUserPosition == 1
                                        ? "¡Felicidades! Eres el líder del ranking global."
                                        : _currentUserPosition > 0
                                            ? "¡Sigue así para subir al Top 3!"
                                            : "Explora la lista completa",
                                    style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                        fontFamily: 'Poppins'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.only(right: 16),
                              child: Text(
                                _currentUserPosition > 0
                                    ? "#$_currentUserPosition de ${_rankingData.length}"
                                    : "Cargando...",
                                softWrap: false,
                                style: const TextStyle(
                                    color: neonGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    fontFamily: 'Poppins'),
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
