import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:affiliatepro_mobile/controller/login_controller.dart';
import 'package:affiliatepro_mobile/utils/text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/colors.dart';
import '../../../utils/images.dart';
import '../../base/custom_loader.dart';
import '../../base/custom_text_field.dart';
import '../../base/loading.dart';
import '../../base/validations.dart';
import '../registration/registration.dart';
import '../../../service/api_service.dart';
import 'tech_background.dart';
import 'vault_intro_overlay.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  bool logingIn = true;
  bool licenseValid = true;
  late final AnimationController _introController;
  bool _introDone = false;
  bool _introStarted = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() {
            _introDone = true;
          });
        }
      });
    initSetup();
  }

  void initSetup() async {
    setState(() {
      logingIn = true;
    });

    bool isValid = await ApiService.instance.validateLicense();
    setState(() {
      licenseValid = isValid;
      logingIn = false;
    });

    if (isValid) {
      // REQUERIMIENTO V18.0: Asegurar que LoginController esté disponible
      if (!Get.isRegistered<LoginController>()) {
        final prefs = await SharedPreferences.getInstance();
        Get.put(LoginController(preferences: prefs), permanent: true);
      }
      checkRememberData();
      _startIntroIfNeeded();
    }
  }

  void checkRememberData() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString(AppText.userName) != null) {
      Get.find<LoginController>().autoLogin(
        context,
        sharedPreferences.getString(AppText.userName) ?? "",
        sharedPreferences.getString(AppText.password) ?? "",
      );
    }
    setState(() {
      logingIn = false;
    });
    _startIntroIfNeeded();
  }

  void _startIntroIfNeeded() {
    if (!licenseValid) return;
    if (_introStarted) return;
    if (!mounted) return;
    _introStarted = true;
    _introController.forward();
  }

  void _skipIntro() {
    if (_introDone) return;
    _introController.value = 1.0;
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    if (!licenseValid) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 80, color: Colors.redAccent),
                const SizedBox(height: 20),
                const Text(
                  'Clave de Licencia Inválida',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Esta aplicación no está activada.\nPor favor contacte al administrador.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    final url = ApiService.instance.baseUrl;
                    Uri uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      launchUrl(uri);
                    }
                  },
                  child: Text(
                    ApiService.instance.baseUrl,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.blueAccent,
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Por favor asegúrese de que su clave de licencia coincida con la de la instalación del sitio web.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () => initSetup(),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Recargar Licencia"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // REQUERIMIENTO V18.0: Blindaje de controlador
    if (!Get.isRegistered<LoginController>()) {
      return const Loading();
    }
    
    return GetBuilder<LoginController>(
      builder: (loginController) {
        final loginOpacity = CurvedAnimation(
          parent: _introController,
          curve: const Interval(0.75, 0.95, curve: Curves.easeInOutQuart),
        );
        final loginScale = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _introController,
            curve: const Interval(0.75, 0.95, curve: Curves.easeOutQuart),
          ),
        );
        final loginBlur = Tween<double>(begin: 20.0, end: 0.0).animate(
          CurvedAnimation(
            parent: _introController,
            curve: const Interval(0.75, 0.90, curve: Curves.easeIn),
          ),
        );

        return logingIn
            ? Loading()
            : Scaffold(
                resizeToAvoidBottomInset: false, // Prevent background from resizing awkwardly
                body: Stack(
                  children: [
                    // New Tech Background
                    const Positioned.fill(
                      child: TechBackground(),
                    ),
                    
                    // Main Content Structure
                    Column(
                      children: [
                        // 1. Todo el contenido principal que hace scroll
                        Expanded(
                          child: IgnorePointer(
                            ignoring: !_introDone,
                            child: Container(
                              margin: const EdgeInsets.only(top: 60), // Reparación de diseño inmersivo: Logo respira a 60px tras eliminar franja negra
                              child: Form(
                                key: _formKey,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  child: ListView(
                                    reverse: true,
                                    children: [
                                      SizedBox(height: height * 0.05), // Reducido para dar espacio arriba

                                    Center(
                                      child: ListView(
                                        shrinkWrap: true,
                                        physics: const ClampingScrollPhysics(),
                                        children: [
                                          FadeTransition(
                                            opacity: loginOpacity,
                                            child: ScaleTransition(
                                              scale: loginScale,
                                              child: AnimatedBuilder(
                                                animation: loginBlur,
                                                builder: (context, child) {
                                                  return ImageFiltered(
                                                    imageFilter: ImageFilter.blur(
                                                      sigmaX: loginBlur.value,
                                                      sigmaY: loginBlur.value,
                                                    ),
                                                    child: child,
                                                  );
                                                },
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(32),
                                                  child: BackdropFilter(
                                                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF151520),
                                                        borderRadius: BorderRadius.circular(24),
                                                        border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.3)),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: const Color(0xFF00FF88).withOpacity(0.1),
                                                            blurRadius: 30,
                                                            spreadRadius: 2,
                                                          )
                                                        ],
                                                      ),
                                                      child: Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: height * 0.02),
                                                        child: ListView(
                                                          shrinkWrap: true,
                                                          physics: const ClampingScrollPhysics(),
                                                          children: [
                                                            const SizedBox(height: 30),
                                                            const Text(
                                                              "CONSTRUYE TU NEGOCIO DIGITAL",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontWeight: FontWeight.bold,
                                                                letterSpacing: 1.2,
                                                                fontFamily: 'Poppins',
                                                              ),
                                                            ),
                                                            const SizedBox(height: 8),
                                                            const Text(
                                                              "GANA COMISIONES • ESCALA TU RED",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                color: Colors.white54,
                                                                fontSize: 12,
                                                                letterSpacing: 2,
                                                                fontFamily: 'Poppins',
                                                              ),
                                                            ),
                                                            const SizedBox(height: 25),
                                                            CustomTextField(
                                                              textEditingController: loginController.userNameController,
                                                              hintText: AppText.userName,
                                                              validator: (value) => Validations.validateEmptyField(value, AppText.userName),
                                                              type: 2,
                                                            ),
                                                            SizedBox(height: height * 0.025),
                                                            CustomTextField(
                                                              textEditingController: loginController.passwordController,
                                                              hintText: AppText.password,
                                                              obscureText: loginController.isObscure,
                                                              suffixIcon: IconButton(
                                                                onPressed: () {
                                                                  loginController.toggleObscure();
                                                                },
                                                                icon: Icon(
                                                                  loginController.isObscure
                                                                      ? Icons.visibility_off_outlined
                                                                      : Icons.visibility_outlined,
                                                                  color: const Color(0xFF00FF88),
                                                                ),
                                                              ),
                                                              validator: (value) => Validations.validateEmptyField(value, AppText.password),
                                                              type: 2,
                                                            ),
                                                            SizedBox(height: height * 0.013),
                                                            Theme(
                                                              data: Theme.of(context).copyWith(
                                                                checkboxTheme: CheckboxThemeData(
                                                                  fillColor: WidgetStateProperty.resolveWith((states) {
                                                                    if (states.contains(WidgetState.selected)) return const Color(0xFF00FF88);
                                                                    return Colors.transparent;
                                                                  }),
                                                                  side: BorderSide(color: Colors.white.withOpacity(0.25)),
                                                                ),
                                                              ),
                                                              child: CheckboxListTile(
                                                                title: Text(
                                                                  AppText.rememberMe,
                                                                  style: TextStyle(
                                                                    fontFamily: 'Poppins',
                                                                    color: Colors.white.withOpacity(0.9),
                                                                  ),
                                                                ),
                                                                value: loginController.rememberMe,
                                                                onChanged: (value) {
                                                                  loginController.chnageRemeber();
                                                                },
                                                              ),
                                                            ),
                                                            SizedBox(height: height * 0.025),
                                                            SizedBox(
                                                              width: double.infinity,
                                                              child: loginController.isLoading
                                                                  ? const Center(child: CustomLoader())
                                                                  : ElevatedButton(
                                                                      onPressed: () {
                                                                        loginController.loginUser(context, _formKey);
                                                                      },
                                                                      style: ElevatedButton.styleFrom(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                                                                        shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(20),
                                                                        ),
                                                                        backgroundColor: const Color(0xFF00FF88),
                                                                        elevation: 0,
                                                                      ),
                                                                      child: Text(
                                                                        AppText.login,
                                                                        style: TextStyle(
                                                                          fontSize: width * 0.04,
                                                                          color: Colors.black,
                                                                          fontWeight: FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                            ),
                                                            SizedBox(height: height * 0.015),
                                                            // REQUERIMIENTO v5.0.0: Botón Google
                                                            SizedBox(
                                                              width: double.infinity,
                                                              child: loginController.isLoading
                                                                  ? const SizedBox() // Ocultar mientras carga otro proceso
                                                                  : ElevatedButton.icon(
                                                                      onPressed: () => loginController.signInWithGoogle(context),
                                                                      icon: const FaIcon(FontAwesomeIcons.google, color: Colors.white, size: 18),
                                                                      label: const Text(
                                                                        "Continuar con Google",
                                                                        style: TextStyle(
                                                                          color: Colors.white,
                                                                          fontWeight: FontWeight.bold,
                                                                          fontFamily: 'Poppins',
                                                                        ),
                                                                      ),
                                                                      style: ElevatedButton.styleFrom(
                                                                        backgroundColor: const Color(0xFF4285F4),
                                                                        padding: const EdgeInsets.symmetric(vertical: 15),
                                                                        shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(8),
                                                                        ),
                                                                        elevation: 0,
                                                                      ),
                                                                    ),
                                                            ),

                                                            SizedBox(height: height * 0.025),
                                                            RichText(
                                                              textAlign: TextAlign.center,
                                                              text: TextSpan(
                                                                text: AppText.dontHaveAccount,
                                                                style: TextStyle(
                                                                  fontFamily: 'Poppins',
                                                                  color: Colors.white.withOpacity(0.75),
                                                                  fontWeight: FontWeight.w300,
                                                                ),
                                                                children: <TextSpan>[
                                                                  TextSpan(
                                                                    text: " ${AppText.registration}",
                                                                    style: const TextStyle(
                                                                      color: Color(0xFF00FF88),
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                    recognizer: TapGestureRecognizer()
                                                                      ..onTap = () {
                                                                        Navigator.of(context).push(
                                                                          MaterialPageRoute(
                                                                            builder: (context) => const RegistrationScreen(),
                                                                          ),
                                                                        );
                                                                      },
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(height: 30),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: height * 0.03), // Espaciado entre logo y modal

                                    // Logo container above the modal
                                    Center(
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 50), // Forzar el logo hacia abajo para evitar corte superior
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF00FF88).withOpacity(0.5),
                                                  blurRadius: 20,
                                                  spreadRadius: 5,
                                                ),
                                              ],
                                            ),
                                            child: Image.asset(
                                              'assets/images/ic_launcher.png',
                                              height: height * 0.15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 2. El Footer fijado en la parte inferior absoluta
                        SafeArea(
                          top: false,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20, top: 16),
                            child: FittedBox(
                              child: Obx(() => Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildTrustItem(Icons.verified_user_outlined, "100% Seguro"),
                                  const SizedBox(width: 16),
                                  _buildTrustItem(Icons.public, "+${loginController.totalEmbajadores.value} Embajadores"),
                                  const SizedBox(width: 16),
                                  _buildTrustItem(Icons.monetization_on_outlined, "${loginController.totalPagados.value} Pagados"),
                                ],
                              )),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!_introDone)
                      Positioned.fill(
                        child: VaultIntroOverlay(
                          animation: _introController,
                          onSkip: _skipIntro,
                        ),
                      ),
                  ],
                ),
              );
      },
    );
  }

  Widget _buildTrustItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF00FF88), size: 18),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w300,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}
