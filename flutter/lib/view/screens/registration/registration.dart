import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:affiliatepro_mobile/utils/text.dart';
import 'package:http/http.dart' as http;
import 'package:affiliatepro_mobile/view/screens/login/login.dart';
import '../login/tech_background.dart';
import '../../../controller/login_controller.dart';
import '../../../utils/colors.dart';
import '../../../utils/images.dart';
import '../../base/custom_loader.dart';
import '../../base/custom_text_field.dart';
import '/service/api_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  List<Map<String, dynamic>> formFields = [];
  bool loading = true;
  bool TandCAccepted = true;
  int isVendor = 0; // 0 = Affiliate, 1 = Vendor
  bool isControllerReady = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initDependencies();
    _getRegistrationForm();
  }

  void _initDependencies() async {
    if (!Get.isRegistered<LoginController>()) {
      final prefs = await SharedPreferences.getInstance();
      Get.put(LoginController(preferences: prefs), permanent: true);
    }
    if (mounted) {
      setState(() {
        isControllerReady = true;
      });
    }
  }

  void _getRegistrationForm() async {
    final response = await http.get(
      Uri.parse('${ApiService.instance.baseUrl}user/get_registration_form'),
    );
    if (response.statusCode == 200) {
      setState(() {
        formFields = List<Map<String, dynamic>>.from(
          json.decode(response.body)['data'],
        );
        print(formFields);
      });
    } else {
      print('Error fetching form fields');
    }
    setState(() {
      loading = false;
    });
  }

  stringToController(label, LoginController loginController) {
    switch (label) {
      case 'Firstname':
        return loginController.firstNameController;
      case 'Lastname':
        return loginController.lastNameController;
      case 'Email':
        return loginController.emailController;
      case 'Mobile Phone':
        return loginController.phoneNumberController;
      case 'Username':
        return loginController.userNameController;
      case 'Password':
        return loginController.passwordController;
      case 'Confirm_password':
        return loginController.ConfirmPasswordController;
      default:
        return loginController.firstNameController;
    }
  }

  stringToHintText(label) {
    switch (label) {
      case 'Firstname':
        return AppText.fName;
      case 'Lastname':
        return AppText.lName;
      case 'Email':
        return AppText.email;
      case 'Mobile Phone':
        return AppText.pNumber;
      case 'Username':
        return AppText.userName;
      case 'Password':
        return AppText.password;
      case 'Confirm_password':
        return AppText.ConfirmPassword;
      default:
        return AppText.fName;
    }
  }

  stringToKeyboardType(label) {
    switch (label) {
      case 'Firstname':
        return TextInputType.name;
      case 'Lastname':
        return TextInputType.name;
      case 'Email':
        return TextInputType.emailAddress;
      case 'Mobile Phone':
        return TextInputType.phone;
      case 'Username':
        return TextInputType.name;
      case 'Password':
        return TextInputType.name;
      case 'Confirm_password':
        return TextInputType.name;

      default:
        return TextInputType.name;
    }
  }

  stringToValidator(label, LoginController loginController) {
    switch (label) {
      case 'Firstname':
        return (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese el Nombre';
          }
          return null;
        };
      case 'Lastname':
        return (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese el Apellido';
          }
          return null;
        };
      case 'Email':
        return (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese el Correo';
          } else if (!RegExp(
                  r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
                  r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
                  r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
                  r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
                  r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
                  r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
                  r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])')
              .hasMatch(value)) {
            return 'Por favor ingrese un Correo válido';
          }
          return null;
        };
      case 'Mobile Phone':
        return (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese el Teléfono';
          }
          return null;
        };
      case 'Username':
        return (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese el Usuario';
          }
          return null;
        };
      case 'Password':
        return (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese la Contraseña';
          }
          return null;
        };
      case 'Confirm_password':
        return (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese la Contraseña';
          }
          if (loginController.ConfirmPasswordController.text !=
              loginController.passwordController.text) {
            return 'Las contraseñas no coinciden';
          }
          return null;
        };
      default:
        return (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese la Contraseña';
          }
          return null;
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    if (!isControllerReady) {
      return const Scaffold(
        body: Center(child: CustomLoader()),
      );
    }

    return GetBuilder<LoginController>(builder: (loginController) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Tech Background
            const Positioned.fill(
              child: TechBackground(),
            ),
            
            // Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppText.createAccount,
                          style: TextStyle(
                            fontSize: height * 0.03,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 10),
                        loading
                            ? const Center(child: CustomLoader())
                            : Form(
                                key: _formKey,
                                child: ListView.builder(
                                  itemCount: formFields.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final field = formFields[index];
                                    return field['label'] == 'Text Area'
                                        ? Container()
                                        : Column(
                                            children: [
                                              SizedBox(height: height * 0.02),
                                              CustomTextField(
                                                textEditingController:
                                                    stringToController(field['label'],
                                                        loginController),
                                                hintText:
                                                    stringToHintText(field['label']),
                                                textInputType: stringToKeyboardType(
                                                    field['label']),
                                                type: 3, // New Dark Theme type for Registration
                                                validator: stringToValidator(
                                                    field['label'], loginController),
                                              ),
                                            ],
                                          );
                                  },
                                ),
                              ),
                        // Inyección manual del campo "Nombre de tu tienda" al final del formulario para PROVEEDOR
                        if (isVendor == 1)
                          Column(
                            children: [
                              SizedBox(height: height * 0.02),
                              CustomTextField(
                                textEditingController: loginController.storeNameController,
                                hintText: 'Ingresa el nombre de tu tienda',
                                textInputType: TextInputType.text,
                                type: 3,
                                validator: (value) {
                                  if (isVendor == 1 && (value == null || value.isEmpty)) {
                                    return 'Por favor ingrese el nombre de la tienda';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tipo de Cuenta',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => isVendor = 0),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        decoration: BoxDecoration(
                                          color: isVendor == 0 ? const Color(0xFF00FF88) : Colors.transparent,
                                          border: Border.all(color: isVendor == 0 ? const Color(0xFF00FF88) : Colors.white24),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Afiliado',
                                            style: TextStyle(
                                              color: isVendor == 0 ? Colors.black : Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => isVendor = 1),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        decoration: BoxDecoration(
                                          color: isVendor == 1 ? const Color(0xFF00FF88) : Colors.transparent,
                                          border: Border.all(color: isVendor == 1 ? const Color(0xFF00FF88) : Colors.white24),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Proveedor',
                                            style: TextStyle(
                                              color: isVendor == 1 ? Colors.black : Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Theme(
                          data: Theme.of(context).copyWith(
                            unselectedWidgetColor: Colors.white24,
                            checkboxTheme: CheckboxThemeData(
                              fillColor: WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) return const Color(0xFF00FF88);
                                return Colors.transparent;
                              }),
                              side: const BorderSide(color: Colors.white24),
                            ),
                          ),
                          child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(AppText.acceptTandC,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white70,
                                  fontSize: 13,
                                )),
                            value: loginController.terms,
                            onChanged: (value) {
                              setState(() {
                                loginController.terms = value!;
                              });
                            },
                          ),
                        ),
                        Visibility(
                          visible: !TandCAccepted,
                          child: const Center(
                            child: Text('Por favor acepta los términos',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.redAccent,
                                  fontSize: 12,
                                )),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: loginController.isLoading
                              ? const Center(child: CustomLoader())
                              : ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      TandCAccepted = true;
                                    });
                                    if (loginController.terms) {
                                      loginController.registerUser(context, isVendor, _formKey);
                                    } else {
                                      setState(() {
                                        TandCAccepted = false;
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: const Color(0xFF00FF88),
                                    elevation: 0,
                                  ),
                                  child: Text(AppText.registration,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black)),
                                ),
                        ),
                        SizedBox(height: height * 0.03),
                        RichText(
                          text: TextSpan(
                            text: AppText.alreadyAccount,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontFamily: 'Poppins',
                              fontSize: 14,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                  text: " ${AppText.loginNow}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00FF88),
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.of(context)
                                          .pushReplacement(MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
                                      ));
                                    }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
