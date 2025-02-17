import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/main_back_button_widget.dart';

class EditProfileScreen extends StatefulWidget {
  final int userId;

  EditProfileScreen({required this.userId});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';
  String _address = '';
  String _phoneNumber = '';
  String _epcgNaplatniBroj = '';
  String _epcgBrojBrojila = '';

  Future<void> _updateProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nema pristupnog tokena!')),
      );
      return;
    }

    final String apiUrl = 'https://lukamasulovic.site/api/users/${widget.userId}';

    try {
      final response = await http.patch(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': _name,
          'email': _email,
          'password': _password,
          'address': _address,
          'phone_number': _phoneNumber,
          'epcg_naplatni_broj': _epcgNaplatniBroj,
          'epcg_broj_brojila': _epcgBrojBrojila,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil je uspješno ažuriran')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška pri ažuriranju profila!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška u povezivanju sa serverom!')),
      );
    }
  }

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
                      'Vaš profil',
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Ime'),
                        onChanged: (value) => _name = value,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Email'),
                        onChanged: (value) => _email = value,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Lozinka'),
                        onChanged: (value) => _password = value,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Adresa'),
                        onChanged: (value) => _address = value,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Telefon'),
                        onChanged: (value) => _phoneNumber = value,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Naplatni broj EPCG'),
                        onChanged: (value) => _epcgNaplatniBroj = value,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Broj brojila EPCG'),
                        onChanged: (value) => _epcgBrojBrojila = value,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _updateProfile,
                        child: Text('Ažuriraj profil'),
                      ),
                    ],
                  ),
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
