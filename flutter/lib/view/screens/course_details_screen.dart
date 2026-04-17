import 'package:flutter/material.dart';
import 'package:affiliatepro_mobile/service/academy_service.dart';
import 'package:affiliatepro_mobile/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class CourseDetailsScreen extends StatefulWidget {
  final int courseId;
  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  Future<List<LessonModel>>? _lessonsFuture;
  LessonModel? _currentLesson;
  static const Color neonGreen = Color(0xFF00FF88);

  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isCompletedTriggered = false;

  @override
  void initState() {
    super.initState();
    _lessonsFuture = AcademyService.instance.getCourseContent(widget.courseId);
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _initializeVideoPlayer(String videoUrl) async {
    // Liberar controladores anteriores
    await _videoPlayerController?.dispose();
    _chewieController?.dispose();
    
    _isCompletedTriggered = false;

    if (videoUrl.isEmpty) {
      setState(() {
        _videoPlayerController = null;
        _chewieController = null;
      });
      return;
    }

    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    
    try {
      await _videoPlayerController!.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: neonGreen,
          handleColor: neonGreen,
          backgroundColor: Colors.white.withOpacity(0.1),
          bufferedColor: Colors.white.withOpacity(0.2),
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(child: CircularProgressIndicator(color: neonGreen)),
        ),
        autoInitialize: true,
      );

      _videoPlayerController!.addListener(_videoListener);
      setState(() {});
    } catch (e) {
      print("Error inicializando video: $e");
    }
  }

  void _videoListener() {
    if (_videoPlayerController == null || !_videoPlayerController!.value.isInitialized || _isCompletedTriggered || (_currentLesson?.isCompleted ?? true)) return;
    
    final position = _videoPlayerController!.value.position;
    final duration = _videoPlayerController!.value.duration;
    
    // Candado de seguridad: Detectar final del video (con margen de 500ms por si acaso)
    if (position >= duration - const Duration(milliseconds: 500) && duration > Duration.zero) {
      _isCompletedTriggered = true;
      _markAsCompleted();
    }
  }

  void _selectLesson(LessonModel lesson) {
    if (_currentLesson?.id == lesson.id) return;
    setState(() {
      _currentLesson = lesson;
    });
    _initializeVideoPlayer(lesson.videoUrl);
  }

  Future<void> _markAsCompleted() async {
    if (_currentLesson == null || (_currentLesson?.isCompleted ?? true)) return;
    
    // Guardar referencia para actualizar UI localmente antes de llamar a la API si se desea, 
    // pero mejor esperar a la respuesta para dar feedback real.
    final success = await AcademyService.instance.completeLesson(_currentLesson?.id ?? 0, widget.courseId);
    
    // Feedback visual premium (SnackBar Neón) - Se muestra incluso si falla para indicar que se procesó el final del video
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1A1A1A),
          margin: const EdgeInsets.all(20),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: success ? neonGreen : Colors.redAccent, width: 1.5),
          ),
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (success ? neonGreen : Colors.redAccent).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  success ? Icons.stars_rounded : Icons.error_outline_rounded, 
                  color: success ? neonGreen : Colors.redAccent, 
                  size: 24
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      success ? "¡Felicidades!" : "Aviso de progreso",
                      style: TextStyle(
                        color: success ? neonGreen : Colors.redAccent, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 14
                      ),
                    ),
                    Text(
                      success 
                        ? "Has completado esta lección. El progreso se ha actualizado."
                        : "Video finalizado. El servidor no confirmó el guardado, pero puedes continuar.",
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
    
    // Misión: Forzar refresco de los datos locales para que al volver a AcademyScreen los datos ya estén listos
    // Incluso si falla, actualizamos el estado local para que el usuario sienta fluidez
    if (mounted) {
      setState(() {
        if (_currentLesson != null) {
          _currentLesson!.isCompleted = true;
        }
        _lessonsFuture = AcademyService.instance.getCourseContent(widget.courseId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.dashboardBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Contenido del Curso",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<LessonModel>>(
        future: _lessonsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: neonGreen));
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No se pudo cargar el contenido", style: TextStyle(color: Colors.white54)),
            );
          }

          final lessons = snapshot.data!;
          if (_currentLesson == null) {
            _currentLesson = lessons.first;
            // Inicializar video de la primera lección solo una vez
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _initializeVideoPlayer(_currentLesson!.videoUrl);
            });
          }

          return Column(
            children: [
              // 1. SECCIÓN FIJA (Video + Título + Recursos)
              _buildFixedTopSection(lessons),

              // 2. SECCIÓN CON SCROLL (Lista de Lecciones)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: lessons.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final lesson = lessons[index];
                    final isSelected = _currentLesson?.id == lesson.id;
                    
                    // Lógica de Bloqueo Secuencial Corregida:
                    // 1. Una lección NUNCA está bloqueada si ya está completada.
                    // 2. Si no está completada, está bloqueada solo si no es la primera y la anterior no está completada.
                    bool isLocked = !(lesson.isCompleted ?? false) && index > 0 && !(lessons[index - 1].isCompleted ?? false);
                    
                    return _buildLessonItem(lesson, isSelected, isLocked);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFixedTopSection(List<LessonModel> lessons) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reproductor de Video
        _buildVideoPlayer(),

        // Información de la Lección Actual
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      _currentLesson?.title ?? "Cargando lección...",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20, // Un poco más pequeño para optimizar espacio
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  if (_currentLesson?.isCompleted ?? false) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: neonGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: neonGreen.withOpacity(0.3), width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.check_circle_rounded, color: neonGreen, size: 12),
                          SizedBox(width: 4),
                          Text(
                            "VISTA",
                            style: TextStyle(
                              color: neonGreen,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              // Sección de Recursos (si existen)
              if (_currentLesson?.resources.isNotEmpty ?? false) ...[
                const Text(
                  "MATERIALES",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _currentLesson!.resources.map((res) => _buildCompactResourceItem(res)).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
        
        const Divider(color: Colors.white10, thickness: 1, height: 32),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: const Text(
            "CONTENIDO DEL CURSO",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCompactResourceItem(String resourceUrl) {
    String fileName = resourceUrl.split('/').last;
    if (fileName.isEmpty) fileName = "Recurso";
    if (fileName.length > 15) fileName = "${fileName.substring(0, 12)}...";

    return GestureDetector(
      onTap: () async {
        final url = Uri.parse(resourceUrl);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: neonGreen.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: neonGreen.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.file_download_outlined, color: neonGreen, size: 16),
            const SizedBox(width: 8),
            Text(
              fileName,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
      width: double.infinity,
      height: 230,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: neonGreen.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
          ? Chewie(controller: _chewieController!)
          : Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(color: neonGreen),
              ),
            ),
    );
  }

  Widget _buildResourceItem(String resourceUrl) {
    // Extraer el nombre del archivo de la URL
    String fileName = resourceUrl.split('/').last;
    if (fileName.isEmpty) fileName = "Recurso";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        onTap: () async {
          final url = Uri.parse(resourceUrl);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
        leading: const Icon(Icons.file_download_outlined, color: neonGreen),
        title: Text(
          fileName,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      ),
    );
  }

  Widget _buildLessonItem(LessonModel lesson, bool isSelected, bool isLocked) {
    return InkWell(
      onTap: isLocked 
        ? () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Completa la lección anterior para continuar"),
                backgroundColor: Colors.black87,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        : () => _selectLesson(lesson),
      child: Opacity(
        opacity: isLocked ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isLocked 
                ? Colors.black.withOpacity(0.3) // Fondo mucho más oscuro para bloqueados
                : (isSelected ? neonGreen.withOpacity(0.1) : Colors.transparent),
            borderRadius: BorderRadius.circular(12),
            border: isSelected 
                ? Border.all(color: neonGreen.withOpacity(0.3)) 
                : (isLocked ? Border.all(color: Colors.white.withOpacity(0.02)) : null),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isLocked 
                      ? Colors.white.withOpacity(0.05) 
                      : (lesson.isCompleted ? neonGreen : Colors.white.withOpacity(0.05)),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLocked 
                      ? Icons.lock_outline_rounded 
                      : (lesson.isCompleted ? Icons.check : Icons.play_arrow),
                  color: isLocked 
                      ? Colors.white24 
                      : (lesson.isCompleted ? Colors.black : Colors.white24),
                  size: 16,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: TextStyle(
                        color: isSelected ? neonGreen : Colors.white,
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    Text(
                      lesson.duration,
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
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
