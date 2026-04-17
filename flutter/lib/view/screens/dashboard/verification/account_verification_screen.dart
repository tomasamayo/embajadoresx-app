import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';
import 'package:affiliatepro_mobile/controller/dashboard_controller.dart';
import 'package:affiliatepro_mobile/service/verification_service.dart';

class AccountVerificationScreen extends StatefulWidget {
  const AccountVerificationScreen({super.key});

  @override
  State<AccountVerificationScreen> createState() => _AccountVerificationScreenState();
}

class _AccountVerificationScreenState extends State<AccountVerificationScreen> {
  final DashboardController _dashboardController = Get.find<DashboardController>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  XFile? _dniImage;
  XFile? _dniBackImage;
  XFile? _faceImage;
  bool _isSubmitting = false;

  // v1.2.0: Configuración de Países (Estandarización)
  String _selectedCountryIso = 'PE';
  final Map<String, String> _countryPhoneCodes = {
    'US': '+1', 'PE': '+51', 'MX': '+52', 'CO': '+57', 'AR': '+54', 'CL': '+56', 'EC': '+593', 'VE': '+58', 'BR': '+55', 'BO': '+591', 'PY': '+595', 'UY': '+598', 'CR': '+506', 'PA': '+507', 'DO': '+1-809', 'SV': '+503', 'GT': '+502', 'HN': '+504', 'NI': '+505', 'PR': '+1-787',
    'ES': '+34', 'PT': '+351', 'FR': '+33', 'DE': '+49', 'IT': '+39', 'NL': '+31', 'BE': '+32', 'CH': '+41', 'AT': '+43', 'IE': '+353', 'GB': '+44', 'SE': '+46', 'NO': '+47', 'DK': '+45', 'FI': '+358', 'IS': '+354', 'RO': '+40', 'BG': '+359', 'GR': '+30', 'HU': '+36', 'CZ': '+420', 'PL': '+48',
  };

  String _flagEmoji(String code) {
    if (code.length != 2) return '';
    final upper = code.toUpperCase();
    const int base = 0x1F1E6;
    final int first = upper.codeUnitAt(0) - 65;
    final int second = upper.codeUnitAt(1) - 65;
    return String.fromCharCode(base + first) + String.fromCharCode(base + second);
  }

  @override
  void initState() {
    super.initState();
    // Actualizar estado al entrar
    _dashboardController.fetchVerificationStatus();
  }

