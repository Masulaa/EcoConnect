import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
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

  double costPerKWh = 0.0971;
  double maxKWhPerDay = 24 * 1.0;

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://lukamasulovic.site/epcg?pretplatniBroj=152577011&brojBrojila=18N4E5B2514906007'));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      double invoiceAmount = double.parse(data['poslednji_racun']['iznos']
          .replaceAll(' €', '')
          .replaceAll(',', '.'));

      double totalKWhUsed = invoiceAmount / costPerKWh;

      int daysInMonth = 30;
      int hoursInMonth = daysInMonth * 24;
      double averageUsagePerDay = totalKWhUsed / daysInMonth;

      int daysUsed = (totalKWhUsed / averageUsagePerDay).floor();
      double remainingKWh = totalKWhUsed - (daysUsed * averageUsagePerDay);
      int hoursUsed = (remainingKWh / 1.0).floor();

      double maxKWhForMonth = maxKWhPerDay * daysInMonth;

      setState(() {
        kwhConsumption = totalKWhUsed.toStringAsFixed(2) + ' kW/h';
        usageTime = '$daysUsed dana, $hoursUsed sati';
        totalDue = data['ukupno_za_uplatu'] ?? 'Nije dostupno';
        previousDebt = data['prethodni_dug'] ?? 'Nije dostupno';
        lastInvoiceDate = data['poslednji_racun']['datum'] ?? 'Nije dostupno';
        lastInvoiceAmount = data['poslednji_racun']['iznos'] ?? 'Nije dostupno';
      });

      print('Max KWh for month: $maxKWhForMonth');
      print('Days used: $daysUsed, Hours used: $hoursUsed');
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
                    //_buildDataCard('Ukupno vrijeme potrošnje:', usageTime),
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
