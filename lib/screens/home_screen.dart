import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 40),
          // Logo i naslov
          Center(
            child: Column(
              children: [
                Image.asset('assets/logo.png', height: 60),
                const SizedBox(height: 1),
                const Text(
                  'Dashboard',
                  style: TextStyle(
                     fontFamily: 'Poppins',
                    fontSize: 40,
                           fontWeight: FontWeight.w900,
            color: const Color(0xFF1B5E20),
            decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ])
    );
  }

  
}