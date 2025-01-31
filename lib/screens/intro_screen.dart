import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/intro_text.dart';
import '../widgets/background_image.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class IntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundImage(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const IntroText(),
                CustomButton(
                  text: 'Registracija',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Prijava',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
