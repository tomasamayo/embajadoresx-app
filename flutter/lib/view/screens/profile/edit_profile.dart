import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:affiliatepro_mobile/view/base/custom_text_field.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controller/login_controller.dart';
import '../../../utils/colors.dart';
import '../../../utils/text.dart';
import '../../base/custom_loader.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class EditProfile extends StatefulWidget {
  var image;
  EditProfile({super.key, required this.image});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final formKey = GlobalKey<FormState>();
  File? _image;

  Future<void> _getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      img.Image? image = img.decodeImage(file.readAsBytesSync());
      img.Image resizedImage = img.copyResize(image!, width: 128, height: 128);
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    Get.find<LoginController>();
    return GetBuilder<LoginController>(builder: (loginController) {
      return Scaffold(
        backgroundColor: AppColor.dashboardBgColor,
        appBar: AppBar(
          foregroundColor: AppColor.appWhite,
          backgroundColor: AppColor.dashboardBgColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            "Editar Cuenta",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Form(
              // Add Form
              key: formKey,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  SizedBox(height: height * 0.03),
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColor.appPrimaryLight,
                            backgroundImage: _image != null
                                ? FileImage(_image!)
                                : NetworkImage(widget.image) as ImageProvider,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _getImageFromGallery,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColor.appPrimary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.black, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.04),
                  
                  // DATOS PERSONALES Section
                  const Text(
                    "DATOS PERSONALES",
                    style: TextStyle(
                      color: AppColor.appPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    textEditingController: loginController.firstNameController,
                    hintText: AppText.fName,
                    textInputType: TextInputType.name,
                    type: 2,
                    prefixIcon: Icons.person_outline,
                  ),
                  SizedBox(height: height * 0.02),
                  CustomTextField(
                    textEditingController: loginController.lastNameController,
                    hintText: AppText.lName,
                    textInputType: TextInputType.name,
                    type: 2,
                    prefixIcon: Icons.person_outline,
                  ),
                  SizedBox(height: height * 0.02),
                  CustomTextField(
                    textEditingController: loginController.emailController,
                    hintText: AppText.email,
                    type: 2,
                    textInputType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                  ),
                  SizedBox(height: height * 0.02),
                  CustomTextField(
                    textEditingController:
                        loginController.phoneNumberController,
                    hintText: AppText.pNumber,
                    type: 2,
                    textInputType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                  ),
                  
                  SizedBox(height: height * 0.04),

                  // SEGURIDAD Section
                  const Text(
                    "SEGURIDAD",
                    style: TextStyle(
                      color: AppColor.appPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    textEditingController: loginController.userNameController,
                    hintText: AppText.userName,
                    type: 2,
                    textInputType: TextInputType.name,
                    readOnly: true,
                    prefixIcon: Icons.lock_outline,
                  ),
                  SizedBox(height: height * 0.02),
                  CustomTextField(
                    textEditingController: loginController.passwordController,
                    hintText: "Nueva Contraseña", // Changed to match image text
                    obscureText: true,
                    type: 2,
                    prefixIcon: Icons.lock_outline,
                  ),
                  
                  SizedBox(height: height * 0.05),
                  
                  SizedBox(
                    width: double.infinity,
                    child: loginController.isLoading
                        ? const Center(child: CustomLoader())
                        : ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                loginController.updateProfile(context,
                                    imageFile: _image);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.appPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                              shadowColor: AppColor.appPrimary.withOpacity(0.4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.save_outlined, color: Colors.black),
                                const SizedBox(width: 10),
                                Text(
                                  "Guardar Cambios",
                                  style: TextStyle(
                                    fontSize: width * 0.042,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black, // Dark text on green button for contrast
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  SizedBox(height: height * 0.05),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
