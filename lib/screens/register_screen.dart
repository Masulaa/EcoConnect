import 'package:flutter/material.dart';
import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registracija')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(decoration: InputDecoration(labelText: 'Ime')),
            TextFormField(decoration: InputDecoration(labelText: 'Prezime')),
            TextFormField(decoration: InputDecoration(labelText: 'E-mail adresa')),
            TextFormField(obscureText: true, decoration: InputDecoration(labelText: 'Lozinka')),
            TextFormField(obscureText: true, decoration: InputDecoration(labelText: 'Potvrdi lozinku')),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('Već imate nalog? Prijavite se', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Text('Registrujte se'),
            ),
          ],
        ),
      ),
    );
  }
}

