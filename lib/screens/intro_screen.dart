import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class IntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('EcoConnect', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(seconds: 1),
              child: Column(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text('Prijava', style: TextStyle(fontSize: 20)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterScreen()),
                      );
                    },
                    child: Text('Registracija', style: TextStyle(fontSize: 20)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