  Future<void> _pickImage(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        if (index == 1) {
          _dniImage = pickedFile;
        } else if (index == 2) {
          _dniBackImage = pickedFile;
        } else {
          _faceImage = pickedFile;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_addressController.text.isEmpty || _phoneController.text.isEmpty || _dniImage == null || _dniBackImage == null || _faceImage == null) {
      Get.snackbar("Campos Incompletos", "Por favor, completa todos los datos y sube las 3 fotos requeridas.",
          backgroundColor: Colors.redAccent, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() => _isSubmitting = true);

    final String fullPhone = "${_countryPhoneCodes[_selectedCountryIso]}${_phoneController.text}";

    final success = await VerificationService.instance.submitVerification(
      address: _addressController.text,
      phone: fullPhone,
      dniFile: _dniImage!,
      dniBackFile: _dniBackImage!,
      faceFile: _faceImage!,
    );

    setState(() => _isSubmitting = false);

    if (success) {
      await _dashboardController.fetchVerificationStatus();
      Get.snackbar("Solicitud Enviada", "Tu documentación está en revisión. ¡Te avisaremos pronto!",
          backgroundColor: const Color(0xFF00FF88), colorText: Colors.black, snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar("Error de Envío", "Hubo un problema al subir tus documentos. Inténtalo de nuevo.",
          backgroundColor: Colors.redAccent, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D0F0E), Color(0xFF003300)], // Negro a Verde Oscuro (Estilo Embajadores X)
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Obx(() {
                  if (_dashboardController.isVerificationLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF00FF88)));
                  }

                  final isVerified = _dashboardController.isVerified.value == 1;
                  final request = _dashboardController.verificationRequestData;
                  final bool hasRequest = request.isNotEmpty && (request['exists'] == true || request['exists']?.toString() == '1' || request['exists']?.toString() == 'true');
                  final int requestStatus = int.tryParse(request['status']?.toString() ?? '0') ?? 0;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(25),
                    child: _buildContent(isVerified, hasRequest, requestStatus),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF00FF88), size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              "Verificación de Cuenta",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildContent(bool isVerified, bool hasRequest, int status) {
    if (isVerified) {
      return _buildSuccessState();
    }
    if (hasRequest && status == 0) {
      return _buildPendingState();
    }
    return _buildForm();
  }

  Widget _buildSuccessState() {
    return FadeInDown(
      child: Column(
        children: [
          const SizedBox(height: 50),
          const Icon(Icons.verified, color: Colors.blue, size: 100),
          const SizedBox(height: 30),
          const Text("¡CUENTA VERIFICADA!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 15),
          const Text(
            "¡Ya eres parte del grupo exclusivo de Embajadores X!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Tu perfil ahora cuenta con el Check de exclusividad. Disfruta de todos los beneficios de estar verificado.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 50),
          _buildFeatureRow(Icons.security, "Seguridad Prioritaria"),
          _buildFeatureRow(Icons.star, "Prestigio en Rankings"),
          _buildFeatureRow(Icons.support_agent, "Soporte VIP"),
        ],
      ),
    );
  }

  Widget _buildPendingState() {
    return FadeInUp(
      child: Column(
        children: [
          const SizedBox(height: 50),
          const Icon(Icons.history_edu_outlined, color: Colors.orangeAccent, size: 100),
          const SizedBox(height: 30),
          const Text("EN REVISIÓN",
              style: TextStyle(color: Colors.orangeAccent, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orangeAccent.withOpacity(0.2)),
            ),
            child: const Text(
              "Tu documentación ha sido recibida correctamente. Un administrador la verificará en las próximas 24-48 horas hábiles. ¡Mantente atento!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeInLeft(
          child: const Text("Solicitud de Check Azul",
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        const Text("Completa tus datos reales para obtener la verificación premium.",
            style: TextStyle(color: Colors.white38, fontSize: 13)),
        const SizedBox(height: 35),
        
        _buildTextField("Dirección de Residencia", Icons.location_on_outlined, _addressController),
        const SizedBox(height: 20),
        _buildPhoneField(), // Usar selector de país
        
        const SizedBox(height: 35),
        const Text("DOCUMENTACIÓN REQUERIDA",
            style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 20),
        
        _buildImagePicker(
            "Foto de DNI / Pasaporte (Frente)", 
            _dniImage, 
            () => _pickImage(1),
            "Sube una foto clara de tu identificación oficial."
        ),
        const SizedBox(height: 20),
        _buildImagePicker(
            "Foto de DNI / Pasaporte (Reverso)", 
            _dniBackImage, 
            () => _pickImage(2),
            "Sube una foto clara de la parte posterior de tu documento."
        ),
        const SizedBox(height: 20),
        _buildImagePicker(
            "Selfie con Documento", 
            _faceImage, 
            () => _pickImage(3),
            "Tómate una foto sosteniendo tu documento para verificar identidad."
        ),
        
        const SizedBox(height: 45),
        
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 10,
              shadowColor: const Color(0xFF00E676).withOpacity(0.5),
            ),
            child: _isSubmitting 
              ? const CircularProgressIndicator(color: Colors.black)
              : const Text("ENVIAR SOLICITUD AHORA", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38, fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF00E676), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 15),
            child: DropdownButton<String>(
              value: _selectedCountryIso,
              underline: const SizedBox(),
              dropdownColor: const Color(0xFF1E1E1E),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00E676)),
              items: _countryPhoneCodes.keys.map((String iso) {
                return DropdownMenuItem<String>(
                  value: iso,
                  child: Text(
                    "${_flagEmoji(iso)} ${_countryPhoneCodes[iso]}",
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCountryIso = val!;
                });
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: VerticalDivider(color: Colors.white10),
          ),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Número de Teléfono",
                hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(String label, XFile? image, VoidCallback onTap, String subtext) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: image != null ? const Color(0xFF00E676).withOpacity(0.5) : Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              height: 60, width: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                image: image != null ? DecorationImage(
                  image: kIsWeb 
                    ? NetworkImage(image.path) 
                    : FileImage(io.File(image.path)) as ImageProvider, 
                  fit: BoxFit.cover
                ) : null,
              ),
              child: image == null ? const Icon(Icons.camera_alt_outlined, color: Colors.white24) : null,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 5),
                  Text(subtext, style: const TextStyle(color: Colors.white24, fontSize: 11)),
                ],
              ),
            ),
            Icon(image != null ? Icons.check_circle : Icons.add_circle_outline, color: image != null ? const Color(0xFF00E676) : Colors.white24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF00E676), size: 18),
          const SizedBox(width: 15),
          Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
