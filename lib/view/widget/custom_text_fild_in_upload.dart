import 'package:CookEasy/constants/colors.dart';
import 'package:flutter/material.dart';

class CustomTextFildInUpload extends StatelessWidget {
  CustomTextFildInUpload({
    Key? key,
    required this.hint,
    this.suffixIcon,
    this.onTapSuffixIcon,
    this.obscureText = false,
    this.maxLines = 1,
    this.radius = 10.0,
    this.icon,
    this.controller,
    this.suffixText, // Añadido
  }) : super(key: key);

  final String hint;
  final IconData? icon;
  final IconData? suffixIcon;
  final VoidCallback? onTapSuffixIcon;
  final bool obscureText;
  final int? maxLines;
  final double radius;
  final TextEditingController? controller;
  final String? suffixText; // Añadido

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(color: outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(color: outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(color: primary),
          ),
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: "Inter",
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: icon != null ? Icon(icon, color: mainText, size: 20) : null,
          suffixIcon: suffixIcon != null
              ? IconButton(
                  icon: Icon(suffixIcon, color: mainText, size: 20),
                  onPressed: onTapSuffixIcon,
                )
              : suffixText != null // Añadido
                  ? Text(
                      suffixText!,
                      style: const TextStyle(
                        fontFamily: "Inter",
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : null,
        ),
      ),
    );
  }
}