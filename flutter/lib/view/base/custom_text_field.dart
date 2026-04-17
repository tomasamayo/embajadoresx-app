import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController textEditingController;
  final int? maxLines;
  final String? hintText;
  final bool? obscureText;
  final int? type;
  final TextInputType? textInputType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final Widget? suffixIcon;
  final IconData? prefixIcon;

  const CustomTextField({
    super.key,
    required this.textEditingController,
    this.maxLines,
    this.obscureText,
    this.textInputType,
    required this.type,
    this.hintText = 'Describe your post',
    this.validator,
    this.inputFormatters,
    this.readOnly = false,
    this.suffixIcon,
    this.prefixIcon,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late final FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!mounted) return;
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<TextInputFormatter>? formatters = widget.inputFormatters;
    if (widget.textInputType == TextInputType.phone) {
      formatters = [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9\s\-+()]')),
      ];
    }

    String? defaultValidator(String? value) {
      if (widget.textInputType == TextInputType.phone) {
        if (value == null || value.isEmpty) {
          return 'Phone number is required';
        }
        String digitsOnly = value.replaceAll(RegExp(r'[\s\-+()]'), '');
        if (digitsOnly.length < 10) {
          return 'Phone number must be at least 10 digits';
        }
        if (digitsOnly.length > 15) {
          return 'Phone number is too long';
        }
        String pattern = r'^\+?[0-9\s-()]+$';
        RegExp regex = RegExp(pattern);
        if (!regex.hasMatch(value)) {
          return 'Please enter a valid phone number';
        }
      }
      return null;
    }

    final isNeon = widget.type == 2 || widget.type == 3;
    const defaultBorderColor = Color(0xFF3A3A3A);
    const neonGreen = Color(0xFF00FF88);
    final borderRadius = isNeon ? BorderRadius.circular(10) : BorderRadius.circular(20);

    final enabledBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(color: defaultBorderColor, width: 1),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(color: neonGreen, width: 1.5),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.type == 2
            ? const Color(0xFF0B0B0F)
            : (widget.type == 3 ? const Color(0xFF0B0B0F) : AppColor.appPrimaryLight),
        borderRadius: borderRadius,
        border: isNeon
            ? null
            : Border.all(
                color: AppColor.appWhite,
                width: 1,
              ),
        boxShadow: isNeon && _hasFocus
            ? [
                BoxShadow(
                  color: neonGreen.withOpacity(0.25),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: TextFormField(
        focusNode: _focusNode,
        maxLines: widget.maxLines ?? 1,
        obscureText: widget.obscureText ?? false,
        controller: widget.textEditingController,
        keyboardType: widget.textInputType,
        inputFormatters: formatters,
        readOnly: widget.readOnly,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: isNeon ? enabledBorder : InputBorder.none,
          enabledBorder: isNeon ? enabledBorder : InputBorder.none,
          focusedBorder: isNeon ? focusedBorder : InputBorder.none,
          errorBorder: isNeon
              ? enabledBorder.copyWith(
                  borderSide: const BorderSide(color: Colors.redAccent, width: 1),
                )
              : InputBorder.none,
          focusedErrorBorder: isNeon
              ? focusedBorder.copyWith(
                  borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                )
              : InputBorder.none,
          suffixIcon: widget.suffixIcon,
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon, color: AppColor.appGrey)
              : null,
          counterStyle: const TextStyle(fontSize: 0),
          hintText: widget.hintText,
          errorStyle: const TextStyle(color: Colors.redAccent),
          hintStyle: TextStyle(
            color: isNeon ? Colors.white54 : AppColor.appGrey.withOpacity(0.5),
            fontFamily: 'Poppins',
          ),
        ),
        validator: widget.validator ?? defaultValidator,
        style: TextStyle(
            color: isNeon ? Colors.white : (widget.type == 1 ? AppColor.appBlack : AppColor.appWhite),
            fontFamily: 'Poppins'),
      ),
    );
  }
}
