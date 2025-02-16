import 'package:flutter/material.dart';
import '../../widgets/main_back_button_widget.dart';

class WaterConsumptionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Image.asset('assets/logo.png', height: 60),
                    const SizedBox(height: 1),
                    const Text(
                      'Potrošnja vode',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1B5E20),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          MainBackButtonWidget(size: 38, color: Colors.black),
        ],
      ),
    );
  }
}
