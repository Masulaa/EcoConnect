import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/background_image.dart';
import '../widgets/intro_text.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import '../widgets/back_button_widget.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;

      try {
        final apiUrl = dotenv.env['API_URL'] ?? 'https://lukamasulovic.site/api';

        final response = await http.post(
          Uri.parse('$apiUrl/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': email,
            'password': password,
          }),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final token = responseData['data']['token'];
          final userId = responseData['data']['user']['id'].toString();

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          await prefs.setString('user_id', userId);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Prijava je uspješna! Dobrodošli, ${responseData['data']['user']['name']}')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          final responseData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Greška: ${responseData['message']}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Greška u povezivanju sa serverom.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundImage(),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const IntroText(),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                      CustomTextField(
                        controller: _emailController,
                        label: 'E-mail adresa',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Unesite e-mail adresu';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Unesite validnu e-mail adresu';
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
                            return 'Unesite lozinku';
                          }
                          if (value.length < 6) {
                            return 'Lozinka mora imati najmanje 6 karaktera';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        text: 'Prijavite se',
                        onPressed: _login,
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RegisterScreen()),
                          );
                        },
                        child: const Text(
                          'Nemate nalog? Registrujte se',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color(0xFF1B5E20),
                            height: 24 / 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          BackButtonWidget(),
        ],
      ),
    );
  }
}
