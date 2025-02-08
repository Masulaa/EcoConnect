import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'login_screen.dart';
import '../widgets/background_image.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/intro_text.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final email = _emailController.text;
      final password = _passwordController.text;

      try {
        final apiUrl = dotenv.env['API_URL'] ?? 'https://ecoconnect.cortexakademija.com/api';

        final response = await http.post(
          Uri.parse('$apiUrl/register'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'name': name,
            'email': email,
            'password': password,
            'password_confirmation': password,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registracija uspјešna! Dobrodošli, ${responseData['data']['user']['name']}')),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else {
          final responseData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Greška: ${responseData['message']}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška u povezivanju sa serverom.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registracija')),
      body: Stack(
        children: [
          const BackgroundImage(),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CustomTextField(
                      controller: _nameController,
                      label: 'Ime',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ime je obavezno';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: _emailController,
                      label: 'E-mail adresa',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'E-mail je obavezan';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Unesite validan e-mail';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Lozinka',
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lozinka je obavezna';
                        }
                        if (value.length < 6) {
                          return 'Lozinka mora imati najmanje 6 karaktera';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: 'Potvrdite lozinku',
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Potvrda lozinke je obavezna';
                        }
                        if (value != _passwordController.text) {
                          return 'Lozinke se ne poklapaju';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Registrujte se',
                      onPressed: _register,
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                      },
                      child: const Text('Već imate nalog? Prijavite se', style: 
                        TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFF1B5E20),
                          height: 24 / 16,
                        )
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
