import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with logo and title
                  Center(
                    child: Column(
                      children: [
                        Image.asset('assets/logo.png', height: 60),
                        const SizedBox(height: 10),
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
                      ],
                    ),
                  ),

                  Container(
                    height: 250,
                    child: _buildChart(),
                  ),

                  const SizedBox(height: 20),

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

  Widget _buildChart() {
    double totalDueValue = double.parse(totalDue.replaceAll('€', '').trim());
    double lastInvoiceValue = double.parse(lastInvoiceAmount.replaceAll('€', '').trim());
    double previousMonthDebt = 50.0;

    return BarChart(
      BarChartData(
        barGroups: [
          BarChartGroupData(x: 0, barRods: [
            BarChartRodData(
                toY: totalDueValue,
                color: Color(0xCC1B5E20),
                borderRadius: BorderRadius.zero)
          ]),
          BarChartGroupData(x: 1, barRods: [
            BarChartRodData(
                toY: lastInvoiceValue,
                color: Color(0xFF4CAF50),
                borderRadius: BorderRadius.zero)
          ]),
          BarChartGroupData(x: 2, barRods: [
            BarChartRodData(
                toY: previousMonthDebt,
                color: Color(0xFF03A9F4),
                borderRadius: BorderRadius.zero)
          ]),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
            return Text('${value.toInt()}€', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold));
          })),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                switch (value.toInt()) {
                  case 0:
                    return Text('Ukupno', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold));
                  case 1:
                    return Text('Poslednji', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold));
                  case 2:
                    return Text('Prethodni', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold));
                }
                return Text('');
              },
            ),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildDataCard(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
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
