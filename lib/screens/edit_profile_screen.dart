import 'package:ecoconnect/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

import '../widgets/main_back_button_widget.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String? name;
  String? email;
  String? createdAt;
  String? updatedAt;
  String? address;
  String? phoneNumber;
  String? epcgNaplatniBroj;
  String? epcgBrojBrojila;
  String? vodovodPretplatniBroj;

  bool isLoading = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _epcgNaplatniBrojController =
      TextEditingController();
  final TextEditingController _epcgBrojBrojilaController =
      TextEditingController();
  final TextEditingController _vodovodPretplatniBrojController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    final userId = prefs.getString('user_id');

    if (authToken != null && userId != null) {
      final url = Uri.parse('https://lukamasulovic.site/api/users/$userId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          name = data['data']['user']['name'];
          email = data['data']['user']['email'];
          createdAt = data['data']['user']['created_at'];
          updatedAt = data['data']['user']['updated_at'];
          address = data['data']['user']['address'];
          phoneNumber = data['data']['user']['phone_number'];
          epcgNaplatniBroj = data['data']['user']['epcg_naplatni_broj'];
          epcgBrojBrojila = data['data']['user']['epcg_broj_brojila'];
          vodovodPretplatniBroj =
              data['data']['user']['vodovod_pretplatni_broj'];

          _nameController.text = name ?? '';
          _emailController.text = email ?? '';
          _addressController.text = address ?? '';
          _phoneController.text = phoneNumber ?? '';
          _epcgNaplatniBrojController.text = epcgNaplatniBroj ?? '';
          _epcgBrojBrojilaController.text = epcgBrojBrojila ?? '';
          _vodovodPretplatniBrojController.text = vodovodPretplatniBroj ?? '';

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _epcgNaplatniBrojController.dispose();
    _epcgBrojBrojilaController.dispose();
    _vodovodPretplatniBrojController.dispose();
    super.dispose();
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    final userId = prefs.getString('user_id');

    if (authToken != null && userId != null) {
      final url = Uri.parse('https://lukamasulovic.site/api/users/$userId');
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': _nameController.text,
          'email': _emailController.text,
          'address': _addressController.text,
          'phone_number': _phoneController.text,
          'epcg_naplatni_broj': _epcgNaplatniBrojController.text,
          'epcg_broj_brojila': _epcgBrojBrojilaController.text,
          'vodovod_pretplatni_broj': _vodovodPretplatniBrojController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Podaci su uspešno ažurirani!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Došlo je do greške. Pokušajte ponovo.')),
        );
      }
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
                        decorationColor: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 10),
                    isLoading
                        ? CircularProgressIndicator()
                        : Column(
                            children: [
                              CustomTextField(
                                controller: _nameController,
                                label: 'Ime i prezime',
                              ),
                              const SizedBox(height: 5),
                              CustomTextField(
                                controller: _emailController,
                                label: 'Email',
                              ),
                              const SizedBox(height: 5),
                              CustomTextField(
                                controller: _addressController,
                                label: 'Adresa',
                              ),
                              const SizedBox(height: 5),
                              CustomTextField(
                                controller: _phoneController,
                                label: 'Broj telefona',
                              ),
                              const SizedBox(height: 5),
                              CustomTextField(
                                controller: _epcgNaplatniBrojController,
                                label: 'EPCG Naplatni broj',
                              ),
                              const SizedBox(height: 5),
                              CustomTextField(
                                controller: _epcgBrojBrojilaController,
                                label: 'EPCG Broj brojila',
                              ),
                              const SizedBox(height: 5),
                              CustomTextField(
                                controller: _vodovodPretplatniBrojController,
                                label: 'Vodovod Pretplatni Broj',
                              ),
                              const SizedBox(height: 20),
                              CustomButton(
                                text: 'Ažuriraj profil',
                                onPressed: _saveUserData,
                              ),
                            ],
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
