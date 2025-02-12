import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isPassword;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.isPassword = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth * 0.8;
          double height = 54.0;
          
          if (width < 245) {
            width = 245;
          }

          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xCC1B5E20),
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextFormField(
              controller: controller,
              obscureText: isPassword,
              keyboardType: isPassword ? TextInputType.text : TextInputType.emailAddress,
              validator: validator,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16.0),
              ),
            ),
          );
        },
      ),
    );
  }
}
