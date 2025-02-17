import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/main_back_button_widget.dart';

class EditProfileScreen extends StatefulWidget {
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
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    
    if (userId != null) {
      setState(() {
        _userId = int.tryParse(userId);
      });
      await _fetchUserData();
    }
  }

  Future<void> _fetchUserData() async {
    if (_userId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nema pristupnog tokena!')),
      );
      return;
    }

    final String apiUrl = 'https://lukamasulovic.site/api/users/$_userId';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body)['data']['user'];

        setState(() {
          _name = userData['name'] ?? '';
          _email = userData['email'] ?? '';
          _address = userData['address'] ?? '';
          _phoneNumber = userData['phone_number'] ?? '';
          _epcgNaplatniBroj = userData['epcg_naplatni_broj'] ?? '';
          _epcgBrojBrojila = userData['epcg_broj_brojila'] ?? '';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška pri dohvaćanju podataka!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška u povezivanju sa serverom!')),
      );
    }
  }

  Future<void> _updateProfile() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nema spremljenog user_id!')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nema pristupnog tokena!')),
      );
      return;
    }

    final String apiUrl = 'https://lukamasulovic.site/api/users/$_userId';

    try {
      final response = await http.put(
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
                        initialValue: _name,
                        decoration: InputDecoration(labelText: 'Ime'),
                        onChanged: (value) => _name = value,
                      ),
                      TextFormField(
                        initialValue: _email,
                        decoration: InputDecoration(labelText: 'Email'),
                        onChanged: (value) => _email = value,
                      ),
                      TextFormField(
                        initialValue: _password,
                        decoration: InputDecoration(labelText: 'Lozinka'),
                        onChanged: (value) => _password = value,
                      ),
                      TextFormField(
                        initialValue: _address,
                        decoration: InputDecoration(labelText: 'Adresa'),
                        onChanged: (value) => _address = value,
                      ),
                      TextFormField(
                        initialValue: _phoneNumber,
                        decoration: InputDecoration(labelText: 'Telefon'),
                        onChanged: (value) => _phoneNumber = value,
                      ),
                      TextFormField(
                        initialValue: _epcgNaplatniBroj,
                        decoration: InputDecoration(labelText: 'Naplatni broj EPCG'),
                        onChanged: (value) => _epcgNaplatniBroj = value,
                      ),
                      TextFormField(
                        initialValue: _epcgBrojBrojila,
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

