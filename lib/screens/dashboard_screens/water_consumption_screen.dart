import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/main_back_button_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import '../edit_profile_screen.dart';

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

  bool hasVodovodData = false;
  String? vodovodPretplatniBroj;

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

  double parseValue(String value, {String remove = ''}) {
    if (value == '...') return 0.0;
    String processed = value;
    if (remove.isNotEmpty) {
      processed = processed.replaceAll(remove, '');
    }
    processed = processed.replaceAll(' €', '').replaceAll(',', '.');
    double? result = double.tryParse(processed);
    return result ?? 0.0;
  }

  Future<void> fetchUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final authToken = prefs.getString('auth_token');

    if (userId != null && authToken != null) {
      final response = await http.get(
        Uri.parse('https://lukamasulovic.site/api/users/$userId'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var user = data['data']['user'];
        setState(() {
          vodovodPretplatniBroj = user['vodovod_pretplatni_broj'];
        });

        if (vodovodPretplatniBroj != null) {
          setState(() {
            hasVodovodData = true;
          });
          fetchData(vodovodPretplatniBroj!);
        } else {
          setState(() {
            hasVodovodData = false;
          });
        }
      } else {
        throw Exception('Failed to load user data');
      }
    } else {
      setState(() {
        hasVodovodData = false;
      });
    }
  }

  Future<void> fetchData(String vodovodPretplatniBroj) async {
    final response = await http.get(Uri.parse(
        'https://lukamasulovic.site/vodovod_niksic?pretplatniBroj=$vodovodPretplatniBroj'));

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
    fetchUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40),
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
                      decorationColor: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  hasVodovodData ? _buildChart() : _buildPopup(),
                  const SizedBox(height: 40),
                  _buildDataCard('Količina potrošnje vode:', waterConsumption),
                  _buildDataCard('Količina otpadnih voda:', sewerageConsumption),
                  _buildDataCard('Ukupno dugovanje:', totalDue),
                  _buildDataCard('Posljednji račun:', lastInvoiceAmount),
                ],
              ),
            ),
          ),
          MainBackButtonWidget(size: 38, color: Colors.black),
        ],
      ),
    );
  }

  Widget _buildPopup() {
    return AlertDialog(
      backgroundColor: Color(0xAA1B5E20),
      title: Text(
        'Podaci nisu dostupni',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      content: Text(
        'Molimo vas da unesete vaš pretplatni broj od vodovoda u podešavanjima da biste videli podatke.',
        style: TextStyle(
          color: Colors.white70,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditProfileScreen()),
            );
          },
          child: Text(
            'Uđi u podešavanja',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    double totalDueValue = parseValue(totalDue);
    double previousDebtValue = parseValue(lastInvoiceAmount);
    double waterUsedValue = parseValue(waterConsumption, remove: ' m³');

    return Container(
      width: 297,
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFD3E0D4),
            Color(0xFFF8FAF8),
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
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: totalDueValue,
                  color: Color(0xCC1B5E20),
                )
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: previousDebtValue,
                  color: Color(0xCC1B5E20),
                )
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: waterUsedValue,
                  color: Color(0xCC1B5E20),
                )
              ],
            ),
          ],
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
            MainAxisAlignment.spaceBetween,
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
