import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:affiliatepro_mobile/utils/colors.dart';
import 'package:affiliatepro_mobile/service/academy_service.dart';
import 'package:affiliatepro_mobile/view/screens/course_details_screen.dart';

class AcademyScreen extends StatefulWidget {
  const AcademyScreen({super.key});

  @override
  State<AcademyScreen> createState() => _AcademyScreenState();
}

class _AcademyScreenState extends State<AcademyScreen> {
  // Misión 2: Eliminar 'late' y usar Future nullable
  Future<List<CourseModel>>? _coursesFuture;
  List<CourseModel> _allCourses = []; // Cache local para filtrado instantáneo
  List<CourseModel> _filteredCourses = [];
  bool _isFiltering = false;
  String _currentFilter = "Recientes";

  static const Color neonGreen = Color(0xFF00FF88);
  String currentUserId = "Cargando...";

  // REQUERIMIENTO: Control de vista (Lista/Cuadros)
  bool isGridView = false;

  @override
  void initState() {
    super.initState();
    // Misión: Carga diferida para asegurar sincronización de ID (RAM/Disco)
    _initAcademy();
  }

  Future<void> _initAcademy() async {
    // Pequeño retardo de cortesía para asegurar que el ID esté listo
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      _loadCourses();
      _loadCurrentUserId();
    }
  }

  Future<void> _loadCourses() async {
    setState(() {
      _coursesFuture = AcademyService.instance.getCourses();
    });
    
    final courses = await _coursesFuture;
    if (mounted && courses != null) {
      setState(() {
        _allCourses = courses;
        _applyFilter(_currentFilter);
      });
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _currentFilter = filter;
      _isFiltering = true;
      
      List<CourseModel> temp = List.from(_allCourses);
      
      if (filter == "Más Recientes") {
        // Ordenar por ID descendente
        temp.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
      } else if (filter == "En Progreso") {
        // Cursos con progreso > 0 primero
        temp.sort((a, b) => (b.progressPercentage ?? 0).compareTo(a.progressPercentage ?? 0));
        // Filtrar solo los que tienen progreso real si se prefiere, 
        // pero el requerimiento dice "muestra primero los que tengan progres_percentage > 0"
      }
      
      _filteredCourses = temp;
      _isFiltering = false;
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A0A0A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          border: Border.all(color: neonGreen.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "FILTRAR CURSOS",
              style: TextStyle(
                color: neonGreen,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 32),
            _filterOption(
              title: "Más Recientes",
              icon: Icons.new_releases_outlined,
              isSelected: _currentFilter == "Más Recientes",
              onTap: () {
                Navigator.pop(context);
                _applyFilter("Más Recientes");
              },
            ),
            const SizedBox(height: 16),
            _filterOption(
              title: "En Progreso",
              icon: Icons.trending_up_rounded,
              isSelected: _currentFilter == "En Progreso",
              onTap: () {
                Navigator.pop(context);
                _applyFilter("En Progreso");
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _filterOption({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? neonGreen.withOpacity(0.1) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? neonGreen : Colors.white10,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? neonGreen : Colors.white54),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: neonGreen, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        currentUserId = prefs.getString('user_id') ?? "No encontrado";
      });
    }
  }

  Future<void> _refreshCourses() async {
    await _loadCourses();
    await _loadCurrentUserId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.dashboardBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Academia EX",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _refreshCourses,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: RepaintBoundary(
        child: Stack(
          children: [
            // Background Aesthetic Gradient
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      neonGreen.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            SafeArea(
              child: RefreshIndicator(
                onRefresh: _refreshCourses,
                color: neonGreen,
                backgroundColor: const Color(0xFF151520),
                child: FutureBuilder<List<CourseModel>>(
                  future: _coursesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: neonGreen),
                            SizedBox(height: 16),
                            Text("Cargando tus cursos asignados...", 
                              style: TextStyle(color: Colors.white54, fontSize: 12)),
                          ],
                        ),
                      );
                    } 
                    
                    if (snapshot.hasError || (snapshot.hasData && (snapshot.data?.isEmpty ?? true))) {
                      return ListView( // Usamos ListView para que el RefreshIndicator funcione
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.7,
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: neonGreen.withOpacity(0.05),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.auto_stories_outlined, color: neonGreen, size: 60),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  "Aún no tienes cursos asignados a tu plan",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "¡Adquiere un plan para comenzar tu formación profesional!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white54, fontSize: 14),
                                ),
                                const SizedBox(height: 32),
                                ElevatedButton(
                                  onPressed: _refreshCourses,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: neonGreen,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                    elevation: 8,
                                    shadowColor: neonGreen.withOpacity(0.4),
                                  ),
                                  child: const Text("ACTUALIZAR", 
                                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 14)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    final courses = _filteredCourses;
                
                // Calcular progreso general basado en los cursos de la lista filtrada
                double totalProgress = courses.isEmpty 
                    ? 0.0 
                    : (courses.map((e) => e.progressPercentage ?? 0.0).reduce((a, b) => a + b) / courses.length) / 100.0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: totalProgress.clamp(0.0, 1.0),
                                    backgroundColor: Colors.white.withOpacity(0.05),
                                    valueColor: const AlwaysStoppedAnimation<Color>(neonGreen),
                                    minHeight: 8,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                "${(totalProgress * 100).toInt()}%",
                                style: const TextStyle(
                                  color: neonGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "TU PROGRESO GENERAL",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // REQUERIMIENTO: Cabecera de Control (Filtro y Selector de Vista Único Inteligente)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Row(
                        children: [
                          // Botón Filtro con lógica V16.0
                          GestureDetector(
                            onTap: _showFilterSheet,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A25),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: neonGreen.withOpacity(0.3)),
                                boxShadow: [
                                  BoxShadow(
                                    color: neonGreen.withOpacity(0.05),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.filter_list, color: neonGreen, size: 20),
                                  if (_currentFilter != "Recientes") ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      _currentFilter.toUpperCase(),
                                      style: const TextStyle(
                                        color: neonGreen,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                          // REQUERIMIENTO: Botón Único Inteligente para Alternar Vista con Animación de Icono
                          GestureDetector(
                            onTap: () => setState(() => isGridView = !isGridView),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A25),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: neonGreen.withOpacity(0.3),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: neonGreen.withOpacity(0.1),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  return ScaleTransition(scale: animation, child: child);
                                },
                                child: Icon(
                                  isGridView ? Icons.view_list : Icons.grid_view,
                                  key: ValueKey<bool>(isGridView),
                                  color: neonGreen,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // REQUERIMIENTO: Animación de Transición Espectacular (Slide Up & Fade)
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          final offsetAnimation = Tween<Offset>(
                            begin: const Offset(0.0, 0.2),
                            end: Offset.zero,
                          ).animate(animation);
                          
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            ),
                          );
                        },
                        child: isGridView 
                          ? GridView.builder(
                              key: const ValueKey('grid_view_academy'),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.72,
                              ),
                              itemCount: courses.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return _buildCourseGridCard(courses[index]);
                              },
                            )
                          : ListView.builder(
                              key: const ValueKey('list_view_academy'),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              itemCount: courses.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final course = courses[index];
                                bool isLocked = index > 0 && (courses[index-1].progressPercentage ?? 0.0) < 100.0;
                                return _buildCourseCard(course, isLocked);
                              },
                            ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    ),
  ),
);
}

  Widget _viewToggleButton(IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? neonGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive ? [
            BoxShadow(
              color: neonGreen.withOpacity(0.3), 
              blurRadius: 12, 
              spreadRadius: 1,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Icon(
          icon, 
          color: isActive ? Colors.black : Colors.white.withOpacity(0.3), 
          size: 20
        ),
      ),
    );
  }

  Widget _buildCourseGridCard(CourseModel curso) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => CourseDetailsScreen(courseId: curso.id ?? 0)
          )
        ).then((_) => _refreshCourses());
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // REQUERIMIENTO: Diseño Premium con Degradado
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A25),
              const Color(0xFF0A1A15), // Verde muy oscuro profundo
            ],
          ),
          border: Border.all(color: neonGreen.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen compacta
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    if (curso.imageUrl != null && curso.imageUrl!.isNotEmpty)
                      Positioned.fill(
                        child: CachedNetworkImage(
                          imageUrl: curso.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.white.withOpacity(0.05),
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: neonGreen)),
                          ),
                          errorWidget: (context, url, error) => const Center(
                            child: Icon(Icons.video_library_rounded, color: Colors.white10, size: 30),
                          ),
                        ),
                      )
                    else
                      const Center(
                        child: Icon(Icons.video_library_rounded, color: Colors.white10, size: 30),
                      ),
                    
                    // REQUERIMIENTO: Badge de porcentaje con degradado neón
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              neonGreen.withOpacity(0.9),
                              const Color(0xFF00AA55),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(color: neonGreen.withOpacity(0.3), blurRadius: 4)
                          ],
                        ),
                        child: Text(
                          "${(curso.progressPercentage ?? 0.0).toInt()}%",
                          style: const TextStyle(
                            color: Colors.black, 
                            fontSize: 10, 
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Título y detalles compactos
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        (curso.name ?? '').toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          height: 1.2,
                        ),
                      ),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // REQUERIMIENTO: Texto de lecciones más brillante
                          Text(
                            "${curso.completedCount ?? 0}/${curso.lessonsCount ?? 0} Lecc.",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: (curso.progressPercentage ?? 0.0) / 100,
                              backgroundColor: Colors.white.withOpacity(0.05),
                              valueColor: const AlwaysStoppedAnimation<Color>(neonGreen),
                              minHeight: 3,
                            ),
                          ),
                        ],
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

  Widget _buildCourseCard(CourseModel curso, bool isLocked) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => CourseDetailsScreen(courseId: curso.id ?? 0)
          )
        ).then((_) => _refreshCourses());
      },
      child: Container(
        height: 180,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          // REQUERIMIENTO: Diseño Premium con Degradado
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A25),
              const Color(0xFF0A1A15),
            ],
          ),
          border: Border.all(color: neonGreen.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              if (curso.imageUrl != null && curso.imageUrl!.isNotEmpty)
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: curso.imageUrl!,
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.2),
                    colorBlendMode: BlendMode.darken,
                    placeholder: (context, url) => Container(
                      color: Colors.white.withOpacity(0.05),
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: neonGreen)),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.video_library_rounded, color: Colors.white10, size: 60),
                    ),
                  ),
                )
              else
                const Center(
                  child: Icon(Icons.video_library_rounded, color: Colors.white10, size: 60),
                ),

              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.3, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.95),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (curso.name ?? '').toUpperCase(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14, // REQUERIMIENTO V20.1: Reducción de fuente para diseño premium
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Poppins',
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: neonGreen.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: neonGreen.withOpacity(0.3), width: 0.5),
                                    ),
                                    child: Text(
                                      "${curso.completedCount ?? 0}/${curso.lessonsCount ?? 0} LECCIONES",
                                      style: const TextStyle(
                                        color: neonGreen,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // REQUERIMIENTO: Badge de porcentaje con degradado en vista lista
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          neonGreen.withOpacity(0.9),
                                          const Color(0xFF00AA55),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      "${(curso.progressPercentage ?? 0.0).toInt()}%",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: neonGreen,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: neonGreen.withOpacity(0.4),
                                blurRadius: 12,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.black,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (curso.progressPercentage ?? 0.0) / 100,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(neonGreen),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
