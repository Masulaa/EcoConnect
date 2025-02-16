import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/main_back_button_widget.dart';

class WaterConsumptionScreen extends StatefulWidget {
  @override
  _WaterConsumptionScreenState createState() => _WaterConsumptionScreenState();
}

class _WaterConsumptionScreenState extends State<WaterConsumptionScreen> {
  String waterConsumption = 'Učitavanje...';
  String sewerageConsumption = 'Učitavanje...';
  String totalDue = 'Učitavanje...';
  String lastInvoiceAmount = 'Učitavanje...';
  String consumerName = 'Učitavanje...';

  Map<String, double> waterRates = {
    'First': 1.330,
    'Second A': 1.146,
    'Second B': 0.405,
  };

  Map<String, double> sewerageRates = {
    'First': 0.665, 
    'Second A': 0.573, 
    'Second B': 0.202, 
  };

  String consumerCategory = 'Second B';

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://lukamasulovic.site/vodovod_niksic?pretplatniBroj=222210'));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      
      double totalCharge = double.parse(data['zaduzenje'].replaceAll('€', '').trim());
      double lastInvoice = double.parse(data['poslednji_racun'].replaceAll('€', '').trim());
      String name = data['ime'];

      double waterUsed = totalCharge / waterRates[consumerCategory]!;
      double sewerageUsed = waterUsed * (sewerageRates[consumerCategory]! / waterRates[consumerCategory]!);

      setState(() {
        waterConsumption = waterUsed.toStringAsFixed(2) + ' m³';
        sewerageConsumption = sewerageUsed.toStringAsFixed(2) + ' m³';
        totalDue = '$totalCharge €';
        lastInvoiceAmount = '$lastInvoice €';
        consumerName = name;
      });

      print('Water Used: $waterUsed m³');
      print('Sewerage Used: $sewerageUsed m³');
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
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
                      'Potrošnja vode',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1B5E20),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(height: 40),
                    //_buildDataCard('Ime korisnika:', consumerName),
                    _buildDataCard('Količina potrošnje vode:', waterConsumption),
                    _buildDataCard('Količina otpadnih voda:', sewerageConsumption),
                    _buildDataCard('Ukupno dugovanje:', totalDue),
                    _buildDataCard('Posljednji račun:', lastInvoiceAmount),
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

  Widget _buildDataCard(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Card(
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.1),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          subtitle: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
