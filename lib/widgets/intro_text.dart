import 'package:flutter/material.dart';

class IntroText extends StatelessWidget {
  const IntroText({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Column(
      children: [
        SizedBox(height: 1),
        Image.asset(
          'assets/logo.png',
          width: 160,
          height: 160,
        ),
        SizedBox(height: 1),
        Text(
          'EcoConnect',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 40,
            color: const Color(0xFF1B5E20),
            decoration: TextDecoration.underline,
          ),
        ),
        SizedBox(height: 1),
        Text(
          'Vaš digitalni kompas',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 20,
            color: const Color(0xFF1B5E20),
          ),
        ),
      ],
    );
  }
}
