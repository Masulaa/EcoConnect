import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/main_back_button_widget.dart';

class PowerConsumptionScreen extends StatefulWidget {
  @override
  _PowerConsumptionScreenState createState() => _PowerConsumptionScreenState();
}

class _PowerConsumptionScreenState extends State<PowerConsumptionScreen> {
  String kwhConsumption = '...';
  String usageTime = '...';
  String totalDue = '...';
  String previousDebt = '...';
  String lastInvoiceDate = '...';
  String lastInvoiceAmount = '';

  double costPerKWh = 0.971;
  double maxKWhPerDay = 24 * 1.0;
  List<FlSpot> consumptionData = [];

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
        'https://lukamasulovic.site/epcg?pretplatniBroj=152577011&brojBrojila=18N4E5B2514906007'));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      double invoiceAmount = double.parse(data['poslednji_racun']['iznos']
          .replaceAll(' €', '')
          .replaceAll(',', '.'));

      double totalKWhUsed = invoiceAmount / costPerKWh;

      int daysInMonth = 30;
      double averageUsagePerDay = totalKWhUsed / daysInMonth;

      setState(() {
        kwhConsumption = totalKWhUsed.toStringAsFixed(2) + ' kW/h';
        usageTime = '${(totalKWhUsed / averageUsagePerDay).floor()} dana';
        totalDue = data['ukupno_za_uplatu'] ?? 'Nije dostupno';
        previousDebt = data['prethodni_dug'] ?? 'Nije dostupno';
        lastInvoiceDate = data['poslednji_racun']['datum'] ?? 'Nije dostupno';
        lastInvoiceAmount = data['poslednji_racun']['iznos'] ?? 'Nije dostupno';

        // Generišemo fiktivne podatke za potrošnju po danima
        consumptionData = List.generate(
          daysInMonth,
          (index) => FlSpot(index.toDouble(),
              (averageUsagePerDay * (0.8 + (index % 5) * 0.05)).toDouble()),
        );
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
                        decorationColor: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Dodajemo dijagram ispod naslova
                    _buildChart(),

                    const SizedBox(height: 40),

                    _buildDataCard('Količina potrošnje:', kwhConsumption),
                    _buildDataCard('Ukupno dugovanje za struju:', totalDue),
                    _buildDataCard('Prethodni dug:', previousDebt),
                    _buildDataCard('Posljednji račun:',
                        '$lastInvoiceDate - $lastInvoiceAmount'),
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

  Widget _buildChartBox() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: _buildChart(), // Pozivanje funkcije za dijagram
    );
  }

  Widget _buildChart() {
    // Parsiramo vrijednosti za grafikon:
    double totalDueValue = parseValue(totalDue);
    double previousDebtValue = parseValue(previousDebt);
    double kwhValue = parseValue(kwhConsumption, remove: ' kW/h');

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
                      return Text('kW/h', style: style);
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
