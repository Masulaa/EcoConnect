import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/main_back_button_widget.dart';
import 'dashboard_screens/water_consumption_screen.dart';  // New import
import 'dashboard_screens/power_consumption_screen.dart';
import 'dashboard_screens/advice_screen.dart';  // New import
import 'dashboard_screens/goals_screen.dart';  // New import

class HomeScreen extends StatelessWidget {
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
                      'Dashboard',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1B5E20),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildChartBox(),
                    const SizedBox(height: 40),
                    _buildButtonGrid(context),
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
    return Container(
      width: 297,
      height: 256,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(91, 71, 188, 0.3),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildChart()),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return BarChart(
      BarChartData(
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 508, color: Color(0xCC1B5E20), borderRadius: BorderRadius.zero)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 591, color: Color(0xCC1B5E20), borderRadius: BorderRadius.zero)]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 72, color: Color(0xCC1B5E20), borderRadius: BorderRadius.zero)]),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                switch (value.toInt()) {
                  case 0:
                    return Text('kW/H', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold));
                  case 1:
                    return Text('Сдавайся', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold));
                  case 2:
                    return Text('Хохол', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold));
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

  Widget _buildButtonGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton(context, 'Potrošnja vode', Icons.water_damage, WaterConsumptionScreen()),
              _buildButton(context, 'Potrošnja struje', Icons.electrical_services, PowerConsumptionScreen()),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton(context, 'Savjeti', Icons.lightbulb, AdviceScreen()),
              _buildButton(context, 'Ciljevi', Icons.flag, GoalsScreen()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, IconData icon, Widget destinationScreen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationScreen),
        );
      },
      child: Container(
        width: 143,
        height: 115,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(91, 71, 188, 0.3),
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Color(0xFF1B5E20), size: 40),
            const SizedBox(height: 10),
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

