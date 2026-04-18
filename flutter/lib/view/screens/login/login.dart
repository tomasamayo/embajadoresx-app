import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:affiliatepro_mobile/controller/login_controller.dart';
import 'package:affiliatepro_mobile/utils/text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../base/custom_loader.dart';
import '../../base/custom_text_field.dart';
import '../../base/loading.dart';
import '../../base/validations.dart';
import '../registration/registration.dart';
import '../../../service/api_service.dart';
import 'tech_background.dart';
import 'vault_intro_overlay.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
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

    bool isValid;
    if (kDebugMode && kIsWeb) {
      debugPrint(
          '🧪 [LICENSE] Bypass local activado para Flutter web en modo debug.');
      isValid = true;
    } else {
      isValid = await ApiService.instance.validateLicense();
    }
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
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
                resizeToAvoidBottomInset:
                    false, // Prevent background from resizing awkwardly
                body: Stack(
                  children: [
                    // New Tech Background
                    const Positioned.fill(
                      child: TechBackground(),
                    ),

                    Positioned(
                      top: 42,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        ignoring: true,
                        child: FadeTransition(
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
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 26,
                                    vertical: 18,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: <Color>[
                                        const Color(0xFF0D1914)
                                            .withOpacity(0.48),
                                        const Color(0xFF111322)
                                            .withOpacity(0.16),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: const Color(0xFF00FF88)
                                          .withOpacity(0.18),
                                    ),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: const Color(0xFF00FF88)
                                            .withOpacity(0.14),
                                        blurRadius: 42,
                                        spreadRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: SizedBox(
                                    width: width * 0.34,
                                    child: Image.asset(
                                      'assets/images/ex_logo.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Main Content Structure
                    Column(
                      children: [
                        // 1. Todo el contenido principal que hace scroll
                        Expanded(
                          child: IgnorePointer(
                            ignoring: !_introDone,
                            child: Container(
                              child: Form(
                                key: _formKey,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: ListView(
                                    padding: const EdgeInsets.only(
                                      top: 212,
                                      bottom: 20,
                                    ),
                                    children: [
                                      SizedBox(
                                          height: height *
                                              0.05), // Reducido para dar espacio arriba

                                      Center(
                                        child: ListView(
                                          shrinkWrap: true,
                                          physics:
                                              const ClampingScrollPhysics(),
                                          children: [
                                            FadeTransition(
                                              opacity: loginOpacity,
                                              child: ScaleTransition(
                                                scale: loginScale,
                                                child: AnimatedBuilder(
                                                  animation: loginBlur,
                                                  builder: (context, child) {
                                                    return ImageFiltered(
                                                      imageFilter:
                                                          ImageFilter.blur(
                                                        sigmaX: loginBlur.value,
                                                        sigmaY: loginBlur.value,
                                                      ),
                                                      child: child,
                                                    );
                                                  },
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            32),
                                                    child: BackdropFilter(
                                                      filter: ImageFilter.blur(
                                                          sigmaX: 16,
                                                          sigmaY: 16),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color(
                                                              0xFF151520),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(24),
                                                          border: Border.all(
                                                              color: const Color(
                                                                      0xFF00FF88)
                                                                  .withOpacity(
                                                                      0.3)),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: const Color(
                                                                      0xFF00FF88)
                                                                  .withOpacity(
                                                                      0.1),
                                                              blurRadius: 30,
                                                              spreadRadius: 2,
                                                            )
                                                          ],
                                                        ),
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      height *
                                                                          0.02),
                                                          child: ListView(
                                                            shrinkWrap: true,
                                                            physics:
                                                                const ClampingScrollPhysics(),
                                                            children: [
                                                              _buildLoginHero(),
                                                              const SizedBox(
                                                                  height: 28),
                                                              CustomTextField(
                                                                textEditingController:
                                                                    loginController
                                                                        .userNameController,
                                                                hintText: AppText
                                                                    .userName,
                                                                validator: (value) =>
                                                                    Validations.validateEmptyField(
                                                                        value,
                                                                        AppText
                                                                            .userName),
                                                                type: 2,
                                                              ),
                                                              SizedBox(
                                                                  height:
                                                                      height *
                                                                          0.025),
                                                              CustomTextField(
                                                                textEditingController:
                                                                    loginController
                                                                        .passwordController,
                                                                hintText: AppText
                                                                    .password,
                                                                obscureText:
                                                                    loginController
                                                                        .isObscure,
                                                                suffixIcon:
                                                                    IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    loginController
                                                                        .toggleObscure();
                                                                  },
                                                                  icon: Icon(
                                                                    loginController
                                                                            .isObscure
                                                                        ? Icons
                                                                            .visibility_off_outlined
                                                                        : Icons
                                                                            .visibility_outlined,
                                                                    color: const Color(
                                                                        0xFF00FF88),
                                                                  ),
                                                                ),
                                                                validator: (value) =>
                                                                    Validations.validateEmptyField(
                                                                        value,
                                                                        AppText
                                                                            .password),
                                                                type: 2,
                                                              ),
                                                              SizedBox(
                                                                  height:
                                                                      height *
                                                                          0.013),
                                                              Theme(
                                                                data: Theme.of(
                                                                        context)
                                                                    .copyWith(
                                                                  checkboxTheme:
                                                                      CheckboxThemeData(
                                                                    fillColor: WidgetStateProperty
                                                                        .resolveWith(
                                                                            (states) {
                                                                      if (states
                                                                          .contains(
                                                                              WidgetState.selected))
                                                                        return const Color(
                                                                            0xFF00FF88);
                                                                      return Colors
                                                                          .transparent;
                                                                    }),
                                                                    side: BorderSide(
                                                                        color: Colors
                                                                            .white
                                                                            .withOpacity(0.25)),
                                                                  ),
                                                                ),
                                                                child:
                                                                    CheckboxListTile(
                                                                  title: Text(
                                                                    AppText
                                                                        .rememberMe,
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Poppins',
                                                                      color: Colors
                                                                          .white
                                                                          .withOpacity(
                                                                              0.9),
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  ),
                                                                  value: loginController
                                                                      .rememberMe,
                                                                  onChanged:
                                                                      (value) {
                                                                    loginController
                                                                        .chnageRemeber();
                                                                  },
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height:
                                                                      height *
                                                                          0.025),
                                                              SizedBox(
                                                                width: double
                                                                    .infinity,
                                                                child: loginController
                                                                        .isLoading
                                                                    ? const Center(
                                                                        child:
                                                                            CustomLoader())
                                                                    : _buildPrimaryLoginButton(
                                                                        width:
                                                                            width,
                                                                        onTap:
                                                                            () {
                                                                          loginController.loginUser(
                                                                              context,
                                                                              _formKey);
                                                                        },
                                                                      ),
                                                              ),
                                                              SizedBox(
                                                                  height:
                                                                      height *
                                                                          0.015),
                                                              // REQUERIMIENTO v5.0.0: Botón Google
                                                              SizedBox(
                                                                width: double
                                                                    .infinity,
                                                                child: loginController
                                                                        .isLoading
                                                                    ? const SizedBox() // Ocultar mientras carga otro proceso
                                                                    : _buildGoogleActionButton(
                                                                        onTap: () =>
                                                                            loginController.signInWithGoogle(context),
                                                                      ),
                                                              ),

                                                              SizedBox(
                                                                  height:
                                                                      height *
                                                                          0.025),
                                                              RichText(
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                text: TextSpan(
                                                                  text: AppText
                                                                      .dontHaveAccount,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Poppins',
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.75),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w300,
                                                                  ),
                                                                  children: <TextSpan>[
                                                                    TextSpan(
                                                                      text:
                                                                          " ${AppText.registration}",
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Color(
                                                                            0xFF00FF88),
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                      recognizer:
                                                                          TapGestureRecognizer()
                                                                            ..onTap =
                                                                                () {
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
                                                              const SizedBox(
                                                                  height: 30),
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
                                      _buildTrustItem(
                                          Icons.verified_user_outlined,
                                          "100% Seguro"),
                                      const SizedBox(width: 16),
                                      _buildTrustItem(Icons.public,
                                          "+${loginController.totalEmbajadores.value} Embajadores"),
                                      const SizedBox(width: 16),
                                      _buildTrustItem(
                                          Icons.monetization_on_outlined,
                                          "${loginController.totalPagados.value} Pagados"),
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

  Widget _buildLoginHero() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFF00FF88).withOpacity(0.16),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                const Color(0xFF0F1A15).withOpacity(0.9),
                const Color(0xFF171726).withOpacity(0.55),
              ],
            ),
          ),
          child: const Text(
            "ACCESO PREMIUM",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF7CFFCA),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.8,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          "CONSTRUYE TU NEGOCIO DIGITAL",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "GANA COMISIONES • ESCALA TU RED",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.58),
            fontSize: 12,
            letterSpacing: 2.4,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 84,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              colors: <Color>[
                Colors.transparent,
                Color(0xFF00FF88),
                Color(0xFFEDFF2E),
                Colors.transparent,
              ],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xFF00FF88).withOpacity(0.22),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryLoginButton({
    required double width,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF19FFA4),
            Color(0xFF00FF88),
            Color(0xFF7CFFCA),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF00FF88).withOpacity(0.24),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.10),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.black,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppText.login,
              style: TextStyle(
                fontSize: width * 0.0405,
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontFamily: 'Poppins',
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleActionButton({
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Colors.white.withOpacity(0.98),
            const Color(0xFFF5F7FB),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.55),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF4285F4).withOpacity(0.12),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _GoogleGlyph(),
            SizedBox(width: 14),
            Text(
              "Continuar con Google",
              style: TextStyle(
                color: Color(0xFF16181D),
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: <Color>[
                  Color(0xFF4285F4),
                  Color(0xFF34A853),
                  Color(0xFFFBBC05),
                  Color(0xFFEA4335),
                  Color(0xFF4285F4),
                ],
              ),
            ),
          ),
          Container(
            width: 17,
            height: 17,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            right: 1,
            child: Container(
              width: 11,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
            ),
          ),
          const Text(
            "G",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
              color: Color(0xFF4285F4),
            ),
          ),
        ],
      ),
    );
  }
}
