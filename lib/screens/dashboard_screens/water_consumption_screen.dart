import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/main_back_button_widget.dart';
import 'package:fl_chart/fl_chart.dart';

class WaterConsumptionScreen extends StatefulWidget {
  @override
  _WaterConsumptionScreenState createState() => _WaterConsumptionScreenState();
}

class _WaterConsumptionScreenState extends State<WaterConsumptionScreen> {
  String waterConsumption = '...';
  String sewerageConsumption = '...';
  String totalDue = '...';
  String lastInvoiceAmount = '...';
  String consumerName = '...';

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

  // Pomoćna funkcija za parsiranje stringa u double
  double parseValue(String value, {String remove = ''}) {
    if (value == '...') return 0.0;
    String processed = value;
    if (remove.isNotEmpty) {
      processed = processed.replaceAll(remove, '');
    }
    // Ukloni eventualni simbol evra i zamijeni zarez točkom
    processed = processed.replaceAll(' €', '').replaceAll(',', '.');
    double? result = double.tryParse(processed);
    return result ?? 0.0;
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://lukamasulovic.site/vodovod_niksic?pretplatniBroj=222210'));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      double totalCharge =
          double.parse(data['zaduzenje'].replaceAll('€', '').trim());
      double lastInvoice =
          double.parse(data['poslednji_racun'].replaceAll('€', '').trim());
      String name = data['ime'];

      double waterUsed = totalCharge / waterRates[consumerCategory]!;
      double sewerageUsed = waterUsed *
          (sewerageRates[consumerCategory]! / waterRates[consumerCategory]!);

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
                    const SizedBox(height: 20),
                    _buildChart(),
                    const SizedBox(height: 40),
                    //_buildDataCard('Ime korisnika:', consumerName),
                    _buildDataCard(
                        'Količina potrošnje vode:', waterConsumption),
                    _buildDataCard(
                        'Količina otpadnih voda:', sewerageConsumption),
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

  Widget _buildChart() {
    // Parsiramo vrijednosti za grafikon:
    double totalDueValue = parseValue(totalDue);
    double previousDebtValue = parseValue(lastInvoiceAmount);
    double kwhValue = parseValue(sewerageConsumption);

    return Container(
      width: 297,
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFD3E0D4), // Prva boja: #D3E0D4
            Color(0xFFF8FAF8), // Druga boja: #F8FAF8
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(91, 71, 188, 0.3),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(20),
      ),
      child: BarChart(
        BarChartData(
          barGroups: [
            // x = 0 : Ukupno dugovanje
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: totalDueValue,
                  color: Color(0xCC1B5E20),
                )
              ],
            ),
            // x = 1 : Prethodni dug
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: previousDebtValue,
                  color: Color(0xCC1B5E20),
                )
              ],
            ),
            // x = 2 : kWh potrošnja
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: kwhValue,
                  color: Color(0xCC1B5E20),
                )
              ],
            ),
          ],
          // Koristimo novu sintaksu za titlove (s obzirom na fl_chart 0.70+)
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  TextStyle style = const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    color: Color(0xFF1B5E20),
                  );
                  switch (value.toInt()) {
                    case 0:
                      return Text('Ukup. dug.', style: style);
                    case 1:
                      return Text('Preth. dug.', style: style);
                    case 2:
                      return Text('Potr. voda', style: style);
                    default:
                      return const Text('');
                  }
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    value.toStringAsFixed(0),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: Color(0xFF1B5E20),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildDataCard(String label, String value) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFD3E0D4),
            Color(0xFFF8FAF8),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(91, 71, 188, 0.3),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Raspoređivanje u liniji
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Color(0xFF1B5E20),
            ),
          ),
        ],
      ),
    );
  }
}
