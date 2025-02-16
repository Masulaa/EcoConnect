import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/main_back_button_widget.dart';

class PowerConsumptionScreen extends StatefulWidget {
  @override
  _PowerConsumptionScreenState createState() => _PowerConsumptionScreenState();
}

class _PowerConsumptionScreenState extends State<PowerConsumptionScreen> {
  String kwhConsumption = 'Učitavanje...';
  String usageTime = 'Učitavanje...';
  String totalDue = 'Učitavanje...';
  String previousDebt = 'Učitavanje...';
  String lastInvoiceDate = 'Učitavanje...';
  String lastInvoiceAmount = '';

  double averageCostPerKWh = 0.89;
  double averageUsagePerHour = 0.5;

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://lukamasulovic.site/epcg?pretplatniBroj=152577011&brojBrojila=18N4E5B2514906007'));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      
      double invoiceAmount = double.parse(data['poslednji_racun']['iznos'].replaceAll(' €', '').replaceAll(',', '.'));
      setState(() {
        kwhConsumption = (invoiceAmount / averageCostPerKWh).toStringAsFixed(2) + ' kW/h';

        double usageTimeInHours = (invoiceAmount / averageCostPerKWh) / averageUsagePerHour;

        int days = (usageTimeInHours / 24).floor();
        int hours = (usageTimeInHours % 24).floor();
        //int minutes = ((usageTimeInHours - hours) * 60).toInt();

        usageTime = '$days dana, $hours sati' /*$minutes minutes'*/;

        totalDue = data['ukupno_za_uplatu'] ?? 'Not Available';
        previousDebt = data['prethodni_dug'] ?? 'Not Available';
        lastInvoiceDate = data['poslednji_racun']['datum'] ?? 'Not Available';
        lastInvoiceAmount = data['poslednji_racun']['iznos'] ?? 'Not Available';
      });
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
                      'Potrošnja struje',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1B5E20),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildDataCard('Količina potrošnje:', kwhConsumption),
                    _buildDataCard('Ukupno vrijeme potrošnje:', usageTime),
                    _buildDataCard('Ukupno dugovanje za struju:', totalDue),
                    _buildDataCard('Prethodni dug:', previousDebt),
                    _buildDataCard('Posljednji račun:', '$lastInvoiceDate - $lastInvoiceAmount'),
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
